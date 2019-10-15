
# create storage account and file share to hold application code

resource "random_id" "storage_account_suffix" {
    byte_length = 5
}

resource "azurerm_storage_account" "aci_example" {
  name                     = "aciexample${lower(random_id.storage_account_suffix.hex)}"
  resource_group_name      = "${azurerm_resource_group.aci_example.name}"
  location                 = "${azurerm_resource_group.aci_example.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_role_assignment" "storage_account" {
  scope = "${azurerm_storage_account.aci_example.id}"
  role_definition_name = "Contributor"
  principal_id = "${azurerm_user_assigned_identity.aci_example.principal_id}"
}

resource "azurerm_storage_container" "aci_example" {
  name                  = "webapp"
  storage_account_name  = "${azurerm_storage_account.aci_example.name}"
  container_access_type = "private"
}

resource "azurerm_storage_share" "aci_example" {
  name                 = "files"
  storage_account_name = "${azurerm_storage_account.aci_example.name}"
  quota                = 50
}
