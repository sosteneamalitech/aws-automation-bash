#!/usr/bin/env bash

echo "Task 4: Creating S3 bucket .....\n ..........\n"

if [ -f .env ]; then
    source .env
fi
# Exit immediately if a command exits with a non-zero status
REGION=$(aws configure get region)

if [ -z "$REGION" ]; then
    REGION="us-east-1"
fi

BUCKET_NAME="my-unique-bucket-$(date +%s)"
FILE_NAME="welcome.txt"

echo "Using target AWS region: ${REGION}"
echo "Creating S3 bucket: ${BUCKET_NAME}..."

# Create the bucket using s3api per the hint
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" --output text
echo "Enabling versioning on the bucket..."
# Enable versioning using s3api per the hint
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled\
    --output text

echo "Applying bucket policy..."
POLICY_JSON=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EnforceHTTPS",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}",
                "arn:aws:s3:::${BUCKET_NAME}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
)

aws s3api put-bucket-policy \
    --bucket "$BUCKET_NAME" \
    --policy "$POLICY_JSON" \
    --output text

echo "Creating and uploading sample file..."
echo "Welcome to your new AWS S3 Bucket!" > "$FILE_NAME"

aws s3api put-object \
    --bucket "$BUCKET_NAME" \
    --key "$FILE_NAME" \
    --body "$FILE_NAME" \
    --output text

echo " Created bucket: ${BUCKET_NAME}"
echo "BUCKET_NAME=$BUCKET_NAME">>.env
