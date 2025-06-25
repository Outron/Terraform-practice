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

resource "azurerm_resource_group" "webapp_rg" {
  count    = var.webapp_create ? 1 : 0
  name     = var.webapp_rg
  location = var.location
}

resource "azurerm_service_plan" "webapp_plan" {
  count               = var.webapp_create ? 1 : 0
  name                = "${var.webapp_name}_service_plan"
  resource_group_name = azurerm_resource_group.webapp_rg[0].name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp" {
  count               = var.webapp_create ? 1 : 0
  name                = var.webapp_name
  resource_group_name = azurerm_resource_group.webapp_rg[0].name
  location            = var.location
  service_plan_id     = azurerm_service_plan.webapp_plan[0].id

  site_config {}
}
