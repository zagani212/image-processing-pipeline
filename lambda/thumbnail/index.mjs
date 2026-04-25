import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import sharp from "sharp";

const s3 = new S3Client({});

const DEST_BUCKET = process.env.THUMBNAIL_BUCKET;
const PREFIX = process.env.THUMBNAIL_PREFIX || "thumbnails/";
const SIZE = parseInt(process.env.THUMBNAIL_SIZE || "150", 10);

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

      const { bucket, key } = body;
      if (!bucket || !key) throw new Error("Missing bucket/key");

      // 1) Read original
      const obj = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }));
      const inputBuffer = await streamToBuffer(obj.Body);

      // 2) Resize to 150x150 (cover = crop to square)
      const thumbBuffer = await sharp(inputBuffer)
        .resize(SIZE, SIZE, { fit: "cover" }) // crop to exact 150x150
        .toFormat("jpeg", { quality: 85 })    // normalize output
        .toBuffer();

      // 3) Build destination key
      const baseName = key.split("/").pop();
      const destKey = `${PREFIX}${baseName.replace(/\.\w+$/, "")}_thumb.jpg`;

      // 4) Write thumbnail
      await s3.send(
        new PutObjectCommand({
          Bucket: DEST_BUCKET || bucket,
          Key: destKey,
          Body: thumbBuffer,
          ContentType: "image/jpeg",
        })
      );

      results.push({ key, thumbnailKey: destKey, status: "ok" });
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