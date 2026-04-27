# Devopstrio 12-Factor Scanner - Networking Layer
# Tier-1 Segmentation & Application Gateway

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devopstrio-scanner"
  address_space       = ["10.10.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "frontend" {
  name                 = "snet-frontend"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend-delegation"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/24"]

  delegation {
    name = "function-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_public_ip" "appgw_ip" {
  name                = "pip-scanner-appgw"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "network" {
  name                = "appgw-scanner-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "my-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw_ip.id
  }

  backend_address_pool {
    name = "scanner-pool"
  }

  backend_http_settings {
    name                  = "http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "my-frontend-ip-configuration"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "scanner-pool"
    backend_http_settings_name = "http-setting"
    priority                   = 1
  }
}
