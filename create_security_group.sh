#!/usr/bin/env bash
if [ -f .env ]; then
    source .env
fi
# Exit immediately if a command exits with a non-zero status
set -e

# Define variables based on the task description
GROUP_NAME="devops-sg"
DESCRIPTION="Automated DevOps Security Group for SSH and HTTP"

echo "Creating security group '${GROUP_NAME}'..."

# Create the security group and capture its ID using the default profile region
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name "$GROUP_NAME" \
    --description "$DESCRIPTION" \
    --query 'GroupId' \
    --output text)


echo "Authorizing HTTP (port 80) and SSH (port 22) ingress rules..."

# Add ingress rules for both port 22 and port 80 in a single consolidated API call
aws ec2 authorize-security-group-ingress \
    --group-id "$SECURITY_GROUP_ID" \
    --ip-permissions \
        'IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=0.0.0.0/0}]' \
        'IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=0.0.0.0/0}]' \
        --output text

echo -e "--- Security Group Configuration Details ---"
echo "Security Group ID: ${SECURITY_GROUP_ID}"
echo "Security Group Name: ${GROUP_NAME}"
# assign the security group to the EC2 instance

# Fetch the primary Network Interface ID (ENI) of the EC2 instance
INTERFACE_ID=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[*].Instances[*].NetworkInterfaces[*].NetworkInterfaceId" \
    --output text)
echo "Primary Network Interface ID: ${INTERFACE_ID}"
#  Assign the security group directly to the Network Interface
aws ec2 modify-network-interface-attribute \
    --network-interface-id "$INTERFACE_ID" \
    --groups "$SECURITY_GROUP_ID"


# Describe the rules of the newly created security group to display them
aws ec2 describe-security-groups \
    --group-ids "$SECURITY_GROUP_ID" \
    --query 'SecurityGroups[0].IpPermissions[*].{Protocol:IpProtocol,From:FromPort,To:ToPort,Ranges:IpRanges[*].CidrIp}' \
    --output table

echo "SECURITY_GROUP_ID=$SECURITY_GROUP_ID" >> .env
echo "GROUP_NAME=$GROUP_NAME" >> .env
