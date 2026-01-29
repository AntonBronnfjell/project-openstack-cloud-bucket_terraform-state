# ============================================================================
# Swift Containers for Terraform State
# ============================================================================
# Creates OpenStack Object Storage (Swift) container(s) used by consumer
# repos for remote Terraform state. If the cloud exposes an S3-compatible API
# (e.g. Ceph RGW, Swift s3api), the same container is used as the S3 "bucket".

resource "openstack_objectstorage_container_v1" "state" {
  name     = var.container_name
  region   = var.region != "" ? var.region : null
  metadata = var.metadata
}

resource "openstack_objectstorage_container_v1" "archive" {
  count    = var.container_archive_name != "" ? 1 : 0
  name     = var.container_archive_name
  region   = var.region != "" ? var.region : null
  metadata = var.metadata
}
