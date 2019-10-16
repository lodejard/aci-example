
# create key vault to hold data protection secret

resource "random_id" "key_vault_suffix" {
    byte_length = 5
}

resource "azurerm_key_vault" "aci_example" {
  name                     = "aciexample${lower(random_id.key_vault_suffix.hex)}"
  resource_group_name      = "${azurerm_resource_group.aci_example.name}"
  location                 = "${azurerm_resource_group.aci_example.location}"
  sku_name = "standard"

  tenant_id = "${data.azurerm_subscription.current.tenant_id}"
}

resource "azurerm_key_vault_access_policy" "aci_example" {
  key_vault_id = "${azurerm_key_vault.aci_example.id}"

  tenant_id = "${data.azurerm_subscription.current.tenant_id}"
  object_id = "${azurerm_user_assigned_identity.aci_example.principal_id}"

  key_permissions = [
    "wrapKey",
    "unwrapKey"
  ]

  secret_permissions = [
    "get",
  ]
}

resource "azurerm_key_vault_access_policy" "deploy" {
  key_vault_id = "${azurerm_key_vault.aci_example.id}"

  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${data.azurerm_client_config.current.object_id}"

  key_permissions = [
    "create",
    "delete",
    "get",
    "list",
  ]

  secret_permissions = [
    "get",
    "list",
  ]
}

resource "azurerm_key_vault_key" "aci_example" {
  depends_on = ["azurerm_key_vault_access_policy.deploy"]

  name         = "data-protection"
  key_vault_id = "${azurerm_key_vault.aci_example.id}"
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
