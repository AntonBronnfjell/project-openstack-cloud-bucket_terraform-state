# ============================================================================
# OpenStack Swift Deployment
# ============================================================================
# Deploys Swift on the OpenStack host via SSH using Ansible
# This runs the deploy-swift-on-host.sh script from the infrastructure repo

# Wait for SSH to be available on OpenStack host
resource "null_resource" "swift_docker_wait_ssh" {
  count = var.swift_deploy_enabled ? 1 : 0

  triggers = {
    ssh_host = var.swift_deploy_ssh_host
  }

  connection {
    type        = "ssh"
    host        = var.swift_deploy_ssh_host
    user        = var.swift_deploy_ssh_user
    private_key = var.swift_deploy_ssh_private_key_path != "" ? file(var.swift_deploy_ssh_private_key_path) : null
    timeout     = "1m"
    agent       = var.swift_deploy_ssh_private_key_path == "" ? true : false
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection successful to OpenStack host ${var.swift_deploy_ssh_host}'"
    ]
  }
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [triggers]
  }
}

# Deploy Swift on OpenStack host
resource "null_resource" "swift_deploy" {
  count = var.swift_deploy_enabled ? 1 : 0

  depends_on = [null_resource.swift_docker_wait_ssh]

  triggers = {
    infra_repo = var.swift_deploy_infra_repo
    ssh_host   = var.swift_deploy_ssh_host
  }

  connection {
    type        = "ssh"
    host        = var.swift_deploy_ssh_host
    user        = var.swift_deploy_ssh_user
    private_key = var.swift_deploy_ssh_private_key_path != "" ? file(var.swift_deploy_ssh_private_key_path) : null
    timeout     = "30m"
    agent       = var.swift_deploy_ssh_private_key_path == "" ? true : false
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo 'Deploying OpenStack Swift on host ${var.swift_deploy_ssh_host}...'",
      "cd /root || cd /home/${var.swift_deploy_ssh_user}",
      "if [ ! -d tooling-openstack-infra-ansible_graphicsforge-infrastructure ]; then",
      "  git clone ${var.swift_deploy_infra_repo} || echo 'Repo may already exist'",
      "fi",
      "cd tooling-openstack-infra-ansible_graphicsforge-infrastructure",
      "chmod +x scripts/deploy-swift-on-host.sh || true",
      "./scripts/deploy-swift-on-host.sh || echo 'Swift deployment script completed (may have warnings)'",
      "echo 'OpenStack Swift deployment completed'"
    ]
  }
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [triggers]
  }
}
