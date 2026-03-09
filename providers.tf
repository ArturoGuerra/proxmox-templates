terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.97"
    }
  }
}

provider "proxmox" {
  # API authentication — configure via environment variables:
  # PROXMOX_VE_ENDPOINT   e.g. "https://pve.example.com:8006/"
  # PROXMOX_VE_API_TOKEN  e.g. "user@pam!tokenid=secret-uuid"  (preferred)
  # PROXMOX_VE_USERNAME   e.g. "root@pam"                      (alternative to token)
  # PROXMOX_VE_PASSWORD                                         (used with username)
  # PROXMOX_VE_INSECURE=true  # uncomment equivalent if using self-signed certs

  # SSH authentication — required for local datastore operations (e.g. uploading files):
  # PROXMOX_VE_SSH_USERNAME
  # PROXMOX_VE_SSH_AGENT=true     (recommended — uses your ssh-agent)
  # PROXMOX_VE_SSH_PRIVATE_KEY    (alternative to agent)
  # PROXMOX_VE_SSH_PASSWORD       (alternative to key)

  # Or configure SSH inline:
  # ssh {
  #   agent    = true
  #   username = "root"
  # }
}
