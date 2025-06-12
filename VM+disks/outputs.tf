output "public_ip_address" {
  value       = azurerm_public_ip.app01vm_pub_ip.ip_address
  description = "The public IP address of the virtual machine"
}

output "data_disk_ids" {
  value       = [for d in azurerm_managed_disk.data_disks : d.id]
  description = "IDs of the attached managed data disks"
}
