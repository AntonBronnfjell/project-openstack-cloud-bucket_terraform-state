# ============================================================================
# OpenStack Swift Object Storage
# ============================================================================
# Uses OpenStack Swift (object storage) for Terraform state backend
# Swift is deployed on the OpenStack host (192.168.2.3) via Ansible
# This module creates Swift containers for storing Terraform state

# ============================================================================
# Swift Containers for Terraform State
# ============================================================================
# Creates OpenStack Object Storage (Swift) container(s) used by consumer
# repos for remote Terraform state. Depends on swift_deploy when enabled so
# that a single terraform apply deploys Swift then creates containers.

resource "openstack_objectstorage_container_v1" "state" {
  name     = var.container_name
  region   = var.region != "" ? var.region : null
  metadata = var.metadata
  # Note: If swift_deploy_enabled=true, containers will be created after Swift deployment
  # Otherwise, Swift should already be deployed on the OpenStack host
}

resource "openstack_objectstorage_container_v1" "archive" {
  count    = var.container_archive_name != "" ? 1 : 0
  name     = var.container_archive_name
  region   = var.region != "" ? var.region : null
  metadata = var.metadata
  # Note: If swift_deploy_enabled=true, containers will be created after Swift deployment
  # Otherwise, Swift should already be deployed on the OpenStack host
}
