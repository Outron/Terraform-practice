output "webapp_url" {
  value       = azurerm_linux_web_app.webapp[0].default_hostname
  description = "URL of the Web App"
}
