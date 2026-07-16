#!/usr/bin/env bash

# Check if AWS cli is installed
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install it before running this script."
  exit 1
fi

# Check if AWS_PROFILE is set (ensures you aren't using the default profile)
if [ -z "$AWS_PROFILE" ]; then
  echo "Error: AWS_PROFILE is not set. Please set a profile (e.g., export AWS_PROFILE=your-profile) to avoid using the default profile."
  exit 1
fi

# check if the output is handled by cli pager like less or more, if so, disable it
if [ -n "$AWS_PAGER" ] || [ -n "$(aws configure get cli_pager 2>/dev/null)" ]; then
  echo "Disabling AWS CLI pager to avoid output issues. You can disable this by setting export AWS_PAGER=\"\" or aws configure set cli_pager \"\""
  exit 1
fi


echo "Using AWS Profile: $AWS_PROFILE"

aws sts get-caller-identity
aws configure list

echo "Success: Using AWS Profile '$AWS_PROFILE'"
