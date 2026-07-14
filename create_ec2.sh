#! /usr/bin/env bash
echo "Task 2: Creating EC2 instance .....\n ..........\n"
if [ -f .env ]; then
    source .env
fi

# Variables
KEY_NAME=${KEY_NAME:-LabServer}
INSTANCE_TYPE=${INSTANCE_TYPE:-t3.micro}
IMAGE_ID=${IMAGE_ID:-ami-07ab13a91f7d7a8af}
TAG_KEY=${TAG_KEY:-Project}
TAG_VALUE=${TAG_VALUE:-AutomationLab}

echo "Creating key pair: $KEY_NAME"
# First create the key pair and save it to a .pem file
aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text >$KEY_NAME.pem
# change permissions of the .pem file to be read-only for the owner
chmod 400 $KEY_NAME.pem

echo "Creating instance with type: $INSTANCE_TYPE, image ID: $IMAGE_ID, key name: $KEY_NAME, and tags: $TAG_KEY=$TAG_VALUE"
# CREATE EC2 INSTANCE and then save in in variable instance id
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE --associate-public-ip-address  \
    --key-name $KEY_NAME --query "Instances[*].InstanceId" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=$TAG_KEY,Value=$TAG_VALUE}]" \
    --output text)
 

# wait for the instance to be in running state
while [ -z "$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].State.Name' --output text | grep running)" ]; do
    echo "Waiting for instance to be in running state..."
    sleep 5
done
# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID  --query "Reservations[*].Instances[*].PublicIpAddress"  --output text)

# Export variable so that they can be used in destroy.sh

echo  "Instance created with ID: %s\n" "$INSTANCE_ID"
echo "Public IP address: %s\n" "$PUBLIC_IP"
echo KEY_NAME=$KEY_NAME
echo "INSTANCE_ID=$INSTANCE_ID">>.env
echo "PUBLIC_IP=$PUBLIC_IP">>.env

