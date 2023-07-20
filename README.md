# az-containerapp-tf
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |
| [azurerm_container_app_environment.container_app_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_app_environment) | data source |
| [azurerm_container_app_environment_certificate.container_app_env_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_app_environment_certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_environment_certificates"></a> [container\_app\_environment\_certificates](#input\_container\_app\_environment\_certificates) | Container app environment certificates to use for custom domains | `list(string)` | `[]` | no |
| <a name="input_container_app_environment_name"></a> [container\_app\_environment\_name](#input\_container\_app\_environment\_name) | Name of the container app environment to deploy container app to | `string` | n/a | yes |
| <a name="input_container_app_environment_resource_group_name"></a> [container\_app\_environment\_resource\_group\_name](#input\_container\_app\_environment\_resource\_group\_name) | Resource group name of the container app environment to deploy container app to | `string` | n/a | yes |
| <a name="input_container_apps"></a> [container\_apps](#input\_container\_apps) | Container apps to deploy | <pre>list(object(<br>    {<br>      name            = string<br>      revision_mode   = optional(string, "Single")<br>      max_replicas    = number<br>      min_replicas    = number<br>      revision_suffix = optional(string)<br><br>      containers = list(object({<br>        name    = string<br>        args    = optional(list(string))<br>        command = optional(list(string))<br>        image   = string<br>        cpu     = string<br>        memory  = string<br>        liveness_probe = optional(object({<br>          failure_count_threshold          = optional(number, 3)<br>          host                             = optional(string)<br>          initial_delay                    = optional(number)<br>          interval_seconds                 = optional(number, 10)<br>          path                             = optional(string, "/")<br>          port                             = optional(number, 443)<br>          termination_grace_period_seconds = optional(number)<br>          timeout                          = optional(number, 1)<br>          transport                        = optional(string, "Https")<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>        }))<br>        readiness_probe = optional(object({<br>          failure_count_threshold = optional(number, 3)<br>          host                    = optional(string)<br>          interval_seconds        = optional(number, 10)<br>          path                    = optional(string, "/")<br>          port                    = optional(number, 443)<br>          success_count_threshold = optional(number, 3)<br>          timeout                 = optional(number, 1)<br>          transport               = optional(string, "Https")<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>        }))<br>        startup_probe = optional(object({<br>          failure_count_threshold          = optional(number, 3)<br>          host                             = optional(string)<br>          interval_seconds                 = optional(number, 10)<br>          path                             = optional(string, "/")<br>          port                             = optional(number, 443)<br>          termination_grace_period_seconds = optional(number)<br>          timeout                          = optional(number, 1)<br>          transport                        = optional(string, "Https")<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>        }))<br>        envs = optional(list(object({<br>          name        = string<br>          secret_name = optional(string)<br>          value       = optional(string)<br>        })))<br>        envs = optional(list(object({<br>          name = string<br>          path = string<br>        })))<br>      }))<br>      dapr = optional(object({<br>        app_id       = string<br>        app_port     = number<br>        app_protocol = optional(string, "http")<br>      }))<br>      ingress = optional(object({<br>        allow_insecure_connections = optional(bool, false)<br>        fqdn                       = string<br>        external_enabled           = optional(bool, false)<br>        target_port                = number<br>        transport                  = optional(string, "auto")<br>        traffic_weights = optional(map(object({<br>          revision_suffix = optional(string)<br>          label           = optional(string)<br>          latest_revision = optional(string)<br>          percentage      = number<br>        })))<br>        custom_domains = optional(list(object({<br>          name                     = string<br>          certificate_binding_type = optional(string, "Disabled")<br>          certificate_reference    = string<br>        })))<br>      }))<br>      registry = optional(object({<br>        server               = string<br>        identity             = optional(string)<br>        password_secret_name = optional(string)<br>        username             = optional(string)<br>      }))<br>      volumes = optional(list(object({<br>        name = string<br>      })))<br>      secrets = optional(list(object({<br>        name             = string<br>        secret_reference = string<br>      })))<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group name to deploy to | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets for container apps to consume | <pre>map(object(<br>    {<br>      value = string<br>    }<br>  ))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
