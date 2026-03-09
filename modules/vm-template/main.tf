locals {
  image_datastore_id = coalesce(var.image_datastore_id, var.datastore_id)
  init_datastore_id  = coalesce(var.init_datastore_id, var.datastore_id)

  vendor_data_content = var.vendor_data_file != null ? file("${path.root}/${var.vendor_data_file}") : null

  user_data_content    = var.user_data_file != null ? file("${path.root}/${var.user_data_file}") : null
  meta_data_content    = var.meta_data_file != null ? file("${path.root}/${var.meta_data_file}") : null
  network_data_content = var.network_data_file != null ? file("${path.root}/${var.network_data_file}") : null
}

resource "proxmox_virtual_environment_file" "user_data" {
  count        = local.user_data_content != null ? 1 : 0
  node_name    = var.node_name
  datastore_id = local.init_datastore_id
  content_type = "snippets"

  source_raw {
    file_name = "${var.name}-user-data.yaml"
    data      = local.user_data_content
  }
}

resource "proxmox_virtual_environment_file" "vendor_data" {
  count        = local.vendor_data_content != null ? 1 : 0
  node_name    = var.node_name
  datastore_id = local.init_datastore_id
  content_type = "snippets"

  source_raw {
    file_name = "${var.name}-vendor-data.yaml"
    data      = local.vendor_data_content
  }
}

resource "proxmox_virtual_environment_file" "meta_data" {
  count        = local.meta_data_content != null ? 1 : 0
  node_name    = var.node_name
  datastore_id = local.init_datastore_id
  content_type = "snippets"

  source_raw {
    file_name = "${var.name}-meta-data.yaml"
    data      = local.meta_data_content
  }
}

resource "proxmox_virtual_environment_file" "network_data" {
  count        = local.network_data_content != null ? 1 : 0
  node_name    = var.node_name
  datastore_id = local.init_datastore_id
  content_type = "snippets"

  source_raw {
    file_name = "${var.name}-network-data.yaml"
    data      = local.network_data_content
  }
}

resource "proxmox_virtual_environment_download_file" "this" {
  content_type            = var.content_type
  datastore_id            = local.image_datastore_id
  node_name               = var.node_name
  overwrite               = var.overwrite
  verify                  = var.verify
  url                     = var.url
  decompression_algorithm = var.decompression_algorithm
  file_name               = var.file_name
}

resource "proxmox_virtual_environment_vm" "this" {
  started     = false
  on_boot     = false
  template    = true
  description = var.description

  vm_id     = var.vm_id
  name      = var.name
  node_name = var.node_name
  machine   = var.machine
  bios      = var.bios
  tags      = var.tags

  protection    = var.protection
  scsi_hardware = var.scsi_hardware
  boot_order    = [var.disk_info.interface]

  operating_system {
    type = var.operating_system.type
  }

  dynamic "vga" {
    for_each = var.vga != null ? [var.vga] : []
    content {
      type   = vga.value.type
      memory = vga.value.memory
    }
  }

  cpu {
    cores      = var.cpu.cores
    type       = var.cpu.type
    hotplugged = var.cpu.hotplugged
    limit      = var.cpu.limit
    numa       = var.cpu.numa
    sockets    = var.cpu.sockets
    units      = var.cpu.units
    affinity   = var.cpu.affinity
  }

  memory {
    dedicated      = var.memory.dedicated
    floating       = coalesce(var.memory.floating, var.memory.dedicated)
    shared         = var.memory.shared
    hugepages      = var.memory.hugepages
    keep_hugepages = var.memory.keep_hugepages
  }

  # cloud-init
  initialization {
    datastore_id = var.datastore_id

    user_data_file_id    = local.user_data_content != null ? proxmox_virtual_environment_file.user_data[0].id : null
    vendor_data_file_id  = local.vendor_data_content != null ? proxmox_virtual_environment_file.vendor_data[0].id : null
    meta_data_file_id    = local.meta_data_content != null ? proxmox_virtual_environment_file.meta_data[0].id : null
    network_data_file_id = local.network_data_content != null ? proxmox_virtual_environment_file.network_data[0].id : null

    dynamic "ip_config" {
      for_each = var.ip_configs
      content {
        dynamic "ipv4" {
          for_each = ip_config.value.ipv4 != null ? [ip_config.value.ipv4] : []
          content {
            address = ipv4.value.address
            gateway = ipv4.value.gateway
          }
        }
        dynamic "ipv6" {
          for_each = ip_config.value.ipv6 != null ? [ip_config.value.ipv6] : []
          content {
            address = ipv6.value.address
            gateway = ipv6.value.gateway
          }
        }
      }
    }

    dynamic "dns" {
      for_each = var.dns != null ? [var.dns] : []
      content {
        domain  = dns.value.domain
        servers = dns.value.servers
      }
    }

    dynamic "user_account" {
      for_each = var.user_account != null ? [var.user_account] : []
      content {
        username = user_account.value.username
        password = user_account.value.password
        keys     = user_account.value.keys
      }
    }
  }

  dynamic "network_device" {
    for_each = var.network_devices
    content {
      bridge      = network_device.value.bridge
      enabled     = network_device.value.enabled
      mac_address = network_device.value.mac_address
      model       = network_device.value.model
      mtu         = network_device.value.mtu
      rate_limit  = network_device.value.rate_limit
      vlan_id     = network_device.value.vlan_id
      firewall    = network_device.value.firewall
    }
  }

  dynamic "hostpci" {
    for_each = var.hostpci_devices
    content {
      device   = hostpci.value.device
      mapping  = hostpci.value.mapping
      pcie     = hostpci.value.pcie
      mdev     = hostpci.value.mdev
      rombar   = hostpci.value.rombar
      rom_file = hostpci.value.rom_file
      xvga     = hostpci.value.xvga
    }
  }

  dynamic "serial_device" {
    for_each = var.serial_devices
    content {
      device = serial_device.value.device
    }
  }

  efi_disk {
    datastore_id      = var.datastore_id
    type              = var.efi_disk_info.type
    pre_enrolled_keys = var.efi_disk_info.pre_enrolled_keys
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = var.content_type != "iso" ? proxmox_virtual_environment_download_file.this.id : null
    import_from  = var.content_type == "iso" ? proxmox_virtual_environment_download_file.this.id : null
    size         = var.disk_size
    interface    = var.disk_info.interface
    iothread     = var.disk_info.iothread
    discard      = var.disk_info.discard
    backup       = var.disk_info.backup
    cache        = var.disk_info.cache
    aio          = var.disk_info.aio
    ssd          = var.disk_info.ssd
  }

  agent {
    enabled = var.agent.enabled
    timeout = var.agent.timeout
    trim    = var.agent.trim
    type    = var.agent.type
  }
}
