
output "ip_address" {
  value = "${azurerm_container_group.aci_example.ip_address}"
}

output "aci_fqdn" {
  value = "${azurerm_container_group.aci_example.fqdn}"
}

output "afd_fqdn" {
  value = "aci-example-${lower(random_id.frontdoor_suffix.hex)}.azurefd.net"
}

output "storage_account_name" {
  value = "${azurerm_storage_account.aci_example.name}"
}

output "storage_account_key" {
  value = "${azurerm_storage_account.aci_example.primary_access_key}"
  sensitive   = true
}

output "resource_group_name" {
  value = "${azurerm_resource_group.aci_example.name}"
}

output "container_group_name" {
  value = "${azurerm_container_group.aci_example.name}"
}
