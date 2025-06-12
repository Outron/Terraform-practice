variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "App-VM-RG"
}

variable "location" {
  description = "Azure region"
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  default     = "App_VNET"
}

variable "vnet_address_space" {
  description = "Address space for the VNET"
  default     = "10.1.0.0/16"
}

variable "dev_subnet_prefix" {
  default = "10.1.1.0/24"
}

variable "tst_subnet_prefix" {
  default = "10.1.2.0/24"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "admin_username" {
  default = "adminuser"
}

variable "admin_password" {
  description = "Password for the admin user"
  default     = "xxxxx"
  sensitive   = true
}

variable "disk_names" {
  type    = list(string)
  default = ["disk_data", "disk_log"]
}

variable "disk_lunes" {
  type    = list(number)
  default = [10, 11]
}

variable "disk_caches" {
  type    = list(string)
  default = ["ReadWrite", "None"]
}

variable "tags" {
  type = map(string)
  default = {
    Owner        = "Outron"
    Organization = "Outron-ORG"
    Environment  = "Development"
  }
}
