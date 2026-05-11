output "backend_resource_group_name" {
  value = azurerm_resource_group.tf_backend.name
}

output "backend_storage_account_name" {
  value = azurerm_storage_account.tf_backend.name
}

output "backend_container_name" {
  value = azurerm_storage_container.tf_backend.name
}

output "backend_state_key" {
  value = azurerm_storage_blob.tf_backend.name
}
