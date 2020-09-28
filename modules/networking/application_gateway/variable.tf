variable settings {}
variable global_settings {}
variable diagnostics {}
variable resource_group_name {}
variable location {}
variable public_ip_addresses {}
variable application_gateway_applications {}
variable vnets {}

variable sku_name {
  type        = string
  default     = "Standard_v2"
  description = "(Optional) (Default = Standard_v2) The Name of the SKU to use for this Application Gateway. Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2."

  validation {
    condition     = contains(["Standard_Small", "Standard_Medium", "Standard_Large", "Standard_v2", "WAF_Medium", "WAF_Large", "WAF_v2"], var.sku_name)
    error_message = "Provide an allowed value as defined in https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html#sku."
  }
}

variable sku_tier {
  type        = string
  default     = "Standard_v2"
  description = "(Optional) (Default = Standard_v2) (Required) The Tier of the SKU to use for this Application Gateway. Possible values are Standard, Standard_v2, WAF and WAF_v2."

  validation {
    condition     = contains(["Standard", "Standard_v2", "WAF ", "WAF_v2"], var.sku_tier)
    error_message = "Provide an allowed value as defined in https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html#sku."
  }
}

