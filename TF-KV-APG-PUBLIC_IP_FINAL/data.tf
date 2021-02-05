data "azurerm_resource_group" "rg" {
  name                = "XXXX"
}

data "azurerm_virtual_network" "vnet" {
  name                = "XXXX"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "sn" {
  name                = "XXXXX"
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name

}


data "azurerm_subnet" "sng" {
  name                = "XXXX"
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name

}

#data "azurerm_subnet" "publicsn" {
#  name                = "AZ_MP_BL_TF_ENRICH-sn-subnet2"
#  resource_group_name = data.azurerm_resource_group.rg.name
#  virtual_network_name = data.azurerm_virtual_network.vnet.name
#
#}