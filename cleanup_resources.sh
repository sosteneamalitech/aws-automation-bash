#!/usr/bin/env bash

# Source env if exists to retrieve saved resource IDs/Names
if [ -f .env ]; then
  source .env
fi

OWNER="sostene"
PROJECT="sostene-lab1-aws-automation"

# Terminate EC2 Instance
# Use ID from .env if available, otherwise find by tags
INSTANCE_ID=${INSTANCE_ID:-}
if [ -z "$INSTANCE_ID" ]; then
  INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Owner,Values=$OWNER" "Name=tag:Project,Values=$PROJECT" "Name=instance-state-name,Values=running,pending,stopped" \
    --query "Reservations[*].Instances[*].InstanceId" --output text)
fi

if [ -n "$INSTANCE_ID" ]; then
  echo "Terminating EC2 instance: $INSTANCE_ID"
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID --output text >/dev/null
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
fi

# Delete Key Pair
# Use KEY_NAME from .env if available, otherwise find by tags
KEY_NAME=${KEY_NAME:-}
if [ -z "$KEY_NAME" ]; then
  KEY_NAME=$(aws ec2 describe-key-pairs \
    --filters "Name=tag:Owner,Values=$OWNER" "Name=tag:Project,Values=$PROJECT" \
    --query "KeyPairs[*].KeyName" --output text)
fi

if [ -n "$KEY_NAME" ]; then
  echo "Deleting Key Pair: $KEY_NAME"
  aws ec2 delete-key-pair --key-name "$KEY_NAME" >/dev/null
  rm -f "${KEY_NAME}.pem"
fi

# Delete Security Group
# Use SECURITY_GROUP_ID from .env if available, otherwise find by tags
SG_ID=${SECURITY_GROUP_ID:-}
if [ -z "$SG_ID" ]; then
  SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=tag:Owner,Values=$OWNER" "Name=tag:Project,Values=$PROJECT" \
    --query "SecurityGroups[*].GroupId" --output text)
fi

if [ -n "$SG_ID" ]; then
  echo "Deleting Security Group: $SG_ID"
  aws ec2 delete-security-group --group-id "$SG_ID" >/dev/null
fi

# Delete S3 Bucket
# Use BUCKET_NAME from .env if available, otherwise find by tags
BUCKETS_TO_DELETE=""
if [ -n "${BUCKET_NAME:-}" ]; then
  BUCKETS_TO_DELETE="$BUCKET_NAME"
else
  # Find buckets by tag
  for bucket in $(aws s3api list-buckets --query "Buckets[*].Name" --output text); do
    if aws s3api get-bucket-tagging --bucket "$bucket" --query "TagSet[?Key=='Owner'&&Value=='$OWNER']" --output text 2>/dev/null | grep -q "$OWNER"; then
      BUCKETS_TO_DELETE="$BUCKETS_TO_DELETE $bucket"
    fi
  done
fi

for bucket in $BUCKETS_TO_DELETE; do
  echo "Deleting S3 bucket: $bucket"
  
  # Delete all object versions and delete markers to empty bucket
  versions=$(aws s3api list-object-versions --bucket "$bucket" --query '{Objects: Versions[].{Key: Key, VersionId: VersionId}}' --output json 2>/dev/null)
  [ -n "$versions" ] && [ "$versions" != "null" ] && aws s3api delete-objects --bucket "$bucket" --delete "$versions" >/dev/null 2>&1 || true

  markers=$(aws s3api list-object-versions --bucket "$bucket" --query '{Objects: DeleteMarkers[].{Key: Key, VersionId: VersionId}}' --output json 2>/dev/null)
  [ -n "$markers" ] && [ "$markers" != "null" ] && aws s3api delete-objects --bucket "$bucket" --delete "$markers" >/dev/null 2>&1 || true

  aws s3api delete-bucket --bucket "$bucket" >/dev/null
done

echo "" >.env
echo "Cleanup completed successfully."

