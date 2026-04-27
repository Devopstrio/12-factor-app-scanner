# Devopstrio 12-Factor Scanner - Compute & Monitoring Layer

resource "azurerm_service_plan" "scale" {
  name                = "plan-scanner-enterprise"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "EP1" # Elastic Premium for Scale-Out
}

resource "azurerm_linux_function_app" "engine" {
  name                = "func-devopstrio-scanner-engine"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  storage_account_name       = azurerm_storage_account.data.name
  storage_account_access_key = azurerm_storage_account.data.primary_access_key
  service_plan_id            = azurerm_service_plan.scale.id
  
  # Network Isolation
  virtual_network_subnet_id = azurerm_subnet.backend.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "STORAGE_QUEUE_NAME" = azurerm_storage_queue.jobs.name
    "STORAGE_TABLE_NAME" = azurerm_storage_table.results.name
    "KEY_VAULT_URL"      = azurerm_key_vault.secrets.vault_uri
    "APPINSIGHTS_KEY"    = azurerm_application_insights.logs.instrumentation_key
  }
}

resource "azurerm_application_insights" "logs" {
  name                = "ai-scanner-monitoring"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "alerts" {
  name                = "ag-scanner-critical"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "ScannerAlert"

  email_receiver {
    name          = "Admin"
    email_address = "info@devopstrio.co.uk"
  }
}
