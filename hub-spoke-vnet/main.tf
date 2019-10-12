
provider azurerm {
    subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
}

resource "azurerm_resource_group" "vnet_gp"{

name     = "${var.prefix}network-rg"
location = "${var.location}"

tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}

resource "azurerm_virtual_network" "test1" {
  name                = "${var.prefix}hub-vnet"
  location            = "${azurerm_resource_group.vnet_gp.location}"
  resource_group_name = "${azurerm_resource_group.vnet_gp.name}"
  address_space       = ["10.0.0.0/16"]

  

  subnet {
    name           = "firewall"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.0.3.0/24"
  }


  tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}
resource "azurerm_virtual_network" "test2" {
  name                = "${var.prefix}spoke1-vnet"
  location            = "${azurerm_resource_group.vnet_gp.location}"
  resource_group_name = "${azurerm_resource_group.vnet_gp.name}"
  address_space       = ["11.0.0.0/16"]

  

  subnet {
    name           = "dremio"
    address_prefix = "11.0.1.0/24"
  }

  subnet {
    name           = "database"
    address_prefix = "11.0.2.0/24"
  }
    tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}
resource "azurerm_virtual_network_peering" "peer1" {
  name                      = "peer1to2"
  resource_group_name       = "${azurerm_resource_group.vnet_gp.name}"
  virtual_network_name      = "${azurerm_virtual_network.test1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.test2.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "peer2to1"
  resource_group_name       = "${azurerm_resource_group.vnet_gp.name}"
  virtual_network_name      = "${azurerm_virtual_network.test2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.test1.id}"
}


