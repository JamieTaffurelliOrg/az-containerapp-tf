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
          customDomains = each.value["ingress"].custom_domains == null ? [] : [for k in each.value["ingress"].custom_domains : [
            {
              bindingType   = k.certificate_binding_type,
              certificateId = data.azurerm_container_app_environment_certificate.container_app_env_cert[(k.certificate_reference)].id,
              name          = k.name
            }
          ]]
          ipSecurityRestrictions = each.value["ingress"].ip_security_restrictions == null ? [] : [for k in each.value["ingress"].ip_security_restrictions : [
            {
              action         = k.action,
              description    = k.description,
              ipAddressRange = k.ip_address_range,
              name           = k.name
            }
          ]],
          traffic = each.value["ingress"].traffic_weights == null ? [] : [for k in each.value["ingress"].traffic_weights : [
            {
              label          = k.label,
              latestRevision = k.latest_revision,
              revisionName   = k.revision_name,
              weight         = k.percentage
            }
          ]]
        },
        registries = each.value["registries"] == null ? [] : [for k in each.value["registries"] : [
          {
            identity          = k.identity,
            passwordSecretRef = k.password_secret_name,
            server            = k.server,
            username          = k.username
          }
        ]],
        secrets = each.value["secrets"] == null ? [] : [for k in each.value["secrets"] : [
          {
            identity    = k.identity,
            keyVaultUrl = k.key_vault_url,
            name        = k.name,
            value       = var.secrets[(k.secret_reference)].value
          }
        ]]
      },
      template = {
        containers = [for k in each.value["containers"] : [
          {
            name    = k.name,
            args    = k.args,
            command = k.command,
            image   = k.image,
            env = k.envs == null ? [] : [for v in k.envs : [
              {
                name      = v.name,
                secretRef = v.secret_name,
                value     = v.value
              }
            ]],
            probes = [for v in [k.liveness_probe, k.readiness_probe, k.startup_probe] : [
              {
                failureThreshold              = v.failure_count_threshold,
                terminationGracePeriodSeconds = v.termination_grace_period_seconds,
                timeoutSeconds                = v.timeout,
                type                          = v.type,
                initialDelaySeconds           = v.initial_delay,
                periodSeconds                 = v.interval_seconds,
                successThreshold              = v.success_count_threshold,
                httpGet = {
                  host   = v.host,
                  path   = v.path,
                  port   = v.port,
                  scheme = v.host,
                  httpHeaders = v.headers == null ? [] : [for i in v.headers : [
                    {
                      name  = i.name,
                      value = i.value
                    }
                  ]]
                }
              }
            ] if v != null],
            resources = {
              cpu    = k.cpu,
              memory = k.memory
            },
            volumeMounts = k.volume_mounts == null ? [] : [for v in k.volume_mounts : [
              {
                mountPath  = v.key,
                volumeName = v.path
              }
            ]]
          }
        ]],
        initContainers = each.value["init_containers"] == null ? [] : [for k in each.value["init_containers"] : [
          {
            name    = k.name,
            args    = k.args,
            command = k.command,
            image   = k.image,
            env = k.envs == null ? [] : [for v in k.envs : [
              {
                name      = v.name,
                secretRef = v.secret_name,
                value     = v.value
              }
            ]],
            resources = {
              cpu    = k.cpu,
              memory = k.memory
            },
            volumeMounts = k.volume_mounts == null ? [] : [for v in k.volume_mounts : [
              {
                mountPath  = v.key,
                volumeName = v.path
              }
            ]]
          }
        ]],
        scale = {
          maxReplicas = each.value["scale"].max_replicas,
          minReplicas = each.value["scale"].min_replicas,
          rules = each.value["scale"].rules == null ? [] : [for k in each.value["scale"].rules : [
            {
              name = k.name,
              azureQueue = k.azureQueue == null ? null : {
                queueLength = k.azureQueue.queue_length,
                queueName   = k.azureQueue.queue_name
                auth = k.azureQueue.auth == null ? [] : [for v in k.azureQueue.auth : [
                  {
                    secretRef        = v.secret_reference,
                    triggerParameter = v.trigger_parameter
                  }
                ]]
              },
              custom = k.custom == null ? null : {
                metadata = k.custom.metadata,
                type     = k.custom.type
                auth = k.custom.auth == null ? [] : [for v in k.custom.auth : [
                  {
                    secretRef        = v.secret_reference,
                    triggerParameter = v.trigger_parameter
                  }
                ]]
              },
              http = k.http == null ? null : {
                metadata = k.http.metadata,
                auth = k.http.auth == null ? [] : [for v in k.http.auth : [
                  {
                    secretRef        = v.secret_reference,
                    triggerParameter = v.trigger_parameter
                  }
                ]]
              },
              tcp = k.tcp == null ? null : {
                metadata = k.tcp.metadata,
                auth = k.tcp.auth == null ? [] : [for v in k.tcp.auth : [
                  {
                    secretRef        = v.secret_reference,
                    triggerParameter = v.trigger_parameter
                  }
                ]]
              }
            }
          ]]
        },
        volumes = each.value["volumes"] == null ? [] : [for k in each.value["volumes"] : [
          {
            name        = k.name,
            storageType = "EmptyDir"
          }
        ]]
      }
    }
  })
}
