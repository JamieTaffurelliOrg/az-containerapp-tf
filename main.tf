/*resource "azurerm_container_app" "container_app" {
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
}*/

resource "azapi_resource" "container_app" {
  for_each  = { for k in var.container_apps : k.name => k }
  type      = "Microsoft.App/managedEnvironments@2022-11-01-preview"
  name      = each.key
  parent_id = data.azurerm_resource_group.resource_group.id
  location  = data.azurerm_container_app_environment.container_app_env.location
  tags      = var.tags

  body = jsonencode({
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      environmentId = data.azurerm_container_app_environment.container_app_env.id,
      configuration = {
        activeRevisionsMode  = each.value["revision_mode"],
        maxInactiveRevisions = each.value["max_inactive_revisions"],
        revisionSuffix       = each.value["revision_suffix"],
        dapr = each.value["dapr"] == null ? null : {
          appId              = each.value["dapr"].app_id,
          appPort            = each.value["dapr"].app_port,
          appProtocol        = each.value["dapr"].app_protocol,
          enableApiLogging   = each.value["dapr"].enable_logging,
          enabled            = each.value["dapr"].enabled,
          httpMaxRequestSize = each.value["dapr"].http_max_request_size_mb,
          httpReadBufferSize = each.value["dapr"].http_read_buffer_size_kb,
          logLevel           = each.value["dapr"].log_level
        },
        ingress = each.value["ingress"] == null ? null : {
          allowInsecure         = each.value["ingress"].allow_insecure_connections,
          clientCertificateMode = each.value["ingress"].client_certificate_mode,
          exposedPort           = each.value["ingress"].exposed_port,
          external              = each.value["ingress"].external_enabled,
          stickySessions        = each.value["ingress"].sticky_sessions,
          targetPort            = each.value["ingress"].target_port,
          transport             = each.value["ingress"].transport,
          corsPolicy = each.value["ingress"].cors_policy == null ? null : {
            allowCredentials = each.value["ingress"].cors_policy.allow_credentials,
            allowedHeaders   = each.value["ingress"].cors_policy.allowed_headers,
            allowedMethods   = each.value["ingress"].cors_policy.allowed_methods,
            allowedOrigins   = each.value["ingress"].cors_policy.allowed_origins,
            exposeHeaders    = each.value["ingress"].cors_policy.expose_headers,
            maxAge           = each.value["ingress"].cors_policy.max_age
          },
          customDomains = [for k in each.value["ingress"].custom_domains : [
            {
              bindingType   = k.value["certificate_binding_type"],
              certificateId = data.azurerm_container_app_environment_certificate.container_app_env_cert[(k.value["certificate_reference"])].id
              name          = k.value["name"]
            }
          ] if k != null]
          ipSecurityRestrictions = [for k in each.value["ingress"].ip_security_restrictions : [
            {
              action         = each.value["action"],
              description    = each.value["description"],
              ipAddressRange = each.value["ip_address_range"]
              name           = each.value["name"]
            }
          ] if k != null],
          traffic = [for k in each.value["ingress"].traffic_weights : [[
            {
              label          = each.value["label"],
              latestRevision = each.value["latest_revision"],
              revisionName   = each.value["revision_name"],
              weight         = each.value["percentage"]
            }
          ]] if k != null]
        },
        registries = [for k in each.value["registries"] : [
          {
            identity          = each.value["identity"],
            passwordSecretRef = each.value["password_secret_name"],
            server            = each.value["server"],
            username          = each.value["username"]
          }
        ] if k != null],
        secrets = [for k in each.value["secrets"] : [
          {
            identity    = each.value["identity"],
            keyVaultUrl = each.value["key_vault_url"],
            name        = each.value["name"],
            value       = var.secrets[(each.value["secret_reference"])].value
          }
        ] if k != null]
      },
      template = {
        containers = [for k in each.value["containers"] : [
          {
            name    = each.value["name"],
            args    = each.value["args"],
            command = each.value["command"],
            image   = each.value["image"],
            env = [for k in each.value["envs"] : [
              {
                name      = each.value["name"],
                secretRef = each.value["secret_name"],
                value     = each.value["value"]
              }
            ] if k != null],
            probes = [for k in [each.value["liveness_probe"], each.value["readiness_probe"], each.value["startup_probe"]] : [
              {
                failureThreshold              = each.value["failure_count_threshold"],
                terminationGracePeriodSeconds = each.value["termination_grace_period_seconds"],
                timeoutSeconds                = each.value["timeout"],
                type                          = each.value["type"],
                initialDelaySeconds           = each.value["initial_delay"],
                periodSeconds                 = each.value["interval_seconds"],
                successThreshold              = each.value["success_count_threshold"],
                httpGet = {
                  host   = each.value["host"],
                  path   = each.value["path"],
                  port   = each.value["port"],
                  scheme = each.value["host"],
                  httpHeaders = [for k in each.value["headers"] : [
                    {
                      name  = each.value["name"],
                      value = each.value["value"]
                    }
                  ]]
                }
              }
            ] if k != null],
            resources = {
              cpu    = each.value["cpu"],
              memory = each.value["memory"]
            },
            volumeMounts = [for k in each.value["volume_mounts"] : [
              {
                mountPath  = each.key,
                volumeName = each.value["path"]
              }
            ] if k != null]
          }
        ]],
        initContainers = [for k in each.value["init_containers"] : [
          {
            name    = each.value["name"],
            args    = each.value["args"],
            command = each.value["command"],
            image   = each.value["image"],
            env = [for k in each.value["envs"] : [
              {
                name      = each.value["name"],
                secretRef = each.value["secret_name"],
                value     = each.value["value"]
              }
            ] if k != null],
            resources = {
              cpu    = each.value["cpu"],
              memory = each.value["memory"]
            },
            volumeMounts = [for k in each.value["volume_mounts"] : [
              {
                mountPath  = each.key,
                volumeName = each.value["path"]
              }
            ] if k != null]
          }
        ]],
        scale = {
          maxReplicas = each.value["scale"].max_replicas,
          minReplicas = each.value["scale"].min_replicas,
          rules = [for k in each.value["scale"].rules : [
            {
              name = each.value["name"],
              azureQueue = each.value["azureQueue"] == null ? null : {
                queueLength = each.value["azureQueue"].queue_length,
                queueName   = each.value["azureQueue"].queue_name
                auth = [for k in each.value["azureQueue"].auth : [
                  {
                    secretRef        = each.value["secret_reference"],
                    triggerParameter = each.value["trigger_parameter"]
                  }
                ] if k != null]
              },
              custom = each.value["custom"] == null ? null : {
                metadata = each.value["custom"].metadata,
                type     = each.value["custom"].type
                auth = [for k in each.value["custom"].auth : [
                  {
                    secretRef        = each.value["secret_reference"],
                    triggerParameter = each.value["trigger_parameter"]
                  }
                ] if k != null]
              },
              http = each.value["http"] == null ? null : {
                metadata = each.value["http"].metadata,
                auth = [for k in each.value["http"].auth : [
                  {
                    secretRef        = each.value["secret_reference"],
                    triggerParameter = each.value["trigger_parameter"]
                  }
                ] if k != null]
              },
              tcp = each.value["tcp"] == null ? null : {
                metadata = each.value["tcp"].metadata,
                auth = [for k in each.value["tcp"].auth : [
                  {
                    secretRef        = each.value["secret_reference"],
                    triggerParameter = each.value["trigger_parameter"]
                  }
                ] if k != null]
              }
            }
          ]]
        },
        volumes = [for k in each.value["volumes"] : [
          {
            name        = each.value["name"],
            storageType = "EmptyDir"
          }
        ] if k != null]
      }
    }
  })
}
