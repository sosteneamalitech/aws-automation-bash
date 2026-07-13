#! /usr/bin/env bash
KEY_NAME=${KEY_NAME:-LabServer}
INSTANCE_ID=${INSTANCE_ID:-}

#distroy
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --query
aws ec2 delete-key-pair --key-name $KEY_NAME

echo "Instance created with ID: $result"