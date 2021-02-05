provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = ">= 2.26"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

resource "azurerm_resource_group" "rg" {
    name                  =   "${var.prefix}-rg"
    location              =   var.location
}

#
# - Create a Availability Set
#

resource "azurerm_availability_set" "availability_set" {
   name                          = "${var.prefix}-availability_set"
   location                      = azurerm_resource_group.rg.location
   resource_group_name           = azurerm_resource_group.rg.name
   managed                       = var.managed
   platform_fault_domain_count   = var.platform_fault_domain_count

}


#
# - Create a Virtual Network
#

resource "azurerm_virtual_network" "vnet" {
    name                  =   "${var.prefix}-vnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    location              =   azurerm_resource_group.rg.location
    address_space         =   [var.vnet_address_range]
}

#
# - Create a Subnet inside the virtual network
#

resource "azurerm_subnet" "sn" {
    name                  =   "${var.prefix}-sn-subnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    virtual_network_name  =   azurerm_virtual_network.vnet.name
    address_prefixes      =   [var.subnet_address_range]
}

resource "azurerm_public_ip" "pip" {
 name                         = "${var.prefix}-pip"
 location                     = azurerm_resource_group.rg.location
 resource_group_name          = azurerm_resource_group.rg.name
 allocation_method            = var.allocation_method
 sku                          = var.lb_sku
 domain_name_label            = var.publicip_dns
}


resource "azurerm_lb" "lb" {
 name                = "${var.prefix}-lb"
 location            = azurerm_resource_group.rg.location
 resource_group_name = azurerm_resource_group.rg.name
 sku                 = var.lb_sku
 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.pip.id
 }
}

resource "azurerm_lb_backend_address_pool" "lbap" {
  name                = "${var.prefix}-lbap"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lbprobe" {

  name                = "${var.prefix}-lbprobe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "TCP"
  port                = "80"
  interval_in_seconds = "5"
  number_of_probes    = "2"
}

resource "azurerm_lb_rule" "lbrule" {
  name                           = "${var.prefix}-lbrule"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "TCP"
  frontend_port                  = "443"
  backend_port                   = "443"
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lbap.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lbprobe.id
  load_distribution              = "SourceIP"
}

resource "azurerm_lb_nat_rule" "lbnatrule" {
  name                           = "${var.prefix}-lbnatrule"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "TCP"
  frontend_port                  = "22"
  backend_port                   = "22"
  frontend_ip_configuration_name = "PublicIPAddress"
}

#
# - Create a Network Security Group
#

resource "azurerm_network_security_group" "nsg" {
    name                        =       "${var.prefix}-web-nsg"
    resource_group_name         =       azurerm_resource_group.rg.name
    location                    =       azurerm_resource_group.rg.location


    security_rule {
    name                        =       "Allow_SSH"
    priority                    =       1000
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "*"
    source_port_range           =       "*"
    destination_port_range      =       "*"
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "*"
    
    }
}

#
# - Subnet-NSG Association
#

resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
    subnet_id                    =       azurerm_subnet.sn.id
    network_security_group_id    =       azurerm_network_security_group.nsg.id
}


resource "azurerm_storage_account" "sa" {
    name                          =    var.storage_account_name
    resource_group_name           =    azurerm_resource_group.rg.name
    location                      =    azurerm_resource_group.rg.location
    account_tier                  =    var.account_tier
    account_replication_type      =    var.account_replication_type
}


resource "azurerm_network_interface" "nic" {
    name                              =   "${var.prefix}-nic${count.index + 1}"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    count                             =   "3"

    ip_configuration                  {
        name                          =  "${var.prefix}-ipconfig-nic"
        subnet_id                     =   azurerm_subnet.sn.id
        private_ip_address_allocation =   var.allocation_methods
#       public_ip_address_id          =   azurerm_public_ip.pip[count.index].id
    }
}


resource "azurerm_network_interface_backend_address_pool_association" "bapa" {
    count                             =   "3"
 # network_interface_id    = azurerm_network_interface.nic[count.index].id
  network_interface_id    =  element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-ipconfig-nic"
 # ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbap.id
}


resource "azurerm_network_interface_nat_rule_association" "natruleassociation" {
  count      =  1
  #network_interface_id  = azurerm_network_interface.nic[count.index].id
  network_interface_id    =  element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name = "${var.prefix}-ipconfig-nic"
  nat_rule_id           = azurerm_lb_nat_rule.lbnatrule.id
}



#
# - Create a Linux Virtual Machine
# 

resource "azurerm_virtual_machine" "vm" {
    name                              =   "${var.prefix}-cmpnode-${count.index + 1}"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    availability_set_id               =   azurerm_availability_set.availability_set.id
    network_interface_ids             =   ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
    vm_size                           =   var.virtual_machine_size
    count                             =   "3"

    storage_os_disk  {
        name                          =   "${var.prefix}-cmpnode-os-disk-${count.index + 1}"
        caching                       =   var.os_disk_caching
        managed_disk_type             =   var.os_disk_storage_account_type
        create_option                 =   "FromImage"
        disk_size_gb                  =   var.os_disk_size_gb
    }

    storage_image_reference {
        publisher                     =   var.publisher
        offer                         =   var.offer
        sku                           =   var.sku
        version                       =   var.vm_image_version
    }
    os_profile {
        computer_name  = "${var.computer_name}-${count.index + 1}"
        admin_username = var.admin_username
        admin_password = var.admin_password
        
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}