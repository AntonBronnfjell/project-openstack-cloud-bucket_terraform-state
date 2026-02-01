#!/bin/bash
# Simple Swift Helper Script
# Makes Swift operations easier with simple commands

SWIFT_ENDPOINT="https://iron.graphicsforge.net"
BUCKET="terraform-state"

# Set your credentials here or export them
# export AWS_ACCESS_KEY_ID="admin"
# export AWS_SECRET_ACCESS_KEY="your-password"

case "$1" in
  list)
    echo "📁 Listing containers..."
    aws --endpoint-url=$SWIFT_ENDPOINT s3 ls
    ;;
  ls)
    if [ -z "$2" ]; then
      echo "📁 Listing files in $BUCKET..."
      aws --endpoint-url=$SWIFT_ENDPOINT s3 ls s3://$BUCKET/
    else
      echo "📁 Listing files in $BUCKET/$2..."
      aws --endpoint-url=$SWIFT_ENDPOINT s3 ls s3://$BUCKET/$2/
    fi
    ;;
  upload)
    if [ -z "$2" ] || [ -z "$3" ]; then
      echo "Usage: $0 upload <local-file> [remote-path]"
      exit 1
    fi
    REMOTE_PATH=${3:-$(basename $2)}
    echo "⬆️  Uploading $2 to s3://$BUCKET/$REMOTE_PATH..."
    aws --endpoint-url=$SWIFT_ENDPOINT s3 cp "$2" s3://$BUCKET/$REMOTE_PATH
    ;;
  download)
    if [ -z "$2" ]; then
      echo "Usage: $0 download <remote-file> [local-file]"
      exit 1
    fi
    LOCAL_FILE=${3:-$(basename $2)}
    echo "⬇️  Downloading s3://$BUCKET/$2 to $LOCAL_FILE..."
    aws --endpoint-url=$SWIFT_ENDPOINT s3 cp s3://$BUCKET/$2 "$LOCAL_FILE"
    ;;
  delete)
    if [ -z "$2" ]; then
      echo "Usage: $0 delete <remote-file>"
      exit 1
    fi
    echo "🗑️  Deleting s3://$BUCKET/$2..."
    aws --endpoint-url=$SWIFT_ENDPOINT s3 rm s3://$BUCKET/$2
    ;;
  *)
    echo "Swift Helper - Simple Swift/S3 operations"
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  list                    - List all containers"
    echo "  ls [path]               - List files (default: root)"
    echo "  upload <file> [path]    - Upload file"
    echo "  download <file> [path]  - Download file"
    echo "  delete <file>           - Delete file"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 ls"
    echo "  $0 ls vault/"
    echo "  $0 upload file.txt"
    echo "  $0 upload file.txt vault/file.txt"
    echo "  $0 download vault/terraform.tfstate"
    echo "  $0 delete vault/old-file.txt"
    ;;
esac
