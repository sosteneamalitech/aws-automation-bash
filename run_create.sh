#!/usr/bin/env bash
export AWS_PAGER=""

./create_ec2.sh
./create_security_group.sh
./create_s3_bucket.sh