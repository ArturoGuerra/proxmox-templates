# Proxmox VM Template Automation

This project automates the creation of Proxmox VM templates using Terraform and a simple YAML-based configuration. It allows you to define VM templates as code, automatically download cloud images, and configure them with Cloud-Init.

## Project Structure

- `templates/`: Directory containing YAML configuration files for each VM template.
- `modules/vm-template/`: The reusable Terraform module that defines the VM resources.
- `main.tf`: The main Terraform entry point that reads YAML files and calls the module.
- `variables.tf`: Global default variables.
- `providers.tf`: Proxmox provider configuration.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0 installed.
- Access to a Proxmox VE cluster.
- A Proxmox API Token with sufficient permissions to create VMs and download files.
- SSH access to the Proxmox node (required when using local datastores).

## Setup & Configuration

### 1. Clone the Repository

```bash
git clone <repository-url>
cd proxmox-templates
```

### 2. Configure Authentication (using `.env`)

Create a `.env` file in the root of the project to store your sensitive Proxmox credentials. This file is ignored by git to keep your secrets safe.

**Example `.env` file content:**

```bash
# API authentication
export PROXMOX_VE_ENDPOINT="https://pve.example.com:8006/"
export PROXMOX_VE_API_TOKEN="root@pam!tokenid=secret-uuid-here"  # preferred
# export PROXMOX_VE_USERNAME="root@pam"    # alternative to API token
# export PROXMOX_VE_PASSWORD="..."
# export PROXMOX_VE_INSECURE=true          # uncomment for self-signed certificates

# SSH authentication (required for local datastore operations)
export PROXMOX_VE_SSH_USERNAME="root"
export PROXMOX_VE_SSH_AGENT=true           # uses your ssh-agent (recommended)
# export PROXMOX_VE_SSH_PRIVATE_KEY="$(cat ~/.ssh/id_ed25519)"  # alternative to agent
```

> **Note on SSH:** The provider uses SSH for operations the Proxmox API cannot perform, such as uploading files to local storage (e.g. `local`, `local-lvm`). If your templates use a local datastore, SSH credentials are required in addition to the API token.

To load these variables into your current shell session, run:

```bash
source .env
```

### 3. Initialize Terraform

Run the following command to download the necessary providers and modules:

```bash
terraform init
```

## Creating VM Templates

To create a new VM template, simply add a `.yaml` file to the `templates/` directory. The filename is used for sorting to assign deterministic VM IDs (starting from 10000).

**Example: `templates/ubuntu-22.04.yaml`**

```yaml
# --- Identification ---
name: "ubuntu-22.04-cloud-template"
description: "Ubuntu 22.04 LTS Cloud Image Template"
tags: ["template", "ubuntu", "22.04"]

# --- Location ---
# Optional: defaults to var.proxmox_node and var.datastore_id if not set
# node_name: "pve"
# datastore_id: "local-lvm"

# --- Source Image ---
url: "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
file_name: "ubuntu-22.04-cloudimg.img"

# --- Hardware ---
cpu:
  cores: 2
  type: "x86-64-v2-AES"
memory:
  dedicated: 2048
disk_size: 10 # Expand disk to 10GB

# --- Cloud-Init ---
user_account:
  username: "ubuntu"
  password: "password" # Ideally, use SSH keys
  keys: 
    - "ssh-ed25519 AAA..."

ip_configs:
  - ipv4:
      address: "dhcp"

# --- Network ---
network_devices:
  - bridge: "vmbr0"
    model: "virtio"
```

### Key Features
- **Auto-ID**: IDs are automatically assigned starting from `10000` based on the file order. You can override this by setting `vm_id: 10050` in the YAML.
- **Cloud-Init**: Configures users, SSH keys, and network settings automatically.
- **PCI Passthrough**: Supports passing through host PCI devices via the `hostpci_devices` list.

## Deployment

Once you have added your templates:

1.  **Plan**: Preview the changes Terraform will make.
    ```bash
    terraform plan
    ```

2.  **Apply**: Create the VM templates in Proxmox.
    ```bash
    terraform apply
    ```

## Customizing Defaults

You can override global defaults (like the default node name or datastore) in `variables.tf` or by creating a `terraform.tfvars` file:

```hcl
proxmox_node = "pve-01"
datastore_id = "ceph-storage"
```
