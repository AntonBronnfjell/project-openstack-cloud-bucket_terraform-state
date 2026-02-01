# ============================================================================
# S3-compatible backend config for Terraform remote state (OpenStack Swift)
# ============================================================================
# Uses OpenStack Swift endpoint (S3-compatible API)
# Migrate: terraform init -backend-config=backend.s3.hcl -migrate-state

bucket                      = "terraform-state"
key                         = "bucket/terraform.tfstate"
region                      = "us-east-1"
endpoint                    = "https://iron.graphicsforge.net"
skip_credentials_validation = true
skip_metadata_api_check     = true
skip_requesting_account_id  = true
skip_region_validation      = true
force_path_style            = true
