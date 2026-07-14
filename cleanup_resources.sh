#! /usr/bin/env bash


if [ -f .env ]; then
    source .env
fi
KEY_NAME=${KEY_NAME:-LabServer}
INSTANCE_ID=${INSTANCE_ID:-}

# 
echo "Terminating EC2 instance with ID: $INSTANCE_ID"
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --output text
echo "Waiting for instance to terminate..."
# Wait for the instance to terminate
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo "Instance terminated successfully."
aws ec2 delete-key-pair --key-name $KEY_NAME --output text
echo "Delete security group associated with the instance..."
aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID --output text
# Delete all object versions
aws s3api delete-objects \
    --bucket your-bucket-name \
    --delete "$(aws s3api list-object-versions --bucket your-bucket-name --output json --query '{Objects: Versions[].{Key: Key, VersionId: VersionId}}')"

echo "Deleting all versions of objects in the bucket..."
aws s3api delete-objects \
  --bucket "${BUCKET_NAME}" \
  --delete "$(aws s3api list-object-versions \
    --bucket "${BUCKET_NAME}" \
    --output json \
    --query '{Objects: Versions[].{Key: Key, VersionId: VersionId}}')"
aws s3api delete-bucket --bucket $BUCKET_NAME --output text
echo "Cleanup completed successfully."