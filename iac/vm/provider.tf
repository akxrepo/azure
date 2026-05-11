terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  # alias = "az-y"
  # type  = "azurerm"
  # tenant_id       = var.tenant_id
  # subscription_id = var.subscription_id
}
