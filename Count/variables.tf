variable "resource_group_name" {
  type    = string
  default = "App-VM-RG"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "number_vm" {
  type    = number
  default = 2
}

variable "tags" {
  type = map(string)
  default = {
    Owner        = "Outron"
    Organization = "Outron-ORG"
    Environment  = "Development"
  }
}

