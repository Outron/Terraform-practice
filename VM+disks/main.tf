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

resource "azurerm_resource_group" "main_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main_vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "dev_subnet" {
  name                 = "dev_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.dev_subnet_prefix]
}

resource "azurerm_subnet" "tst_subnet" {
  name                 = "tst_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.tst_subnet_prefix]
}

resource "azurerm_public_ip" "app01vm_pub_ip" {
  name                = "app01vm_ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  tags                = var.tags
}

resource "azurerm_network_interface" "app01vm_nic" {
  name                = "app01vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app01vm_pub_ip.id
  }
}

resource "azurerm_network_security_group" "nsg_rdp" {
  name                = "app01vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow_rdp"
    priority                   = 100
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
  network_interface_id      = azurerm_network_interface.app01vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_rdp.id
}

resource "azurerm_windows_virtual_machine" "app01vm" {
  name                  = "app01vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.app01vm_nic.id]
  tags                  = var.tags

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
}

resource "azurerm_managed_disk" "data_disks" {
  for_each             = toset(var.disk_names)
  name                 = each.value
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachments" {
  count              = length(var.disk_names)
  managed_disk_id    = azurerm_managed_disk.data_disks[var.disk_names[count.index]].id
  virtual_machine_id = azurerm_windows_virtual_machine.app01vm.id
  lun                = var.disk_lunes[count.index]
  caching            = var.disk_caches[count.index]
}
