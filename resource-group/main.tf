provider azurerm {
    subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
}

resource "azurerm_resource_group" "resource2_vnet_gp"{

name = "qrsimple-rg"
location = "westeurope"

tags = {
    Owner = "Anil"
  }
}
