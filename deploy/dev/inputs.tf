
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

variable "location" {
    type = "string"
    default = "eastus2"
    description = "Azure location used for resource group and created resources"
}

variable "resource_group_name" {
    type = "string"
    default = "aci-example"
    description = "Resource group name to hold any created resources"
}
