# ============================================================================
# Outputs - Terraform State Bucket Leaf
# ============================================================================

output "object_store_endpoint_note" {
  description = "Note about Swift endpoint configuration"
  value       = "Configure consumer backend with container name above; endpoint from OS catalog or S3_ENDPOINT."
}

output "region" {
  description = "OpenStack region for object storage"
  value       = var.region != "" ? var.region : "RegionOne"
}

output "container_name" {
  description = "Name of the state container"
  value       = openstack_objectstorage_container_v1.state.name
}

output "container_archive_name" {
  description = "Name of the archive container (if created)"
  value       = var.container_archive_name != "" ? openstack_objectstorage_container_v1.archive[0].name : ""
}
