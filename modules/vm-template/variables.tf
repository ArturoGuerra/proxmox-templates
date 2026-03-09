variable "node_name" {
  description = "The name of the Proxmox node"
  type        = string
}

variable "datastore_id" {
  description = "The ID of the datastore"
  type        = string
}

variable "vm_id" {
  description = "The ID of the VM"
  type        = number
}

variable "name" {
  description = "The name of the VM"
  type        = string
}

variable "description" {
  description = "Description of the VM"
  type        = string
  default     = "Managed by Terraform"
}

variable "tags" {
  description = "Tags for the VM"
  type        = list(string)
  default     = []
}

# --- Download File ---

variable "content_type" {
  description = "Content type for the downloaded file (e.g., 'iso', 'vztmpl')"
  type        = string
  validation {
    condition     = contains(["iso", "import", "vztmpl", "backup", "snippets"], var.content_type)
    error_message = "Content type must be one of: iso, import, vztmpl, backup, snippets."
  }
}

variable "url" {
  description = "URL to download the file from"
  type        = string
}

variable "file_name" {
  description = "Name of the downloaded file"
  type        = string
  default     = null
  nullable    = true
}

variable "overwrite" {
  description = "Whether to overwrite the file if it exists"
  type        = bool
  default     = true
}

variable "verify" {
  description = "Whether to verify the SSL certificate when downloading the file"
  type        = bool
  default     = true
}

variable "decompression_algorithm" {
  description = "Algorithm to use for decompression. Leave null for uncompressed files."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition     = var.decompression_algorithm == null || contains(["bz2", "gz", "lzma", "lzo", "zstd"], var.decompression_algorithm)
    error_message = "Decompression algorithm must be one of: bz2, gz, lzma, lzo, zstd."
  }
}

# --- VM Configuration ---

variable "machine" {
  description = "Machine type"
  type        = string
  default     = "q35"
  validation {
    condition     = contains(["q35", "pc", "i440fx"], var.machine)
    error_message = "Machine must be one of: q35, pc, i440fx."
  }
}

variable "bios" {
  description = "BIOS type"
  type        = string
  default     = "ovmf"
  validation {
    condition     = contains(["ovmf", "seabios"], var.bios)
    error_message = "BIOS must be one of: ovmf, seabios."
  }
}

variable "operating_system" {
  description = "Operating system type (e.g., l26, win11)"
  type = object({
    type = string
  })
  default = {
    type = "l26" # Linux 2.6 - 6.x Kernel
  }
  validation {
    condition     = contains(["l26", "l24", "win11", "win10", "other", "solaris"], var.operating_system.type)
    error_message = "Operating system type must be one of: l26, l24, win11, win10, other, solaris."
  }
}

variable "vga" {
  description = "Display/VGA configuration"
  type = object({
    type   = optional(string)
    memory = optional(number)
  })
  default = {
    type   = "serial0" # Default to serial for cloud-images
    memory = 16
  }
}

variable "protection" {
  description = "Enable protection against removal"
  type        = bool
  default     = false
}

variable "scsi_hardware" {
  description = "SCSI hardware type"
  type        = string
  default     = "virtio-scsi-single"
}

variable "cpu" {
  description = "CPU configuration"
  type = object({
    cores      = number
    type       = string
    hotplugged = optional(number)
    limit      = optional(number)
    numa       = optional(bool)
    sockets    = optional(number)
    units      = optional(number, 100)
    affinity   = optional(string)
  })
  default = {
    cores = 2
    type  = "x86-64-v2-AES"
  }
}

variable "memory" {
  description = "Memory configuration"
  type = object({
    dedicated      = number
    floating       = optional(number)
    shared         = optional(number)
    hugepages      = optional(string)
    keep_hugepages = optional(bool)
  })
  default = {
    dedicated = 2048
  }
}

variable "network_devices" {
  description = "List of network devices"
  type = list(object({
    bridge      = string
    enabled     = optional(bool)
    mac_address = optional(string)
    model       = optional(string)
    mtu         = optional(number)
    rate_limit  = optional(number)
    vlan_id     = optional(number)
    firewall    = optional(bool)
  }))
  default = []
}

variable "serial_devices" {
  description = "List of serial devices"
  type = list(object({
    device = optional(string)
  }))
  default = []
}

variable "hostpci_devices" {
  description = "List of Host PCI devices to pass through using resource mapping"
  type = list(object({
    device   = string           # The PCI slot name in Proxmox (e.g., hostpci0, hostpci1)
    mapping  = string           # The resource mapping name in Proxmox
    pcie     = optional(bool)   # Enable PCIe (default: true for mapped devices usually)
    mdev     = optional(string) # Mediated device type (e.g., nvidia-222)
    rombar   = optional(bool)   # Visibility of ROM bar
    rom_file = optional(string) # Custom ROM file path
    xvga     = optional(bool)   # Use as primary GPU
  }))
  default = []
}

# --- Cloud-Init ---

variable "ip_configs" {
  description = "List of IP configurations for cloud-init"
  type = list(object({
    ipv4 = optional(object({
      address = string
      gateway = optional(string)
    }))
    ipv6 = optional(object({
      address = string
      gateway = optional(string)
    }))
  }))
  default = []
}

variable "dns" {
  description = "DNS configuration for cloud-init"
  type = object({
    domain  = optional(string)
    servers = optional(list(string))
  })
  default = null
}

variable "user_account" {
  description = "Cloud-init user account configuration"
  type = object({
    username = optional(string)
    password = optional(string)
    keys     = optional(list(string))
  })
  default = null
}

# --- Disk Configuration ---

variable "efi_disk_info" {
  description = "EFI Disk configuration"
  type = object({
    type              = string
    pre_enrolled_keys = optional(bool)
  })
  default = {
    type              = "4m"
    pre_enrolled_keys = false
  }
  validation {
    condition     = contains(["4m", "2m"], var.efi_disk_info.type)
    error_message = "EFI disk type must be one of: 4m, 2m."
  }
}

variable "disk_size" {
  description = "Size of the disk in GB. If specified, must be larger than the source image."
  type        = number
  default     = null
  nullable    = true
}

variable "disk_info" {
  description = "Disk configuration"
  type = object({
    interface = string
    iothread  = optional(bool)
    discard   = optional(string)
    backup    = optional(bool)
    cache     = optional(string)
    aio       = optional(string)
    ssd       = optional(bool)
  })
  default = {
    interface = "scsi0"
    iothread  = true
    discard   = "on"
    ssd       = true
  }
}

# --- Agent ---

variable "agent" {
  description = "QEMU Guest Agent configuration"
  type = object({
    enabled = bool
    timeout = optional(string)
    trim    = optional(bool)
    type    = optional(string)
    wait_for_ip = optional(object({
      ipv6 = optional(bool)
      ipv4 = optional(bool)
    }))
  })
  default = {
    enabled = true
    trim    = true
    type    = "virtio"
  }
}
