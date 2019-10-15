
# Create a Virtual machine in an existing Subnet 
# Also create an Network Security group with basic rules

provider azurerm {
    subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
}

resource "azurerm_resource_group" "main"{

name     = "${var.prefix}cluster-rg"
location = "${var.location}"

tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}


resource "azurerm_managed_disk" "copy" {
  name = "ProvisionOsDisk1"
  location = "West Europe"
  resource_group_name = "${azurerm_resource_group.main.name}"
  storage_account_type = "Standard_LRS"
  create_option = "Copy"
  source_resource_id = "/subscriptions/6513336d-7a7a-4542-9870-96badcfd3794/resourceGroups/qrazaniltest/providers/Microsoft.Compute/snapshots/azure-provision-server-disk01"
  disk_size_gb = "127"

tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}


resource "azurerm_network_security_group" "dnsg" {
  name                = "dremio-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "rule1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}

data "azurerm_subnet" "snet" {
  name                 = "${var.dremiosubnet}"
  virtual_network_name = "${var.spoke1vnet}"
  resource_group_name  = "qrnetwork-rg"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}001-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.snet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}001-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true


  storage_os_disk {
    name              = "${azurerm_managed_disk.copy.name}"
    os_type           = "windows"
    managed_disk_id   = "${azurerm_managed_disk.copy.id}"
    create_option     = "Attach"
  }	

#  os_profile {
#    computer_name  = "hostname"
#    admin_username = "testadmin"
#    admin_password = "Password1234!"
# }


 

  tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }

  
}