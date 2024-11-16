# Backend Setup for RouterOS Let's Encrypt State

This directory contains the necessary AWS IAM policies and setup instructions for the Terraform backend.

## Setup Steps

1. Create S3 Bucket
2. Create DynamoDB Table
3. Apply IAM Policies
4. Configure Backend in Terraform

## Resources to Create

1. S3 Bucket: Choose a unique name (e.g., `your-terraform-state-bucket`)
2. DynamoDB Table: Choose a name (e.g., `your-terraform-state-lock`)
   - Partition key: `LockID` (String)
   - On-demand capacity

## Configuration Steps

1. Update resource names in the policy files:
   - Replace `your-terraform-state-bucket` in `iam-policy.json`
   - Replace `your-terraform-state-lock` in `iam-policy.json`
   - Update region in the DynamoDB ARN if needed

2. Optional Security Enhancements:
   - Enable bucket versioning
   - Enable server-side encryption
   - Configure lifecycle rules
   - Enable access logging

## Usage

1. Apply the policies using AWS CLI or Console
2. Update the backend configuration in `backend.tf`
3. Initialize Terraform with the new backend
