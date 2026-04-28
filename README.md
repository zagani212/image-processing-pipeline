# Image Processing Pipeline

## Overview

This repository contains an image processing pipeline deployed on AWS. It includes a Vite front-end app and multiple Node.js Lambda functions wired together with AWS services (API Gateway, S3, SQS, SNS, DynamoDB). Infrastructure is managed with Terraform under `terraform/`.

This README documents the architecture, components, deployment steps, local development, environment variables, and open questions needed to finalize deployment details.

## Architecture (high level)

![](./images/image%20processing%20architecture.png)

## Repo layout

- `front/` — Vite React front-end (index.html, src/, .env.example)
- `lambda/` — Lambda source folders:
  - `connectionHandler/` — handles client connection lifecycle
  - `medium/` — resizes/generates medium images
  - `metadata/` — extracts image metadata
  - `thumbnail/` — generates thumbnails
  - `validate/` — validates incoming images
  - `watermark/` — applies watermark to images
- `terraform/` — Terraform configs. Two areas: `bootstrap/` and `resources/` (modules and AWS resources)

## Components & responsibilities

- Front-end (`front/`): Upload UI, progress/status, and web UI that interacts with API Gateway endpoints. Uses environment variables in `.env` / `.env.example`.
- API Gateway: Exposes HTTP and (optionally) WebSocket endpoints for uploads and connection management.
- Lambda functions (`lambda/*`): Small ESM entrypoints (`index.mjs`) implementing each pipeline step. Typical flow:
  1. `validate` checks file format/size
  2. `medium` creates a medium resolution image
  3. `thumbnail` creates a small thumbnail
  4. `watermark` overlays watermark
  5. `metadata` extracts and stores metadata
  6. `connectionHandler` + `retreiveConnectionInfos` manage client connections (likely via API GW WebSockets) and store connection IDs in DynamoDB
- Storage & messaging:
  - S3: stores original and processed images
  - DynamoDB: stores active connections and/or metadata lookup
  - SNS/SQS: used to broadcast and queue processing work


## Infrastructure (Terraform)

- `terraform/bootstrap/` — initial provisioning (providers, backend, shared resources).
- `terraform/resources/` — main infra: API Gateway, Lambda deployment entries, S3 buckets, DynamoDB tables, SNS, SQS, IAM roles and permissions.

Deployment workflow (high-level):
1. Configure AWS credentials and target region.
2. From `terraform/bootstrap/`: `terraform init && terraform apply` to create any required bootstrap resources (if applicable).
3. From `terraform/resources/`: `terraform init && terraform apply` to create the main resources and deploy references to Lambda artifacts.

Terraform notes:
- The repo includes per-service TF files under `terraform/resources/` (s3, lambda, api-gateway, dynamodb, sns, sqs, permissions).

## Local development

Front-end (Vite):

1. cd into `front/`
2. Install dependencies: `npm install`
3. Run dev server: `npm run dev`
4. Build: `npm run build`


## Environment variables

- `front/.env.example` holds front-end vars (copy to `.env` and set values).
- Terraform and Lambdas will need AWS credentials and a set of resource identifiers (S3 bucket names, DynamoDB table names, API Gateway endpoints).

Common values you should provide:
- AWS_REGION
- AWS_ACCOUNT_ID
- S3_BUCKET_NAME (or prefix for originals/processed)
- API_BASE_URL (deployed API Gateway URL)
- DYNAMODB_TABLE_CONNECTIONS
- SNS_TOPIC_ARN / SQS_QUEUE_URL (if used directly by Lambdas)

Add these to the appropriate `.tfvars` or CI secrets.

## CI / deployment considerations

- Build artifacts: Ensure Lambda packages (zipped) are created in CI and uploaded or referenced by Terraform.
- IAM roles: Terraform defines permissions per-lambda in `terraform/resources/permissions/` — verify least-privilege rules and S3/DynamoDB access.

## Testing & monitoring

- Add unit tests for image processing functions where possible (mock streams/files).
- Use CloudWatch logs + X-Ray for Lambda observability.
- Add S3 event notifications and DLQs for failed messages.

## Troubleshooting

- If uploads fail: check API Gateway logs, Lambda errors in CloudWatch, and S3 bucket policies.
- If processing is slow: check SQS backlog, Lambda concurrency limits, and function memory/timeouts.

## Files of interest

- Front-end: `front/` (UI and env example)
- Terraform: `terraform/bootstrap/` and `terraform/resources/`
- Lambdas: `lambda/*/index.mjs`