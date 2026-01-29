# ============================================================================
# Variables - Terraform State Bucket Leaf
# ============================================================================

variable "container_name" {
  description = "Swift container name for Terraform state."
  type        = string
  default     = "terraform-state"
}

variable "container_archive_name" {
  description = "Optional Swift container for state archive/versioning."
  type        = string
  default     = ""
}

variable "region" {
  description = "OpenStack region for object storage."
  type        = string
  default     = ""
}

variable "metadata" {
  description = "Optional metadata key/value for the state container."
  type        = map(string)
  default     = {}
}
