# VM Templates

This directory is where you should place your VM template definition files (`.yaml`).
All `.yaml` files in this directory are ignored by Git to prevent committing sensitive or local-specific configurations.

## Example Template

Create a file (e.g., `ubuntu-22.04.yaml`) with the following structure:

```yaml
# VM Template Configuration

# --- Identification ---
name: "ubuntu-22.04-cloud-template"
description: "Ubuntu 22.04 LTS Cloud Image Template (Created via Terraform)"
tags: ["template", "ubuntu", "22.04", "cloud"]
node_name: "pve"      # CHANGE THIS to your Proxmox node name
datastore_id: "local" # CHANGE THIS to your storage ID (e.g., local-lvm, ceph)

# --- Source Image ---
# Cloud image URL
url: "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
file_name: "ubuntu-22.04-cloudimg.img"
content_type: "img"             # Required: iso, vztmpl, backup, snippets

# --- Hardware ---
machine: "q35" # Required: q35, pc, i440fx
bios: "ovmf"   # Required: ovmf, seabios

cpu:
  cores: 2
  type: "x86-64-v2-AES"
memory:
  dedicated: 2048
disk_size: 10 # Expand the root disk to 10GB
disk_info:
  interface: "scsi0"
  ssd: true
  discard: "on"
  iothread: true

# --- Cloud-Init ---
user_account:
  username: "ubuntu"
  password: "password" # Ideally use SSH keys below
  # keys: ["ssh-ed25519 AAA..."] 

ip_configs:
  - ipv4:
      address: "dhcp"

# --- Network ---
network_devices:
  - bridge: "Server"
    model: "virtio"
    firewall: false

# --- OS Type ---
operating_system:
  type: "l26" # Linux 2.6+

# --- Serial Console (for cloud images) ---
serial_devices:
  - device: "socket"
vga:
  type: "serial0"
```
