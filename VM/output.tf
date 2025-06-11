output "public_ip_address" {
  value       = azurerm_public_ip.app01vm_pub_ip.ip_address
  description = "Public IP address of the VM"
}
