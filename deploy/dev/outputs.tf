
output "ip_address" {
  value = "${azurerm_container_group.aci_example.ip_address}"
}

output "fqdn" {
  value = "${azurerm_container_group.aci_example.fqdn}"
}

output "storage_account_name" {
  value = "${azurerm_storage_account.aci_example.name}"
}

output "storage_account_key" {
  value = "${azurerm_storage_account.aci_example.primary_access_key}"
  sensitive   = true
}
