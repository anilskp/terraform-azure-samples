
variable "vnetname" {
  description = "The prefix used for all resources in this example"
}
variable "subnetname"{}
variable "vnetresourcegroupname"{}
variable "newresourcegroupname" {}
variable "newservername" {}
variable "servercount" {}
variable "location" {
  default = "westeurope"  
  description = "The Azure location where all resources in this example should be created"
}
variable "Owner" {
}

variable "CC" {
  
}

variable "Environment" {
  
}


