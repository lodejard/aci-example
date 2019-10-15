
provider "azurerm" {
    version = "~> 1.35"
}

provider "random" {
    version = "~> 2.2"
}

resource "azurerm_resource_group" "aci_example" {
  name     = "aci-example-dev"
  location = "westus2"
}

resource "random_id" "storage_account" {
    byte_length = 5
}

resource "random_id" "dns_suffix" {
    byte_length = 5
}

# create storage account and file share to hold application code
resource "azurerm_storage_account" "aci_example" {
  name                     = "aciexample${lower(random_id.storage_account.hex)}"
  resource_group_name      = "${azurerm_resource_group.aci_example.name}"
  location                 = "${azurerm_resource_group.aci_example.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "aci_example" {
  name                 = "files"
  storage_account_name = "${azurerm_storage_account.aci_example.name}"
  quota                = 50
}

# create managed identity for app to access related resources
resource "azurerm_user_assigned_identity" "aci_example" {
    name = "hello-world-identity"
    resource_group_name = "${azurerm_resource_group.aci_example.name}"
    location            = "${azurerm_resource_group.aci_example.location}"
}

resource "azurerm_container_group" "aci_example" {
    name = "aci_example"
    resource_group_name = "${azurerm_resource_group.aci_example.name}"
    location            = "${azurerm_resource_group.aci_example.location}"
    ip_address_type     = "public"
    dns_name_label      = "aci-example-${lower(random_id.dns_suffix.hex)}"
    os_type             = "Linux"

    identity {
        type = "UserAssigned"
        identity_ids = ["${azurerm_user_assigned_identity.aci_example.id}"]
    }

    container {
        name   = "hello-world"
        image  = "mcr.microsoft.com/dotnet/core/sdk:3.0"
        cpu    = "0.5"
        memory = "1.5"

        commands = ["/bin/bash", "-c", "cd /files/app && dotnet HelloWorld.dll"]

        environment_variables = {
          ASPNETCORE_URLS = "http://0.0.0.0:80"
          ASPNETCORE_ENVIRONMENT = "Development"
        }

        ports {
            port     = 80
            protocol = "TCP"
        }

        volume {
            name       = "files"
            mount_path = "/files"
            read_only  = false
            share_name = "${azurerm_storage_share.aci_example.name}"

            storage_account_name = "${azurerm_storage_account.aci_example.name}"
            storage_account_key  = "${azurerm_storage_account.aci_example.primary_access_key}"
        }
    }
}

