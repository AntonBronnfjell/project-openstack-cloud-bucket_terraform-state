# Terraform State Bucket (OpenStack Swift)

This repository contains a minimal Terraform **leaf** that creates OpenStack Object Storage (Swift) container(s) used for Terraform remote state by other repos (traefik orchestration, openstack-infra, vault).

## What it creates

- **Swift container** for Terraform state (default name: `terraform-state`).
- **Optional** second container for state archive/versioning (e.g. `terraform-state-archive`).

No S3-specific resources are created here. If your OpenStack cloud exposes an S3-compatible API (e.g. Ceph RGW, Swift s3api), you use the same container as the S3 "bucket" and configure the S3 backend in consumer repos.

## Requirements

- OpenStack with **Object Storage (Swift) enabled**. If you see *"No suitable endpoint could be found in the service catalog"* when applying, Swift is not enabled on your cloud.
  - For OpenStack-Ansible (e.g. `tooling-openstack-infra-ansible_graphicsforge-infrastructure`): set `swift_enabled: true` in `etc/openstack_deploy/user_variables.yml` and run the playbooks to deploy Swift, then run this repo’s `terraform apply` again.
- Terraform >= 1.0 and [terraform-provider-openstack](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest) ~> 1.54.
- Auth: `OS_CLOUD` (and `clouds.yaml`) or `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_TENANT_NAME`, `OS_REGION_NAME`.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and set `container_name`, optional `container_archive_name`, and `region`.
2. Ensure OpenStack env vars (or `OS_CLOUD`) are set.
3. Run:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

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
