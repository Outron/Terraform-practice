output "public_ip_addresses" {
  description = "List of public IP addresses for VMs"
  value       = [for ip in azurerm_public_ip.vm_ip : ip.ip_address]
}

output "admin_usernames" {
  description = "List of admin usernames"
  value       = [for vm in azurerm_windows_virtual_machine.vm : vm.admin_username]
}

output "admin_passwords" {
  description = "List of admin passwords (sensitive)"
  value       = [for vm in azurerm_windows_virtual_machine.vm : vm.admin_password]
  sensitive   = true
}
