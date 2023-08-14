variable "container_app_environment_name" {
  type        = string
  description = "Name of the container app environment to deploy container app to"
}

variable "container_app_environment_resource_group_name" {
  type        = string
  description = "Resource group name of the container app environment to deploy container app to"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name to deploy to"
}

variable "container_app_environment_certificates" {
  type        = list(string)
  default     = []
  description = "Container app environment certificates to use for custom domains"
}

variable "container_apps" {
  type = list(object(
    {
      name                   = string
      revision_mode          = optional(string, "Single")
      revision_suffix        = optional(string)
      max_inactive_revisions = optional(number)
      dapr = optional(object({
        app_id                   = string
        app_port                 = number
        app_protocol             = optional(string, "http")
        enable_logging           = optional(bool, true)
        enabled                  = optional(bool, true),
        http_max_request_size_mb = optional(number, 4),
        http_read_buffer_size_kb = optional(number, 65),
        log_level                = optional(string, "info")
      }))
      ingress = optional(object({
        allow_insecure_connections = optional(bool, false)
        client_certificate_mode    = optional(string)
        exposed_port               = optional(number)
        external_enabled           = optional(bool, false)
        target_port                = number
        transport                  = optional(string, "Auto")
        cors_policy = optional(object({
          allow_credentials = optional(bool)
          allowed_headers   = optional(list(string))
          allowed_methods   = optional(list(string))
          allowed_origins   = optional(list(string))
          expose_headers    = optional(list(string))
          max_age           = optional(number)
        }))
        custom_domains = optional(list(object({
          name                     = string
          certificate_binding_type = optional(string, "Disabled")
          certificate_reference    = string
        })))
        ip_security_restrictions = optional(list(object({
          name             = string,
          action           = string,
          description      = string,
          ip_address_range = string,
        })))
        sticky_sessions = optional(object({
          affinity = string
        }))
        traffic_weights = optional(map(object({
          revision_name   = optional(string)
          label           = optional(string)
          latest_revision = optional(bool)
          percentage      = number
          })),
          {
            "lastest-revision" = {
              latest_revision = true
              percentage      = 100
            }
        })
      }))
      registries = optional(list(object({
        server               = string
        identity             = optional(string)
        password_secret_name = optional(string)
        username             = optional(string)
      })))
      secrets = optional(list(object({
        name             = string
        secret_reference = optional(string)
        identity         = optional(string, "System")
        key_vault_url    = optional(string)
      })))
      containers = list(object({
        name    = string
        args    = optional(list(string))
        command = optional(list(string))
        image   = string
        cpu     = number
        memory  = string
        liveness_probe = optional(object({
          type                             = optional(string, "Liveness")
          failure_count_threshold          = optional(number, 3)
          host                             = optional(string)
          initial_delay                    = optional(number)
          interval_seconds                 = optional(number, 10)
          path                             = optional(string, "/")
          port                             = optional(number, 443)
          termination_grace_period_seconds = optional(number)
          timeout                          = optional(number, 1)
          header = optional(object({
            name  = string
            value = string
          }))
        }))
        readiness_probe = optional(object({
          type                    = optional(string, "Readiness")
          failure_count_threshold = optional(number, 3)
          host                    = optional(string)
          interval_seconds        = optional(number, 10)
          path                    = optional(string, "/")
          port                    = optional(number, 443)
          success_count_threshold = optional(number, 3)
          timeout                 = optional(number, 1)
          header = optional(object({
            name  = string
            value = string
          }))
        }))
        startup_probe = optional(object({
          type                             = optional(string, "Startup")
          failure_count_threshold          = optional(number, 3)
          host                             = optional(string)
          interval_seconds                 = optional(number, 10)
          path                             = optional(string, "/")
          port                             = optional(number, 443)
          termination_grace_period_seconds = optional(number)
          timeout                          = optional(number, 1)
          header = optional(object({
            name  = string
            value = string
          }))
        }))
        envs = optional(list(object({
          name        = string
          secret_name = optional(string)
          value       = optional(string)
        })))
        volume_mounts = optional(list(object({
          name = string
          path = string
        })))
      }))
      init_containers = optional(list(object({
        name    = string
        args    = optional(list(string))
        command = optional(list(string))
        image   = string
        cpu     = number
        memory  = string
        envs = optional(list(object({
          name        = string
          secret_name = optional(string)
          value       = optional(string)
        })))
        volume_mounts = optional(list(object({
          name = string
          path = string
        })))
      })))
      scale = object({
        max_replicas = number
        min_replicas = number
        rules = optional(list(object({
          name = string
          azure_queue = optional(object({
            queue_length = number
            queue_name   = string
            auth = optional(list(object({
              secret_reference  = optional(string)
              trigger_parameter = optional(string)
            })))
          }))
          custom = optional(object({
            metadata = optional(map(string))
            type     = string
            auth = optional(list(object({
              secret_reference  = optional(string)
              trigger_parameter = optional(string)
            })))
          }))
          http = optional(object({
            metadata = optional(map(string))
            auth = optional(list(object({
              secret_reference  = optional(string)
              trigger_parameter = optional(string)
            })))
          }))
          tcp = optional(object({
            metadata = optional(map(string))
            auth = optional(list(object({
              secret_reference  = optional(string)
              trigger_parameter = optional(string)
            })))
          }))
        })))
      })
      volumes = optional(list(object({
        name = string
      })))
    }
  ))
  default     = []
  description = "Container apps to deploy"
}

variable "secrets" {
  type = map(object(
    {
      value = string
    }
  ))
  default     = {}
  sensitive   = true
  description = "Secrets for container apps to consume"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
