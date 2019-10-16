

resource "azurerm_resource_group" "aci_example" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

# create managed identity for application to access resources

resource "random_id" "containergroup_suffix" {
    byte_length = 5
}

resource "azurerm_user_assigned_identity" "aci_example" {
    name = "hello-world-identity"
    resource_group_name = "${azurerm_resource_group.aci_example.name}"
    location            = "${azurerm_resource_group.aci_example.location}"
}

# create container to run

resource "azurerm_container_group" "aci_example" {
    depends_on = ["azurerm_storage_share.aci_example"]

    name = "aci_example"
    resource_group_name = "${azurerm_resource_group.aci_example.name}"
    location            = "${azurerm_resource_group.aci_example.location}"
    ip_address_type     = "public"
    dns_name_label      = "aci-example-${lower(random_id.containergroup_suffix.hex)}"
    os_type             = "Linux"

    identity {
        type = "UserAssigned"
        identity_ids = ["${azurerm_user_assigned_identity.aci_example.id}"]
    }

    container {
        name   = "web-app"
        image  = "mcr.microsoft.com/dotnet/core/aspnet:3.0"
        cpu    = "0.5"
        memory = "1.5"

        commands = ["/bin/bash", "-c", "cd /files/app && dotnet HelloWorld.dll"]

        environment_variables = {
          ASPNETCORE_URLS = "http://0.0.0.0:80"
          ASPNETCORE_ENVIRONMENT = "Production"
          HelloWorld__Azure__TenantId = "${data.azurerm_subscription.current.tenant_id}"
          HelloWorld__Azure__SubscriptionId = "${data.azurerm_subscription.current.subscription_id}"
          HelloWorld__DataProtection__Enabled = "true"
          HelloWorld__DataProtection__StorageAccountIdentifier = "${azurerm_storage_account.aci_example.id}"
          HelloWorld__DataProtection__KeyIdentifier = "${azurerm_key_vault_key.aci_example.id}"
        }

        ports {
            port     = 80
            protocol = "TCP"
        }

        readiness_probe {
            http_get {
                path = "/-/ready"
                scheme = "Http"
                port = 80
            }
        }

        liveness_probe {
            http_get {
                path = "/-/alive"
                scheme = "Http"
                port = 80
            }
        }

        volume {
            name       = "files"
            mount_path = "/files"
            read_only  = true
            share_name = "${azurerm_storage_share.aci_example.name}"

            storage_account_name = "${azurerm_storage_account.aci_example.name}"
            storage_account_key  = "${azurerm_storage_account.aci_example.primary_access_key}"
        }
    }
}
