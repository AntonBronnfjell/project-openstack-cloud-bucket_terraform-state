# Terraform State Bucket (OpenStack Swift)

This repository contains a minimal Terraform **leaf** that creates OpenStack Object Storage (Swift) container(s) used for Terraform remote state by other repos (traefik orchestration, openstack-infra, vault).

## What it creates

- **Swift container** for Terraform state (default name: `terraform-state`).
- **Optional** second container for state archive/versioning (e.g. `terraform-state-archive`).

No S3-specific resources are created here. If your OpenStack cloud exposes an S3-compatible API (e.g. Ceph RGW, Swift s3api), you use the same container as the S3 "bucket" and configure the S3 backend in consumer repos.

## Requirements

- **Terraform-managed Swift:** If Swift is not yet on your OpenStack cloud, set `swift_deploy_enabled = true` and ensure **SSH key access** to the OpenStack host (default `root@192.168.2.3`). One `terraform apply` will deploy Swift on that host via SSH, then create the containers.
- If Swift is already deployed, set `swift_deploy_enabled = false` and run `terraform apply` to only create the containers.
- Terraform >= 1.0, [terraform-provider-openstack](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest) ~> 1.54, and [null](https://registry.terraform.io/providers/hashicorp/null/latest) ~> 3.0.
- Auth: `OS_CLOUD` (and `clouds.yaml`) or `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_TENANT_NAME`, `OS_REGION_NAME`.

## Deploy the bucket (one-time)

From a machine where **SSH to the OpenStack host works** (e.g. `ssh root@192.168.2.3`):

1. **Set up SSH** (if not already):
   ```bash
   ssh-copy-id root@192.168.2.3
   ```
   Or use a key file and set `swift_deploy_ssh_private_key_path` in `terraform.tfvars`.

2. **Apply** (deploys Swift on 192.168.2.3, then creates the containers):
   ```bash
   cd project-openstack-cloud-bucket_terraform-state
   terraform init && terraform apply -auto-approve
   ```

That’s it. No separate shell scripts; one `terraform apply` until the bucket is deployed.

## Usage (Terraform-managed)

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and set `container_name`, optional `container_archive_name`, `region`, and Swift deploy vars (`swift_deploy_ssh_host` = `192.168.2.3`, `swift_deploy_ssh_user`, optional `swift_deploy_ssh_private_key_path`).
2. Ensure **SSH to the OpenStack host** works (e.g. `ssh root@192.168.2.3`). If using a key, set `swift_deploy_ssh_private_key_path` in `terraform.tfvars`.
3. Ensure OpenStack env vars (or `OS_CLOUD`) are set for the provider.
4. Run `terraform init` then `terraform apply`.

With `swift_deploy_enabled = true`, Terraform runs the Swift deployment on the host (clone infra repo, bootstrap Ansible, `os-swift-install.yml`), then creates the Swift containers.

This repo’s own state is **local** by default (e.g. `terraform.tfstate` in the repo, ignored by `.gitignore`). You can later move it to the same Swift container (e.g. key `bucket-repo/terraform.tfstate`) once the backend is configured.

## Consuming this bucket from other repos

- **S3-compatible API (Terraform):** Use the `s3` backend with `bucket` = container name, plus `endpoint`, `region`, and credentials from Vault (see `terraform-state/credentials/*` in [VAULT_SECRETS.md](https://github.com/AntonBronnfjell/project-traefik-container-yaml_domain-reverse-proxy/blob/main/docs/VAULT_SECRETS.md) in the traefik repo).
- **Swift (OpenTofu):** Use the [Swift backend](https://developer.hashicorp.com/terraform/language/settings/backends/swift) with the same container name and OpenStack env vars (or from Vault).

See each consumer repo’s README or QUICKSTART for:
- One-time bucket creation (this repo),
- Vault secrets for the state backend,
- Per-repo `terraform init -backend-config=...`.

## Outputs

- `container_name` – State container name for backend config.
- `container_archive_name` – Archive container name (if created).
- `region` – Region of the container(s).
- `object_store_endpoint_note` – Reminder to set endpoint from OS catalog or `S3_ENDPOINT` in consumer backends.
