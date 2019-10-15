


provider azurerm {
    subscription_id = "6513336d-7a7a-4542-9870-96badcfd3794"
    alias = "dev"
}



provider azurerm {
 # version = "=1.6.0"
   alias = "prod"
   subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
 # tenant_id = "..."
}

data "azurerm_virtual_network" "test1" {
  name                = "QRAZUREGRPVNET"
  provider            = "azurerm.dev"
  resource_group_name = "QRAZUREGRP"
}

data "azurerm_virtual_network" "prod" {
  name                = "qrspoke1-vnet"
  provider            = "azurerm.prod"
  resource_group_name = "qrnetwork-rg"
}

resource "azurerm_virtual_network_peering" "peer1" {
  name                      = "dpeer1to2"
  resource_group_name       = "${data.azurerm_virtual_network.test1.resource_group_name}"
  virtual_network_name      = "${data.azurerm_virtual_network.test1.name}"
  remote_virtual_network_id = "${data.azurerm_virtual_network.prod.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  provider = "azurerm.dev"
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "dpeer2to1"
  resource_group_name       = "${data.azurerm_virtual_network.prod.resource_group_name}"
  virtual_network_name      = "${data.azurerm_virtual_network.prod.name}"
  remote_virtual_network_id = "${data.azurerm_virtual_network.test1.id}"
  provider = "azurerm.prod"
}