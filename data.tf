data "azurerm_container_app_environment" "container_app_env" {
  name                = var.container_app_environment_name
  resource_group_name = var.container_app_environment_resource_group_name
}

data "azurerm_container_app_environment_certificate" "container_app_env_cert" {
  for_each                     = toset(var.container_app_environment_certificates)
  name                         = each.key
  container_app_environment_id = data.azurerm_container_app_environment.container_app_env.id
}
