resource "azurecaf_name" "agw" {
  name          = var.settings.name
  resource_type = "azurerm_application_gateway"
  prefixes      = [var.global_settings.prefix]
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
}

resource "azurerm_application_gateway" "agw" {
  name                = azurecaf_name.agw.result
  resource_group_name = var.resource_group_name
  location            = var.location

  zones              = try(var.settings.zones, null)
  enable_http2       = try(var.settings.enable_http2, true)
  tags               = try(var.settings.tags, null)
  firewall_policy_id = try(var.settings.firewall_policy_id, null)

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = try(var.settings.capacity.autoscale, null) == null ? var.settings.capacity.scale_unit : null
  }

  gateway_ip_configuration {
    name      = var.settings.name
    subnet_id = var.vnets[var.settings.vnet_key].subnets[var.settings.subnet_key].id
  }

  dynamic autoscale_configuration {
    for_each = try(var.settings.capacity.autoscale, null) == null ? [] : [1]

    content {
      min_capacity = var.settings.capacity.autoscale.minimum_scale_unit
      max_capacity = var.settings.capacity.autoscale.maximum_scale_unit
    }
  }

  dynamic frontend_ip_configuration {
    for_each = var.settings.front_end_ip_configurations

    content {
      name                          = frontend_ip_configuration.value.name
      public_ip_address_id          = try(frontend_ip_configuration.value.public_ip_key, null) == null ? null : var.public_ip_addresses[frontend_ip_configuration.value.public_ip_key].id
      private_ip_address            = try(frontend_ip_configuration.value.public_ip_key, null) == null ? cidrhost(var.vnets[frontend_ip_configuration.value.vnet_key].subnets[frontend_ip_configuration.value.subnet_key].cidr[frontend_ip_configuration.value.subnet_cidr_index], frontend_ip_configuration.value.private_ip_offset) : null
      private_ip_address_allocation = try(frontend_ip_configuration.value.public_ip_key, null) == null ? frontend_ip_configuration.value.private_ip_address_allocation : null
      subnet_id                     = try(frontend_ip_configuration.value.public_ip_key, null) == null ? var.vnets[frontend_ip_configuration.value.vnet_key].subnets[frontend_ip_configuration.value.subnet_key].id : null
    }
  }

  dynamic frontend_port {
    for_each = var.settings.front_end_ports

    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic http_listener {
    for_each = var.application_gateway_applications.listeners

    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = var.settings.front_end_ip_configurations[http_listener.value.front_end_ip_configuration_key].name
      frontend_port_name             = var.settings.front_end_ports[http_listener.value.front_end_port_key].name
      protocol                       = var.settings.front_end_ports[http_listener.value.front_end_port_key].protocol
    }
  }

  dynamic request_routing_rule {
    for_each = var.application_gateway_applications.request_routing_rules

    content {
      name               = request_routing_rule.value.name
      rule_type          = request_routing_rule.value.rule_type
      http_listener_name = var.application_gateway_applications.listeners[request_routing_rule.value.http_listener_key].name
      backend_http_settings_name = var.application_gateway_applications.backend_http_settings[request_routing_rule.value.backend_http_settings_key].name
      backend_address_pool_name = var.application_gateway_applications.backend_pools[request_routing_rule.value.backend_pool_key].name
    }
  }

  dynamic backend_http_settings {
    for_each = var.application_gateway_applications.backend_http_settings

    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity = try(backend_http_settings.value.cookie_based_affinity, "Disabled")
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      request_timeout       = try(backend_http_settings.value.request_timeout, 30)
    }
  }

  dynamic backend_address_pool {
    for_each = var.application_gateway_applications.backend_pools

    content {
      name = backend_address_pool.value.name
    }
  }




  # identity {

  # }
  # authentication_certificate {

  # }

  # trusted_root_certificate {

  # }

  # ssl_policy {

  # }

  # probe {

  # }

  # ssl_certificate {

  # }

  # url_path_map {}

  # waf_configuration {}

  # custom_error_configuration {}

  # redirect_configuration {}

  # autoscale_configuration {}

  # rewrite_rule_set {}


}