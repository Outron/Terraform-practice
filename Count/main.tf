terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  vm_name_prefix      = "appvm"
  nic_name_suffix     = "-nic"
  ip_name_suffix      = "_ip"
  admin_username_base = "adminuser"
  admin_password      = "pass"
}

resource "azurerm_resource_group" "main_rg" {
  name     = local.resource_group_name
  location = local.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main_vnet" {
  name                = "App_VNET"
  address_space       = ["10.1.0.0/16"]
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "dev_subnet" {
  name                 = "dev_subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "tst_subnet" {
  name                 = "tst_subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_public_ip" "vm_ip" {
  count               = var.number_vm
  name                = "${local.vm_name_prefix}${count.index}${local.ip_name_suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_nic" {
  count               = var.number_vm
  name                = "${local.vm_name_prefix}${count.index}${local.nic_name_suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.dev_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip[count.index].id
  }
}

resource "azurerm_network_security_group" "nsg_rdp" {
  name                = "app01vm-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = var.number_vm
  network_interface_id      = azurerm_network_interface.vm_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_rdp.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.number_vm
  name                = "${local.vm_name_prefix}${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_B2s"
  admin_username      = "${local.admin_username_base}${count.index}"
  admin_password      = local.admin_password

  network_interface_ids = [
    azurerm_network_interface.vm_nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-ent"
    version   = "latest"
  }

  tags = var.tags
}
