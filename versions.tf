terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.20"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 1.8"
    }
  }
  required_version = "~> 1.5.0"
}
