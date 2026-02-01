# ============================================================================
# OpenStack Provider - Terraform State Bucket Leaf
# ============================================================================
# Auth via environment: OS_CLOUD (clouds.yaml) or OS_AUTH_URL, OS_USERNAME,
# OS_PASSWORD, OS_TENANT_NAME, OS_REGION_NAME.

terraform {
  required_version = ">= 1.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # Backend: s3 (OpenStack Swift S3-compatible bucket). Config via -backend-config=backend.s3.hcl
  # See backend.s3.hcl for configuration details.
  backend "s3" {}
}

provider "openstack" {
  # Uses OS_* env vars or OS_CLOUD (clouds.yaml)
}

provider "null" {}
