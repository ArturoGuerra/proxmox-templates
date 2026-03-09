output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "id" {
  description = "The ID of the VM resource"
  value       = proxmox_virtual_environment_vm.this.id
}
