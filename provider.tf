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
  }

  # This repo's state stays local initially. Optionally migrate to the same
  # container (e.g. key = "bucket-repo/terraform.tfstate") after backend is set.
  backend "local" {}
}

provider "openstack" {
  # Uses OS_* env vars or OS_CLOUD (clouds.yaml)
}
