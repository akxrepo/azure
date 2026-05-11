resource "azurerm_resource_group" "tf_backend" {
  name     = "tf-backend-rg"
  location = "East US"
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_storage_account" "tf_backend" {
  name                     = "tfbackend${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tf_backend.name
  location                 = azurerm_resource_group.tf_backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tf_backend" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tf_backend.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tf_backend" {
  name                   = "terraform.tfstate"
  storage_account_name   = azurerm_storage_account.tf_backend.name
  storage_container_name = azurerm_storage_container.tf_backend.name
  type                   = "Block"
  source_content         = <<-EOT
    {
      "version": 4,
      "terraform_version": "1.0.0",
      "serial": 1,
      "lineage": "00000000-0000-0000-0000-000000000000",
      "outputs": {},
      "resources": []
    }
  EOT
}

