terraform {
    required_providers{
        azurerm={
            source = "hashicorp/azurerm"
            version = "4.1.0"
        }
    }
}

provider "azurerm"{
    resource_provider_registrations = "none"
    subscription_id = "5d803f6b-79b0-4ae1-bed4-06b468a8bf11"
    features {}
}

resource "azurerm_resource_group" "example" {
    name = "gowebapp-resources"
    location = "westus"

}
resource "azurerm_virtual_network" "example"{
    name ="gowebapp-network"
    resource_group_name = azurerm_resource_group.example.name
    location = azurerm_resource_group.example.location
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {

  name                 = "gowebapp-subnet"

  resource_group_name  = azurerm_resource_group.example.name

  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = ["10.0.1.0/24"]
}


resource "azurerm_kubernetes_cluster" "aks" {

  name                = "gowebapp-aks"

  location            = azurerm_resource_group.example.location

  resource_group_name = azurerm_resource_group.example.name

  dns_prefix = "portfolio"

  default_node_pool {

      name = "system"

      node_count = 3

      vm_size = "Standard_D2s_v3"

      vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {

      type = "SystemAssigned"
  }
  network_profile {
  network_plugin = "azure"

  service_cidr   = "10.2.0.0/16"
  dns_service_ip = "10.2.0.10"
}
}


