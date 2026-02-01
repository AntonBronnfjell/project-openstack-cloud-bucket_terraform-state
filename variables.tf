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

# -----------------------------------------------------------------------------
# Terraform-managed Swift deployment (runs deploy on OpenStack host via SSH)
# Set swift_deploy_enabled = true and ensure SSH to the host works; then
# terraform apply will deploy Swift and then create the containers.
# -----------------------------------------------------------------------------

variable "swift_deploy_enabled" {
  description = "If true, run Swift deployment on swift_deploy_ssh_host before creating containers."
  type        = bool
  default     = true
}

variable "swift_deploy_ssh_host" {
  description = "OpenStack host to run Swift deploy on (e.g. 192.168.2.3)."
  type        = string
  default     = "192.168.2.3"
}

variable "swift_deploy_ssh_user" {
  description = "SSH user on swift_deploy_ssh_host."
  type        = string
  default     = "root"
}

variable "swift_deploy_ssh_private_key_path" {
  description = "Path to SSH private key for swift_deploy_ssh_host. Leave empty to use default SSH agent."
  type        = string
  default     = ""
  sensitive   = true
}

variable "swift_deploy_infra_repo" {
  description = "Git URL of the infra repo (for deploy-swift-on-host.sh)."
  type        = string
  default     = "https://github.com/AntonBronnfjell/tooling-openstack-infra-ansible_graphicsforge-infrastructure.git"
}

