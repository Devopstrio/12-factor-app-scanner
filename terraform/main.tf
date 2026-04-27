# Devopstrio 12-Factor App Scanner - Enterprise Edition
# Architecture: Secure Serverless + VNet Integration

resource "azurerm_resource_group" "main" {
  name     = "rg-devopstrio-scanner-pro"
  location = "West Europe"
}

# Virtual Network for isolation
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-scanner"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "func_subnet" {
  name                 = "snet-function-delegation"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "function-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

# High-Performance Function Engine
resource "azurerm_linux_function_app" "pro_scanner" {
  name                = "func-devopstrio-12factor-pro"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.store.name
  storage_account_access_key = azurerm_storage_account.store.primary_access_key
  service_plan_id            = azurerm_service_plan.premium.id
  
  virtual_network_subnet_id = azurerm_subnet.func_subnet.id

  # Managed Identity for Secret-less Access
  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
    application_stack {
      python_version = "3.11"
    }
  }
}

resource "azurerm_service_plan" "premium" {
  name                = "plan-scanner-premium"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "EP1" # Elastic Premium for scaling
}

resource "azurerm_storage_account" "store" {
  name                     = "stdevopstrio12fpro"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-Redundant for BCDR
}
