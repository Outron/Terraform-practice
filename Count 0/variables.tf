variable "webapp_create" {
  description = "Whether to create the Web App"
  type        = bool
  default     = true
}

variable "webapp_rg" {
  description = "Name of the Resource Group for Web App"
  type        = string
  default     = "webapp_rg"
}

variable "webapp_name" {
  description = "Name of the Web App (must be globally unique)"
  type        = string
  default     = "demowebapp987654"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus2"
}
