
resource "random_id" "frontdoor_suffix" {
    byte_length = 5
}

resource "azurerm_frontdoor" "aci_example" {
  name                                         = "aci-example-${lower(random_id.frontdoor_suffix.hex)}"
  location                                     = "${azurerm_resource_group.aci_example.location}"
  resource_group_name                          = "${azurerm_resource_group.aci_example.name}"
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
      name                    = "routingWebApp"
      accepted_protocols      = ["Http", "Https"]
      patterns_to_match       = ["/*"]
      frontend_endpoints      = ["frontendWebApp"]
      forwarding_configuration {
        forwarding_protocol   = "HttpOnly"
        backend_pool_name     = "backendWebApp"
      }
  }

  backend_pool_load_balancing {
    name = "loadBalancingWebApp"
  }

  backend_pool_health_probe {
    name = "healthProbeWebApp"
    path = "/-/ready"
    protocol = "Https"
  }

  backend_pool {
      name            = "backendWebApp"
      backend {
          host_header = "${azurerm_container_group.aci_example.fqdn}"
          address     = "${azurerm_container_group.aci_example.fqdn}"
          http_port   = 80
          https_port  = 443
      }

      load_balancing_name = "loadBalancingWebApp"
      health_probe_name   = "healthProbeWebApp"
  }

  frontend_endpoint {
    name                              = "frontendWebApp"
    host_name                         = "aci-example-${lower(random_id.frontdoor_suffix.hex)}.azurefd.net"
    custom_https_provisioning_enabled = false    
  }
}
