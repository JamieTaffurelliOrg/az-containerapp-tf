resource "azurerm_container_app" "container_app" {
  for_each                     = { for k in var.container_apps : k.name => k }
  name                         = each.key
  container_app_environment_id = data.azurerm_container_app_environment.container_app_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = each.value["revision_mode"]

  template {
    max_replicas    = each.value["max_replicas"]
    min_replicas    = each.value["min_replicas"]
    revision_suffix = each.value["min_replicas"]

    dynamic "container" {
      for_each = { for k in each.value["containers"] : k.name => k }

      content {
        name    = container.key
        args    = each.value["args"]
        command = each.value["command"]
        image   = each.value["image"]
        cpu     = each.value["cpu"]
        memory  = each.value["memory"]

        dynamic "liveness_probe" {
          for_each = each.value["liveness_probe"] == null ? [] : [each.value["liveness_probe"]]

          content {
            failure_count_threshold          = liveness_probe.failure_count_threshold
            host                             = liveness_probe.host
            initial_delay                    = liveness_probe.initial_delay
            interval_seconds                 = liveness_probe.interval_seconds
            path                             = liveness_probe.path
            port                             = liveness_probe.port
            termination_grace_period_seconds = liveness_probe.termination_grace_period_seconds
            timeout                          = liveness_probe.timeout
            transport                        = liveness_probe.transport

            dynamic "header" {
              for_each = liveness_probe.value["header"] == null ? [] : [liveness_probe.value["header"]]

              content {
                name  = header.name
                value = header.value
              }
            }
          }
        }

        dynamic "readiness_probe" {
          for_each = each.value["readiness_probe"] == null ? [] : [each.value["readiness_probe"]]

          content {
            failure_count_threshold = readiness_probe.failure_count_threshold
            host                    = readiness_probe.host
            interval_seconds        = readiness_probe.interval_seconds
            path                    = readiness_probe.path
            port                    = readiness_probe.port
            success_count_threshold = readiness_probe.success_count_threshold
            timeout                 = readiness_probe.timeout
            transport               = readiness_probe.transport

            dynamic "header" {
              for_each = readiness_probe.value["header"] == null ? [] : [readiness_probe.value["header"]]

              content {
                name  = header.name
                value = header.value
              }
            }
          }
        }

        dynamic "startup_probe" {
          for_each = each.value["startup_probe"] == null ? [] : [each.value["startup_probe"]]

          content {
            failure_count_threshold          = startup_probe.failure_count_threshold
            host                             = startup_probe.host
            interval_seconds                 = startup_probe.interval_seconds
            path                             = startup_probe.path
            port                             = startup_probe.port
            termination_grace_period_seconds = startup_probe.termination_grace_period_seconds
            timeout                          = startup_probe.timeout
            transport                        = startup_probe.transport

            dynamic "header" {
              for_each = startup_probe.value["header"] == null ? [] : [startup_probe.value["header"]]

              content {
                name  = header.name
                value = header.value
              }
            }
          }
        }

        dynamic "env" {
          for_each = { for k in container.value["envs"] : k.name => k }

          content {
            name        = env.value["name"]
            secret_name = env.value["secret_name"]
            value       = env.value["value"]
          }
        }

        dynamic "volume_mounts" {
          for_each = { for k in container.value["volume_mounts"] : k.name => k }

          content {
            name = volume_mounts.key
            path = volume_mounts.value["path"]
          }
        }
      }
    }

    dynamic "volume" {
      for_each = { for k in each.value["volumes"] : k.name => k if k != null }

      content {
        name         = volume.name
        storage_type = "EmptyDir"
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "dapr" {
    for_each = each.value["dapr"] == null ? [] : [each.value["dapr"]]

    content {
      app_id       = dapr.app_id
      app_port     = dapr.app_port
      app_protocol = dapr.app_protocol
    }
  }

  dynamic "ingress" {
    for_each = each.value["ingress"] == null ? [] : [each.value["ingress"]]

    content {
      allow_insecure_connections = ingress.allow_insecure_connections
      fqdn                       = ingress.fqdn
      external_enabled           = ingress.external_enabled
      target_port                = ingress.target_port
      transport                  = ingress.transport

      dynamic "traffic_weight" {
        for_each = each.value["revision_mode"] == "Multiple" ? {} : ingress.traffic_weights

        content {
          revision_suffix = traffic_weight.value["revision_suffix"]
          label           = traffic_weight.value["label"]
          latest_revision = traffic_weight.value["latest_revision"]
          percentage      = traffic_weight.value["percentage"]
        }
      }

      dynamic "custom_domain" {
        for_each = { for k in ingress.value["custom_domains"] : k.name => k if k != null }

        content {
          name                     = custom_domain.key
          certificate_binding_type = custom_domain.value["certificate_binding_type"]
          certificate_id           = data.azurerm_container_app_environment_certificate.container_app_env_cert[(custom_domain.value["certificate_reference"])].id
        }
      }
    }
  }

  dynamic "registry" {
    for_each = each.value["registry"] == null ? [] : [each.value["registry"]]

    content {
      server               = registry.server
      identity             = registry.identity
      password_secret_name = registry.password_secret_name
      username             = registry.username
    }
  }

  dynamic "secret" {
    for_each = { for k in each.value["secrets"] : k.name => k if k != null }

    content {
      name  = each.value["name"]
      value = var.secrets[(each.value["secret_reference"])].value
    }
  }

  tags = var.tags
}
