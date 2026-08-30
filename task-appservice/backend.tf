terraform {
  backend "azurerm" {
    resource_group_name  = "rg-appservice-demo"
    storage_account_name = "tfstateappservice2026"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}