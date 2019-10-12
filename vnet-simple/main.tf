
provider azurerm {
    subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
}

resource "azurerm_resource_group" "resource2_vnet_gp"{

name = "qrvnet-rg"
location = "westeurope"

tags = {
    Owner = "Anil"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "qrhub-vnet"
  location            = "${azurerm_resource_group.resource2_vnet_gp.location}"
  resource_group_name = "${azurerm_resource_group.resource2_vnet_gp.name}"
  address_space       = ["10.0.0.0/16"]

  

  subnet {
    name           = "firewall"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.0.2.0/24"
  }


  tags = {
    environment = "Production"
  }
}