terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  features {}

  # alias = "az-y"
  # type  = "azurerm"
  # tenant_id       = var.tenant_id
  # subscription_id = var.subscription_id
}

provider "random" {}
