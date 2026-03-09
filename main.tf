locals {
  yaml_files = fileset("${path.module}/templates", "*.yaml")

  templates = {
    for f in local.yaml_files :
    replace(basename(f), ".yaml", "") => yamldecode(file("${path.module}/templates/${f}"))
  }
}

module "vm_templates" {
  source = "./modules/vm-template"

  for_each = local.templates

  # --- Core Identification ---
  vm_id       = each.value.vm_id
  name        = try(each.value.name, each.key)
  description = try(each.value.description, "Managed by Terraform")
  tags        = try(each.value.tags, [])

  node_name    = try(each.value.node_name, var.proxmox_node)
  datastore_id = try(each.value.datastore_id, var.datastore_id)

  # --- Download File ---
  url                     = each.value.url
  file_name               = try(each.value.file_name, null)
  content_type            = each.value.content_type
  overwrite               = try(each.value.overwrite, true)
  verify                  = try(each.value.verify, true)
  decompression_algorithm = try(each.value.decompression_algorithm, null)

  # --- Hardware ---
  machine       = try(each.value.machine, "q35")
  bios          = try(each.value.bios, "ovmf")
  scsi_hardware = try(each.value.scsi_hardware, "virtio-scsi-single")
  protection    = try(each.value.protection, false)

  cpu = try(each.value.cpu, {
    cores = 2
    type  = "x86-64-v2-AES"
  })

  memory = try(each.value.memory, {
    dedicated = 2048
  })

  # --- OS / Display ---
  operating_system = try(each.value.operating_system, {
    type = "l26"
  })

  vga = try(each.value.vga, {
    type   = "serial0"
    memory = 16
  })

  # --- Devices ---
  network_devices = try(each.value.network_devices, [])
  serial_devices  = try(each.value.serial_devices, [])
  hostpci_devices = try(each.value.hostpci_devices, [])

  # --- Disk ---
  disk_info     = try(each.value.disk_info, {
    interface = "scsi0"
    iothread  = true
    discard   = "on"
    ssd       = true
  })
  disk_size     = try(each.value.disk_size, null)
  efi_disk_info = try(each.value.efi_disk_info, {
    type              = "4m"
    pre_enrolled_keys = true
  })

  # --- Cloud-Init ---
  ip_configs   = try(each.value.ip_configs, [])
  dns          = try(each.value.dns, null)
  user_account = try(each.value.user_account, null)

  # --- Agent ---
  agent = try(each.value.agent, {
    enabled = true
    trim    = true
    type    = "virtio"
  })
}

output "created_templates" {
  description = "Map of created VM Templates"
  value = {
    for k, v in module.vm_templates : k => v.vm_id
  }
}
