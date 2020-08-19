#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Create a Linux VM
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = ">= 2.20"

  subscription_id = "528db867-aafd-4420-b517-2e2863ca7305"
  client_id       = "d2ee82e7-0f2a-40e3-ac32-c18f4b46dad3"
  client_secret   = "sZAD2ynOXzJP~4~i6HISVnkB5aKr~k-By6"
  tenant_id       = "8d894c2b-238f-490b-8dd1-d93898c5bf83"

  features {}
}


resource "azurerm_resource_group" "rg" {
    for_each              =   var.resource_group
    name                  =   each.key
    location              =   each.value
    tags                  =   var.tags
}

#
# - Create a Virtual Network
#


resource "azurerm_virtual_network" "vnet" {
  resource_group_name   =   azurerm_resource_group.rg["Dev-RG"].name
  name                  =   var.virtual_network["name"]
  location              =   azurerm_resource_group.rg["Dev-RG"].location
  address_space         =   [var.virtual_network["address_range"]]
  tags                  =   var.tags
}


#
# - Create multiple Subnets inside the virtual network
#

resource "azurerm_subnet" "sn" {
   for_each             =   var.subnet
   name                 =   each.key
   resource_group_name  =   azurerm_resource_group.rg["Dev-RG"].name
   virtual_network_name =   azurerm_virtual_network.vnet.name
   address_prefixes     =   [each.value]
}
