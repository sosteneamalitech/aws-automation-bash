#!/usr/bin/env bash

set -euo pipefail
# check if user account is there

./create_ec2.sh
./create_security_group.sh
./create_s3_bucket.sh

