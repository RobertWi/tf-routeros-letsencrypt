# RouterOS Let's Encrypt Certificate Home Automation

This Terraform project automates the process of obtaining and managing Let's Encrypt SSL certificates for RouterOS devices in a private home network. It uses Cloudflare for DNS challenges and supports local DNS resolution through BIND9.

## Important: Initial Setup

⚠️ **Initial Router API Configuration**:

1. Start with non-SSL API port first:
   ```hcl
   # Initial terraform.tfvars configuration
   router_url = "api://192.168.33.1:8728"  # Note: Use non-SSL API port initially
   ```

2. After Let's Encrypt certificate is successfully placed:
   ```hcl
   # Update terraform.tfvars to use SSL
   router_url = "apis://192.168.33.1:8729"  # Switch to SSL API port
   ```

3. Final Security Steps:
   - Go to your RouterOS device's IP → Services
   - Disable the plain API port (8728)
   - Keep only the API-SSL port (8729) enabled

This ensures secure API communication after the initial certificate setup.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ Let's       │     │ Cloudflare   │     │ RouterOS    │
│ Encrypt     │◄────┤ DNS          │     │ Device      │
│ Authority   │     │ (Challenge)  │     │             │
└─────────────┘     └──────────────┘     └─────────────┘
       ▲                                        ▲
       │                                        │
       │            ┌──────────────┐           │
       └────────────┤ Terraform    ├───────────┘
                    │ Automation   │
                    └──────────────┘
                           ▲
                           │
                    ┌──────────────┐
                    │ Local BIND9  │
                    │ DNS Server   │
                    └──────────────┘
```

### How it Works

1. **DNS Setup**:
   - Uses Cloudflare as the public DNS provider
   - Local BIND9 server handles `.home` zone resolution
   - Enables certificate validation for private network hosts

2. **Certificate Process**:
   - Terraform requests Let's Encrypt certificate
   - DNS challenge performed through Cloudflare API
   - Certificate automatically deployed to RouterOS
   - SSL services (www-ssl, api-ssl) configured automatically

3. **Automation Benefits**:
   - Zero-touch certificate renewal
   - Secure private network setup
   - Automated RouterOS configuration

## Prerequisites

- Terraform installed
- A domain managed by Cloudflare
- RouterOS device with API access enabled (port 8729)
- Local BIND9 server for `.home` zone resolution
- Cloudflare API tokens with appropriate permissions
- AWS account for state storage

### AWS S3 State Storage

This project uses AWS S3 for secure, remote state storage with the following setup:

1. S3 Bucket:
   - Used for storing Terraform state
   - Encryption enabled for security
   - Region: eu-west-1 (configurable)

2. DynamoDB Table:
   - Used for state locking
   - Prevents concurrent modifications

Example backend configuration (adjust for your setup):
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "your-terraform-state-lock"
  }
}
```

Required AWS permissions:
- S3 bucket access
- DynamoDB table access
- AWS credentials configured locally

#### Optional: Enhanced AWS Security Configuration

While basic S3 and DynamoDB permissions are sufficient for testing, consider these security enhancements for production:

1. Security Best Practices:
   - Use a dedicated IAM user for Terraform
   - Enable MFA for the IAM user
   - Regularly rotate access keys
   - Monitor access using AWS CloudTrail
   - Consider using AWS KMS for additional encryption control

2. Recommended IAM Policy for S3 State Bucket (least privilege):
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::your-terraform-state-bucket"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::your-terraform-state-bucket/terraform.tfstate"
        }
    ]
}
```

3. Recommended IAM Policy for DynamoDB Lock Table:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:REGION:*:table/your-terraform-state-lock"
        }
    ]
}
```

4. Recommended S3 Bucket Security Features:
   - Enable versioning for state history
   - Enable server-side encryption (AES-256 or KMS)
   - Block public access
   - Optional: Enable access logging
   - Optional: Configure lifecycle rules for old versions

Optional S3 bucket policy to enforce encryption and HTTPS:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RequireEncryptedTransport",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::your-terraform-state-bucket",
                "arn:aws:s3:::your-terraform-state-bucket/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
```

### Required Cloudflare API Tokens

1. DNS API Token:
   - Permissions: Zone:DNS:Edit
   - Resources: Include > All zones

2. Zone API Token:
   - Permissions: Zone:Zone:Read
   - Resources: Include > All zones

## Configuration

### BIND9 Setup

Ensure your BIND9 server is configured to:
1. Handle the `.home` zone
2. Forward other queries to appropriate DNS servers
3. Allow queries from your RouterOS device

Example BIND9 zone configuration:
```bind
zone "home.example.com" {
    type master;
    file "/etc/bind/zones/db.home.example.com";
    allow-query { 192.168.0.0/16; };
    allow-transfer { none; };
};
```

Ensure your BIND9 server (192.168.1.1) is configured properly:
```bash
# Test local resolution
dig @192.168.1.1 router.home.example.com

# Test ACME challenge resolution
dig @192.168.1.1 _acme-challenge.router.home.example.com
```

### Environment Variables

Create a `terraform.tfvars` file with your configuration:

```hcl
# Router Configuration
router_url = "api://192.168.1.1:8728"  # Start with non-SSL API port
router_user = "admin"
router_password = "your_password"

# After certificate is placed, update to:
# router_url = "apis://192.168.1.1:8729"  # SSL API port

# Cloudflare Configuration
cloudflare_dns_api_token = "your_dns_api_token"
cloudflare_zone_api_token = "your_zone_api_token"
cloudflare_zone_id = "your_zone_id"
cloudflare_zone_name = "example.com"

# Domain Configuration
subdomain = "router"
domain_prefix = "home"
email_address = "your.email@example.com"

# Optional: DNS Configuration
recursive_nameservers = ["192.168.1.53:53"]  # Your BIND9 server
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Plan and apply with non-SSL API first:
```bash
terraform plan
terraform apply
```

3. After successful certificate deployment:
   - Update `router_url` in terraform.tfvars to use SSL port (8729)
   - Disable plain API port in RouterOS
   - Run terraform apply again to ensure everything works with SSL

## Certificate Management

The solution automatically:
1. Obtains Let's Encrypt certificates
2. Uploads them to your RouterOS device
3. Configures SSL services
4. Handles certificate renewals
5. Removes local certificate files after successful upload

Certificate files on RouterOS:
- Certificate: `[hostname]-fullchain.pem`
- Private Key: `[hostname]-privkey.pem`

### Security Notes

1. Local Certificate Handling:
   - Certificate files are temporarily created with restricted permissions (600 for key, 644 for cert)
   - Files are automatically removed after successful upload to RouterOS
   - Cleanup is triggered after successful certificate import
   - No sensitive files are left on the local system

2. API Security:
   - Use separate tokens for DNS and Zone management
   - Store tokens securely
   - Apply principle of least privilege

## Security Considerations

1. API Tokens:
   - Use separate tokens for DNS and Zone management
   - Store tokens securely
   - Apply principle of least privilege

2. Network Security:
   - Restrict BIND9 queries to trusted networks
   - Secure RouterOS API access
   - Use strong passwords

## Troubleshooting

1. DNS Resolution:
   ```bash
   # Test local DNS
   dig @192.168.1.53 router.home.example.com
   
   # Test Cloudflare challenge
   dig @1.1.1.1 _acme-challenge.router.home.example.com
   ```

2. Certificate Status:
   ```bash
   # Check certificate on RouterOS
   ssh admin@192.168.1.1 "/certificate print"
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
