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
