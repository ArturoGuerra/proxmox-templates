# Global Defaults
# These can be overridden by environment variables (TF_VAR_...) or a .tfvars file

variable "proxmox_node" {
  description = "Default Proxmox node name if not specified in template"
  type        = string
  default     = "pve"
}

variable "datastore_id" {
  description = "Default datastore ID (e.g., local-lvm, ceph)"
  type        = string
  default     = "local-lvm"
}

variable "vm_passwords" {
  description = "Map of template key to cloud-init user password. Keys match template filenames without .yaml (e.g. ubuntu-24.04-lts). Never commit values — use secrets.auto.tfvars."
  type        = map(string)
  default     = {}
  sensitive   = true
}
