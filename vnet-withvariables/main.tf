
provider azurerm {
    subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
}

resource "azurerm_resource_group" "resource1_vnet_gp"{

name     = "${var.prefix}-rg"
location = "${var.location}"

tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "${var.prefix}-vnet"
  location            = "${azurerm_resource_group.resource1_vnet_gp.location}"
  resource_group_name = "${azurerm_resource_group.resource1_vnet_gp.name}"
  address_space       = ["11.0.0.0/16"]

  

  subnet {
    name           = "firewall"
    address_prefix = "11.0.1.0/24"
  }

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "11.0.3.0/24"
  }


  tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}