# Devopstrio 12-Factor Scanner - Storage & Security Layer
# Architecture: Private-Link Secure Tiered Storage

resource "azurerm_storage_account" "data" {
  name                     = "stdevopstrioscanarch"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Secure-only access
  public_network_access_enabled = false
}

# 1. Blob Storage (Reports & Artifacts)
resource "azurerm_storage_container" "reports" {
  name                  = "reports"
  storage_account_name  = azurerm_storage_account.data.name
  container_access_type = "private"
}

# 2. Queue Storage (Scan Jobs)
resource "azurerm_storage_queue" "jobs" {
  name                 = "scan-jobs"
  storage_account_name = azurerm_storage_account.data.name
}

# 3. Table Storage (Metadata & Results)
resource "azurerm_storage_table" "results" {
  name                 = "ScanResults"
  storage_account_name = azurerm_storage_account.data.name
}

# Security: Dedicated Key Vault
resource "azurerm_key_vault" "secrets" {
  name                        = "kv-scanner-secrets"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "pe-scanner-storage"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.backend.id

  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = azurerm_storage_account.data.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}
