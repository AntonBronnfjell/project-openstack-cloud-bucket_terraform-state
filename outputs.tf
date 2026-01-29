# ============================================================================
# Outputs - Terraform State Bucket Leaf
# ============================================================================

output "container_name" {
  description = "Swift container name for Terraform state."
  value       = openstack_objectstorage_container_v1.state.name
}

output "container_archive_name" {
  description = "Swift container name for state archive (if created)."
  value       = length(openstack_objectstorage_container_v1.archive) > 0 ? openstack_objectstorage_container_v1.archive[0].name : null
}

output "region" {
  description = "Region where the container(s) were created."
  value       = openstack_objectstorage_container_v1.state.region
}

# Object-store endpoint URL for consumer backend config (S3 or Swift).
# Consumer repos may get this from OpenStack service catalog or env; leave as optional doc.
output "object_store_endpoint_note" {
  description = "For S3 backend: use your cloud's S3-compatible endpoint (e.g. from openstack catalog show object-store). For Swift (OpenTofu): use OS_* env vars."
  value       = "Configure consumer backend with container name above; endpoint from OS catalog or S3_ENDPOINT."
}
