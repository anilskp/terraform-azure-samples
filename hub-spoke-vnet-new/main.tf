
provider azurerm {
    subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
}

locals {
  common_tags = {
     Owner = "${var.Owner}"
     Environment = "${var.Environment}"
     CC = "${var.CC}"
  }

  # extra_tags  = {
  #   network = "${var.network1_name}"
  #   support = "${var.network_support_name}"
  # }
}

resource "azurerm_resource_group" "vnet_gp"{

name     = "${var.prefix}network-rg"
location = "${var.location}"
tags = "${merge( local.common_tags)}"
#tags = "${merge( local.common_tags, local.extra_tags)}"

}
resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}hub-vnet"
  location            = "${azurerm_resource_group.vnet_gp.location}"
  resource_group_name = "${azurerm_resource_group.vnet_gp.name}"
  address_space       = ["10.0.0.0/16"]
  tags = "${merge( local.common_tags)}"
  
  subnet {
    name           = "firewall"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.0.3.0/24"
  }

}
resource "azurerm_virtual_network" "spoke" {
  name                = "${var.prefix}spoke1-vnet"
  location            = "${azurerm_resource_group.vnet_gp.location}"
  resource_group_name = "${azurerm_resource_group.vnet_gp.name}"
  address_space       = ["11.0.0.0/16"]
  tags = "${merge( local.common_tags)}"
}
  
resource "azurerm_network_security_group" "spoke" {
  name                = "dremio-nsg"
  location            = "${azurerm_resource_group.vnet_gp.location}"
  resource_group_name = "${azurerm_resource_group.vnet_gp.name}"
  tags = "${merge( local.common_tags)}"

  security_rule {
    name                       = "UDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.189.3.0/24"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet" "spoke" {
  name                      = "provisiosvr"
  virtual_network_name      = "${azurerm_virtual_network.spoke.name}"
  resource_group_name       = "${azurerm_resource_group.vnet_gp.name}"
  address_prefix            = "11.0.1.0/24"
  #network_security_group_id = "${azurerm_network_security_group.spoke.id}"
}
resource "azurerm_subnet_network_security_group_association" "spoke" {
  subnet_id                 = "${azurerm_subnet.spoke.id}"
  network_security_group_id = "${azurerm_network_security_group.spoke.id}"
}
 
resource "azurerm_virtual_network_peering" "peer1" {
  name                      = "peer1to2"
  resource_group_name       = "${azurerm_resource_group.vnet_gp.name}"
  virtual_network_name      = "${azurerm_virtual_network.hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.spoke.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "peer2to1"
  resource_group_name       = "${azurerm_resource_group.vnet_gp.name}"
  virtual_network_name      = "${azurerm_virtual_network.spoke.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.hub.id}"
}


