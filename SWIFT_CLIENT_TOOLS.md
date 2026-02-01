# Software Tools for Connecting to OpenStack Swift

OpenStack Swift is S3-compatible, so you can use various tools designed for S3 or Swift.

## Command Line Tools

### 1. **OpenStack Swift CLI** (Native)
```bash
# Install
pip install python-swiftclient

# Configure
export OS_AUTH_URL=http://192.168.2.3:5000/v3
export OS_USERNAME=admin
export OS_PASSWORD=your-password
export OS_TENANT_NAME=admin
export OS_REGION_NAME=RegionOne

# Or use clouds.yaml
export OS_CLOUD=openstack

# Usage
swift list                    # List containers
swift list terraform-state    # List objects in container
swift upload terraform-state file.txt  # Upload file
swift download terraform-state file.txt  # Download file
swift stat terraform-state    # Container info
```

### 2. **AWS CLI** (S3-Compatible)
```bash
# Install
pip install awscli

# Configure for Swift
aws configure set aws_access_key_id $OS_USERNAME
aws configure set aws_secret_access_key $OS_PASSWORD
aws configure set default.region us-east-1

# Or use environment variables
export AWS_ACCESS_KEY_ID=$OS_USERNAME
export AWS_SECRET_ACCESS_KEY=$OS_PASSWORD
export AWS_DEFAULT_REGION=us-east-1

# Usage with endpoint
aws --endpoint-url=https://iron.graphicsforge.net s3 ls
aws --endpoint-url=https://iron.graphicsforge.net s3 ls s3://terraform-state/
aws --endpoint-url=https://iron.graphicsforge.net s3 cp file.txt s3://terraform-state/
aws --endpoint-url=https://iron.graphicsforge.net s3 sync ./local-folder s3://terraform-state/
```

### 3. **rclone** (Universal)
```bash
# Install
# macOS: brew install rclone
# Linux: curl https://rclone.org/install.sh | sudo bash

# Configure
rclone config

# Select: Swift / OpenStack Swift
# Enter endpoint: https://iron.graphicsforge.net
# Enter access key: your-username
# Enter secret key: your-password
# Region: us-east-1

# Usage
rclone lsd swift:                    # List containers
rclone ls swift:terraform-state     # List objects
rclone copy file.txt swift:terraform-state/
rclone sync ./local swift:terraform-state/
```

### 4. **s3cmd** (S3-Compatible)
```bash
# Install
pip install s3cmd

# Configure
s3cmd --configure

# Set:
# Access Key: your-username
# Secret Key: your-password
# S3 Endpoint: iron.graphicsforge.net
# Use HTTPS: Yes
# Use path-style: Yes

# Usage
s3cmd ls s3://terraform-state/
s3cmd put file.txt s3://terraform-state/
s3cmd get s3://terraform-state/file.txt
```

## GUI Applications

### 1. **Cyberduck** (macOS/Windows)
- **Download:** https://cyberduck.io/
- **Setup:**
  - New Connection → S3 (Amazon Simple Storage Service)
  - Server: `iron.graphicsforge.net`
  - Access Key ID: Your OpenStack username
  - Secret Access Key: Your OpenStack password
  - Path Style: Enable (important for Swift)

### 2. **S3 Browser** (Windows)
- **Download:** https://s3browser.com/
- **Setup:**
  - Add New Account → S3 Compatible Storage
  - Account Name: Swift
  - REST Endpoint: `https://iron.graphicsforge.net`
  - Access Key ID: Your username
  - Secret Access Key: Your password
  - Use Path Style: Yes

### 3. **CloudBerry Explorer** (Cross-platform)
- **Download:** https://www.cloudberrylab.com/
- Supports S3-compatible storage
- Configure with Swift endpoint

### 4. **Mountain Duck** (macOS/Windows)
- **Download:** https://mountainduck.io/
- Similar to Cyberduck, mounts S3 as a drive
- Same configuration as Cyberduck

### 5. **FileZilla Pro** (Cross-platform)
- **Download:** https://filezilla-project.org/
- Supports S3-compatible storage
- Configure with Swift endpoint

## Terraform Backend (Already Configured)

Your Terraform is already configured to use Swift:

```bash
# Backend configuration in backend.s3.hcl
bucket = "terraform-state"
endpoint = "https://iron.graphicsforge.net"
```

## Python SDK

### boto3 (AWS SDK - S3 Compatible)
```python
import boto3
from botocore.client import Config

s3 = boto3.client(
    's3',
    endpoint_url='https://iron.graphicsforge.net',
    aws_access_key_id='your-username',
    aws_secret_access_key='your-password',
    config=Config(signature_version='s3v4'),
    region_name='us-east-1'
)

# List buckets
response = s3.list_buckets()

# List objects
objects = s3.list_objects_v2(Bucket='terraform-state')

# Upload file
s3.upload_file('local-file.txt', 'terraform-state', 'remote-file.txt')

# Download file
s3.download_file('terraform-state', 'remote-file.txt', 'local-file.txt')
```

### python-swiftclient (Native Swift)
```python
from swiftclient import Connection

conn = Connection(
    authurl='http://192.168.2.3:5000/v3',
    user='admin',
    key='your-password',
    tenant_name='admin',
    auth_version='3'
)

# List containers
containers = conn.get_account()[1]

# List objects
objects = conn.get_container('terraform-state')[1]

# Upload file
with open('file.txt', 'r') as f:
    conn.put_object('terraform-state', 'file.txt', contents=f)

# Download file
obj = conn.get_object('terraform-state', 'file.txt')
with open('local-file.txt', 'w') as f:
    f.write(obj[1])
```

## Recommended Tools

### For Terraform State Management
- **AWS CLI** - Best for Terraform backend operations
- **OpenStack Swift CLI** - Native Swift support

### For File Management
- **Cyberduck** (macOS) - Easy GUI, free
- **rclone** - Powerful CLI, sync capabilities
- **AWS CLI** - Simple and reliable

### For Development
- **boto3** (Python) - If writing scripts
- **python-swiftclient** - Native Swift API

## Quick Start Examples

### Using AWS CLI (Recommended for Terraform)
```bash
# Set credentials
export AWS_ACCESS_KEY_ID="admin"
export AWS_SECRET_ACCESS_KEY="your-password"

# List Terraform state files
aws --endpoint-url=https://iron.graphicsforge.net s3 ls s3://terraform-state/

# List specific state file
aws --endpoint-url=https://iron.graphicsforge.net s3 ls s3://terraform-state/vault/

# Download state file
aws --endpoint-url=https://iron.graphicsforge.net s3 cp s3://terraform-state/vault/terraform.tfstate ./vault-state-backup.tfstate
```

### Using Swift CLI (Native)
```bash
# List containers
swift list

# List objects in terraform-state container
swift list terraform-state

# List objects in vault subdirectory
swift list terraform-state --prefix vault/

# Download state file
swift download terraform-state vault/terraform.tfstate --output vault-state-backup.tfstate
```

## Troubleshooting

### Common Issues

1. **Path Style Required**
   - Swift requires path-style URLs: `https://iron.graphicsforge.net/bucket/object`
   - Not virtual-hosted: `https://bucket.iron.graphicsforge.net/object`
   - Most tools have a "Use Path Style" option

2. **HTTPS vs HTTP**
   - If using domain: `https://iron.graphicsforge.net`
   - If using IP: `http://192.168.2.3:8080`

3. **Region**
   - Swift doesn't use regions like AWS, but some tools require it
   - Use `us-east-1` as default

4. **Authentication**
   - Use OpenStack username/password
   - Not AWS access keys (unless configured in Swift)

## Security Notes

- Store credentials securely (use environment variables or credential files)
- Use HTTPS when possible
- Consider using Swift's built-in authentication tokens
- Don't commit credentials to version control
