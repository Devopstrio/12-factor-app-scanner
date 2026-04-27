# Devopstrio 12-Factor App Scanner Infrastructure
# Cloud-Native Deployment Template

resource "azurerm_resource_group" "scanner" {
  name     = "rg-12factor-scanner"
  location = var.location
  tags = {
    Environment = "Production"
    Portfolio   = "Devopstrio"
  }
}

resource "azurerm_storage_account" "store" {
  name                     = "st12factorscanprod"
  resource_group_name      = azurerm_resource_group.scanner.name
  location                 = azurerm_resource_group.scanner.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-scanner-service"
  resource_group_name = azurerm_resource_group.scanner.name
  location            = azurerm_resource_group.scanner.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption tier
}

resource "azurerm_linux_function_app" "app" {
  name                = "func-12factor-scanner"
  resource_group_name = azurerm_resource_group.scanner.name
  location            = azurerm_resource_group.scanner.location

  storage_account_name       = azurerm_storage_account.store.name
  storage_account_access_key = azurerm_storage_account.store.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.insights.instrumentation_key
    "SCAN_TIMEOUT_SEC"               = "300"
  }
}

resource "azurerm_application_insights" "insights" {
  name                = "ai-scanner-monitoring"
  location            = azurerm_resource_group.scanner.location
  resource_group_name = azurerm_resource_group.scanner.name
  application_type    = "web"
}
