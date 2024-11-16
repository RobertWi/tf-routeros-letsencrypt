# AWS Policy Components Explained

## S3 Bucket Policy
The bucket policy includes:
- `Sid`: Statement ID - A unique identifier for the policy statement (e.g., "DenyNonTLSRequests")
- `Effect`: "Deny" - Explicitly denies the specified actions
- `Principal`: "*" - Applies to all users/roles
- `Action`: "s3:*" - Applies to all S3 actions
- `Condition`: Checks if `aws:SecureTransport` is false (non-HTTPS requests)

This policy ensures that:
1. All access to the S3 bucket must use HTTPS/TLS
2. Non-encrypted transport attempts are denied
3. Applies to both bucket operations and object operations

## IAM Policy
The IAM policy includes:

### S3 Permissions
- `s3:ListBucket`: List files in the bucket
  - Required for Terraform to check state file existence
- `s3:GetObject`: Read state file
  - Required for reading current state
- `s3:PutObject`: Write state file
  - Required for saving state changes
- `s3:DeleteObject`: Clean up old state files
  - Required for state management

### DynamoDB Permissions
- `dynamodb:GetItem`: Read lock information
  - Required to check if state is locked
- `dynamodb:PutItem`: Create lock
  - Required to lock state during operations
- `dynamodb:DeleteItem`: Release lock
  - Required to unlock state after operations

## Best Practices
1. Use unique statement IDs (Sids) for clear policy management
2. Follow least privilege principle
3. Explicitly deny insecure access
4. Use conditions to enforce security requirements
5. Regularly review and update policies
