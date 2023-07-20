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
      name            = string
      revision_mode   = optional(string, "Single")
      max_replicas    = number
      min_replicas    = number
      revision_suffix = optional(string)

      containers = list(object({
        name    = string
        args    = optional(list(string))
        command = optional(list(string))
        image   = string
        cpu     = string
        memory  = string
        liveness_probe = optional(object({
          failure_count_threshold          = optional(number, 3)
          host                             = optional(string)
          initial_delay                    = optional(number)
          interval_seconds                 = optional(number, 10)
          path                             = optional(string, "/")
          port                             = optional(number, 443)
          termination_grace_period_seconds = optional(number)
          timeout                          = optional(number, 1)
          transport                        = optional(string, "Https")
          header = optional(object({
            name  = string
            value = string
          }))
        }))
        readiness_probe = optional(object({
          failure_count_threshold = optional(number, 3)
          host                    = optional(string)
          interval_seconds        = optional(number, 10)
          path                    = optional(string, "/")
          port                    = optional(number, 443)
          success_count_threshold = optional(number, 3)
          timeout                 = optional(number, 1)
          transport               = optional(string, "Https")
          header = optional(object({
            name  = string
            value = string
          }))
        }))
        startup_probe = optional(object({
          failure_count_threshold          = optional(number, 3)
          host                             = optional(string)
          interval_seconds                 = optional(number, 10)
          path                             = optional(string, "/")
          port                             = optional(number, 443)
          termination_grace_period_seconds = optional(number)
          timeout                          = optional(number, 1)
          transport                        = optional(string, "Https")
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
        envs = optional(list(object({
          name = string
          path = string
        })))
      }))
      dapr = optional(object({
        app_id       = string
        app_port     = number
        app_protocol = optional(string, "http")
      }))
      ingress = optional(object({
        allow_insecure_connections = optional(bool, false)
        fqdn                       = string
        external_enabled           = optional(bool, false)
        target_port                = number
        transport                  = optional(string, "auto")
        traffic_weights = optional(map(object({
          revision_suffix = optional(string)
          label           = optional(string)
          latest_revision = optional(string)
          percentage      = number
        })))
        custom_domains = optional(list(object({
          name                     = string
          certificate_binding_type = optional(string, "Disabled")
          certificate_reference    = string
        })))
      }))
      registry = optional(object({
        server               = string
        identity             = optional(string)
        password_secret_name = optional(string)
        username             = optional(string)
      }))
      volumes = optional(list(object({
        name = string
      })))
      secrets = optional(list(object({
        name             = string
        secret_reference = string
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
