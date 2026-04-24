import Busboy from "busboy";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";
import crypto from "crypto";

const s3 = new S3Client({});
const sqs = new SQSClient({});

const MAX_FILE_SIZE = parseInt(process.env.MAX_FILE_SIZE || "5000000");
const BUCKET = process.env.S3_BUCKET;
const QUEUE_URL = process.env.SQS_QUEUE_URL;

export const handler = async (event) => {
  return new Promise((resolve, reject) => {
    try {
      const contentType =
        event.headers["content-type"] || event.headers["Content-Type"];

      if (!contentType?.includes("multipart/form-data")) {
        return resolve({
          statusCode: 400,
          body: JSON.stringify({ error: "Invalid content type" }),
        });
      }

      const busboy = Busboy({
        headers: { "content-type": contentType },
      });

      const bodyBuffer = event.isBase64Encoded
        ? Buffer.from(event.body, "base64")
        : Buffer.from(event.body);

      const uploadPromises = [];
      const results = [];

      busboy.on("file", (fieldname, file, info) => {
        const { filename, mimeType } = info;

        if (fieldname !== "images") {
          file.resume();
          return;
        }

        let fileSize = 0;
        const chunks = [];

        file.on("data", (data) => {
          fileSize += data.length;

          if (fileSize <= MAX_FILE_SIZE) {
            chunks.push(data);
          }
        });

        file.on("end", () => {
          // Validate
          if (!mimeType?.startsWith("image/")) {
            results.push({ filename, status: "rejected", reason: "invalid type" });
            return;
          }

          if (fileSize > MAX_FILE_SIZE) {
            results.push({ filename, status: "rejected", reason: "too large" });
            return;
          }

          const buffer = Buffer.concat(chunks);
          const key = `uploads/${Date.now()}-${crypto.randomUUID()}-${filename}`;

          console.log("UPLOAD....")

          const uploadPromise = (async () => {
            console.log("let's upload")
            console.log({
              Bucket: BUCKET,
              Key: key,
              Body: buffer,
              ContentType: mimeType,
            })
            // Upload to S3
            await s3.send(
              new PutObjectCommand({
                Bucket: BUCKET,
                Key: key,
                Body: buffer,
                ContentType: mimeType,
              })
            );

            console.log("image uploaded")

            const fileUrl = `https://${BUCKET}.s3.amazonaws.com/${key}`;

            // Send message to SQS
            await sqs.send(
              new SendMessageCommand({
                QueueUrl: QUEUE_URL,
                MessageBody: JSON.stringify({
                  filename,
                  key,
                  bucket: BUCKET,
                  url: fileUrl,
                  uploadedAt: new Date().toISOString(),
                }),
              })
            );

            results.push({
              filename,
              status: "uploaded",
              url: fileUrl,
            });
          })();

          uploadPromises.push(uploadPromise);
        });
      });

      busboy.on("finish", async () => {
        try {
          await Promise.all(uploadPromises);

          resolve({
            statusCode: 200,
            body: JSON.stringify({
              message: "Processing complete",
              results,
            }),
          });
        } catch (err) {
          console.log(err)
          reject({
            statusCode: 500,
            body: JSON.stringify({ error: err.message }),
          });
        }
      });

      busboy.end(bodyBuffer);
    } catch (err) {
      console.log(err)
      reject({
        statusCode: 500,
        body: JSON.stringify({ error: err.message }),
      });
    }
  });
};