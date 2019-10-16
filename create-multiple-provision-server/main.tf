# to create a new provison server
provider azurerm {
    subscription_id = "11a0fcee-66ee-4603-b871-79d050820de1"
}

data "azurerm_subnet" "cps" {
  name                 = "${var.subnetname}"
  virtual_network_name = "${var.vnetname}"
  resource_group_name  = "${var.vnetresourcegroupname}"
}

resource "azurerm_resource_group" "cps"{

name     = "${var.newresourcegroupname}"
location = "${var.location}"

tags = {
    Owner = "${var.Owner}"
    Environment = "${var.Environment}"
    CC = "${var.CC}"
  }
}

resource "azurerm_managed_disk" "copy" {
  count = "${var.servercount}"
  name = "${var.newservername}-${count.index}-OSDisk"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cps.name}"
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

resource "azurerm_network_interface" "cps" {
  count               = "${var.servercount}"
  name                = "${var.newservername}-${count.index}-nic"
  location            = "${azurerm_resource_group.cps.location}"
  resource_group_name = "${azurerm_resource_group.cps.name}"
  #network_security_group_id = "${azurerm_network_security_group.dnsg.id}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.cps.id}"
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_virtual_machine" "cps" {
  count                 = "${var.servercount}"
  name                  = "${var.newservername}-${count.index}-vm"
  location              = "${azurerm_resource_group.cps.location}"
  resource_group_name   = "${azurerm_resource_group.cps.name}"
  network_interface_ids = ["${element(azurerm_network_interface.cps.*.id, count.index)}"]
  vm_size               = "Standard_DS1_v2"




  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true


  storage_os_disk {
    
    name              = "${var.newservername}-${count.index}-OSDisk"
    os_type           = "windows"
    managed_disk_id   = "${element(azurerm_managed_disk.copy.*.id, count.index)}"
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