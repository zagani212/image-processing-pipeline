import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import sharp from "sharp";
import AWS from "aws-sdk";

const s3 = new S3Client({});

const PREFIX = process.env.THUMBNAIL_PREFIX || "mediums/";
const SIZE = parseInt(process.env.THUMBNAIL_SIZE || "800", 10);
const ENDPOINT = process.env.ENDPOINT || "tnynwdt4o1.execute-api.eu-west-3.amazonaws.com/dev-stage"

// helper: stream -> buffer
const streamToBuffer = async (stream) =>
  new Promise((resolve, reject) => {
    const chunks = [];
    stream.on("data", (c) => chunks.push(c));
    stream.on("error", reject);
    stream.on("end", () => resolve(Buffer.concat(chunks)));
  });

export const handler = async (event) => {
  console.log("EVENT:", JSON.stringify(event, null, 2));

  const results = [];

  for (const record of event.Records ?? []) {
    try {
      const body = typeof record.body === "string" ? JSON.parse(record.body) : record.body;

      const { Bucket, Key, ConnectionId } = JSON.parse(body.Message);
      
      if (!Bucket || !Key) throw new Error("Missing bucket/key");
      // 1) Read original
      const obj = await s3.send(new GetObjectCommand({ Bucket, Key }));
      const inputBuffer = await streamToBuffer(obj.Body);

      // 2) Resize to 150x150 (cover = crop to square)
      const thumbBuffer = await sharp(inputBuffer)
        .resize(SIZE, SIZE, { fit: "cover" }) // crop to exact 150x150
        .toFormat("jpeg", { quality: 85 })    // normalize output
        .toBuffer();

      // 3) Build destination key
      const baseName = Key.split("/").pop();
      const destKey = `${PREFIX}${baseName.replace(/\.\w+$/, "")}_thumb.jpg`;

      // 4) Write thumbnail
      await s3.send(
        new PutObjectCommand({
          Bucket,
          Key: destKey,
          Body: thumbBuffer,
          ContentType: "image/jpeg",
        })
      );

      const command = new GetObjectCommand({
        Bucket,
        Key: destKey,
      });

      const signedUrl = await getSignedUrl(s3, command, {
        expiresIn: 3600, // seconds (1 hour)
      });

      const apigw = new AWS.ApiGatewayManagementApi({
        endpoint: ENDPOINT,
      });

      await apigw
        .postToConnection({
          ConnectionId,
          Data: JSON.stringify({ type: "MEDIUM_GENERATED", url: signedUrl }),
        })
        .promise();

      results.push({ Key, thumbnailKey: destKey, status: "ok" });
    } catch (err) {
      console.error("Error processing record:", err);
      throw err;
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ results }),
  };
};