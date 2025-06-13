variable "resource_group_name" {
  type    = string
  default = "App-VM-RG"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "disks" {
  type = map(object({
    lun   = number
    cache = string
    size  = number
  }))
  default = {
    disk_data = {
      lun   = 10
      cache = "ReadWrite"
      size  = 1
    }
    disk_log = {
      lun   = 11
      cache = "None"
      size  = 1
    }
  }
}

variable "tags" {
  type = map(string)
  default = {
    Owner       = "Outron"
    Organization = "Outron-ORG"
    Environment  = "Development"
  }
}
