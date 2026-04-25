import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";
import sharp from "sharp";

const s3 = new S3Client({});
const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const sns = new SNSClient({});


const TABLE_NAME = process.env.DYNAMO_TABLE;
const SNS_TOPIC_ARN = process.env.SNS_TOPIC_ARN;

export const handler = async (event) => {
  console.log("Received SQS event:", JSON.stringify(event, null, 2));

  const results = [];

  for (const record of event.Records) {
    try {
      const body = JSON.parse(record.body);

      const { bucket, key, filename, uploadedAt, connectionId} = body;

      if (!bucket || !key) {
        throw new Error("Missing bucket or key in message");
      }

      // 1. Get image from S3
      const s3Response = await s3.send(
        new GetObjectCommand({
          Bucket: bucket,
          Key: key,
        })
      );

      const streamToBuffer = async (stream) =>
        new Promise((resolve, reject) => {
          const chunks = [];
          stream.on("data", (chunk) => chunks.push(chunk));
          stream.on("error", reject);
          stream.on("end", () => resolve(Buffer.concat(chunks)));
        });

      const imageBuffer = await streamToBuffer(s3Response.Body);

      // 2. Extract metadata using sharp
      const metadata = await sharp(imageBuffer).metadata();

      const item = {
        imageId: key, // use S3 key as unique ID
        filename,
        bucket,
        key,
        uploadedAt,

        // metadata
        format: metadata.format,
        width: metadata.width,
        height: metadata.height,
        size: imageBuffer.length,
        space: metadata.space,
        channels: metadata.channels,
        hasAlpha: metadata.hasAlpha,

        createdAt: new Date().toISOString(),
      };

      // 3. Store in DynamoDB
      await dynamo.send(
        new PutCommand({
          TableName: TABLE_NAME,
          Item: item,
        })
      );

      await sns.send(
        new PublishCommand({
          TopicArn: SNS_TOPIC_ARN,
          Message: JSON.stringify({
            Bucket: bucket,
            Key: key,
            ConnectionId: connectionId
          }),
          Subject: "ImageToBeResized",
        })
      );

      results.push({ key, status: "processed" });
    } catch (err) {
      console.error("Error processing record:", err);

      // ❗ Important: throw to trigger SQS retry / DLQ
      throw err;
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Batch processed",
      results,
    }),
  };
};