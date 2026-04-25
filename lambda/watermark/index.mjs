import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import sharp from "sharp";
import AWS from "aws-sdk";

const s3 = new S3Client({});

const PREFIX = process.env.THUMBNAIL_PREFIX || "watermarked/";
const ENDPOINT = process.env.ENDPOINT || "tnynwdt4o1.execute-api.eu-west-3.amazonaws.com/dev-stage";

const WATERMARK_TEXT = process.env.WATERMARK_TEXT || "© MyApp";

// helper: stream -> buffer
const streamToBuffer = async (stream) =>
  new Promise((resolve, reject) => {
    const chunks = [];
    stream.on("data", (c) => chunks.push(c));
    stream.on("error", reject);
    stream.on("end", () => resolve(Buffer.concat(chunks)));
  });

// generate SVG watermark
const createWatermarkSVG = (text, width, height) => `
<svg width="${width}" height="${height}">
  <style>
    .title {
      fill: white;
      font-size: 32px;
      font-family: Arial, sans-serif;
      opacity: 0.6;
    }
  </style>
  <text x="95%" y="95%" text-anchor="end" class="title">${text}</text>
</svg>
`;

export const handler = async (event) => {
  console.log("EVENT:", JSON.stringify(event, null, 2));

  const results = [];

  for (const record of event.Records ?? []) {
    try {
      const body = typeof record.body === "string" ? JSON.parse(record.body) : record.body;
      const { Bucket, Key, ConnectionId } = JSON.parse(body.Message);

      if (!Bucket || !Key) throw new Error("Missing bucket/key");

      // 1. Read original
      const obj = await s3.send(new GetObjectCommand({ Bucket, Key }));
      const inputBuffer = await streamToBuffer(obj.Body);

      // 2. Get image metadata (to size watermark properly)
      const metadata = await sharp(inputBuffer).metadata();

      const svg = createWatermarkSVG(
        WATERMARK_TEXT,
        metadata.width,
        metadata.height
      );

      // 3. Apply watermark (NO resize)
      const watermarkedBuffer = await sharp(inputBuffer)
        .composite([
          {
            input: Buffer.from(svg),
            gravity: "southeast", // bottom-right
          },
        ])
        .toFormat("jpeg", { quality: 90 })
        .toBuffer();

      // 4. Build destination key
      const baseName = Key.split("/").pop();
      const destKey = `${PREFIX}${baseName.replace(/\.\w+$/, "")}_watermarked.jpg`;

      // 5. Upload
      await s3.send(
        new PutObjectCommand({
          Bucket,
          Key: destKey,
          Body: watermarkedBuffer,
          ContentType: "image/jpeg",
        })
      );

      // 6. Generate signed URL
      const command = new GetObjectCommand({
        Bucket,
        Key: destKey,
      });

      const signedUrl = await getSignedUrl(s3, command, {
        expiresIn: 3600,
      });

      // 7. Send via WebSocket
      const apigw = new AWS.ApiGatewayManagementApi({
        endpoint: ENDPOINT,
      });

      try {
        await apigw
          .postToConnection({
            ConnectionId,
            Data: JSON.stringify({
              type: "WATERMARK_GENERATED",
              url: signedUrl,
            }),
          })
          .promise();
      } catch (err) {
        if (err.statusCode === 410) {
          console.log("Stale connection, should delete:", ConnectionId);
        } else {
          throw err;
        }
      }

      results.push({ Key, watermarkedKey: destKey, status: "ok" });
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