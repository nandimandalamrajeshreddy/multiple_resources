#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Create a Linux VM 
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = ">= 2.26"

  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id

  features {}
}


#
# - Create a Resource Group
#



resource "azurerm_resource_group" "rg" {
    name                  =   "${var.prefix}-rg"
    location              =   var.location
}


#
# - Create a Resource Group Level  restriction
#

resource "azurerm_management_lock" "policy" {
  name       = "${var.prefix}-policy"
  scope      = azurerm_resource_group.rg.id
  lock_level = var.lock_level
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

#resource "azurerm_subnet" "sn" {
#    name                  =   "${var.prefix}-sn-subnet"
#    resource_group_name   =   azurerm_resource_group.rg.name
#    virtual_network_name  =   azurerm_virtual_network.vnet.name
#    address_prefixes      =   [var.subnet_address_range]
#}

resource "azurerm_subnet" "sn" {
    name                  =   "${var.prefix}-private-subnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    virtual_network_name  =   azurerm_virtual_network.vnet.name
    address_prefixes      =   [var.public_subnet_range]
}

resource "azurerm_subnet" "publicsn" {
    name                  =   "${var.prefix}-public-subnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    virtual_network_name  =   azurerm_virtual_network.vnet.name
    address_prefixes      =   [var.private_subnet_range]
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
    priority                    =       100
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "TCP"
    source_port_range           =       "*"
    destination_port_range      =       "22"
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "x"
    
    }
    security_rule {
    name                        =       "Allow_HTTP"
    priority                    =       110
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "TCP"
    source_port_range           =       "*"
    destination_port_range      =       "80"
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "x"
    
    }
    security_rule {
    name                        =       "Allow_HTTPS"
    priority                    =       120
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "TCP"
    source_port_range           =       "*"
    destination_port_range      =       "443"
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "x"
    
    }
    security_rule {
    name                        =       "Allow_SQL"
    priority                    =       130
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "TCP"
    source_port_range           =       "*"
    destination_port_ranges     =       ["1433","53","67","68","445","902","903","8531","8400","8401","8403","161","3306","3389","135","5985","5986"]
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "x"
    
    }
    security_rule {
    name                        =       "Port_AppGateway"
    priority                    =       140
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "*"
    source_port_range           =       "*"
    destination_port_ranges     =       ["65200-65535"]
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "*"
    
    }
    security_rule {
    name                        =       "hyperwiser_ports"
    priority                    =       150
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "*"
    source_port_range           =       "*"
    destination_port_ranges     =       ["5900-6000"]
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "*"
    
    }
    security_rule {
    name                        =       "Allow_AzureMoniter_HTTPS"
    priority                    =       210
    direction                   =       "Outbound"
    access                      =       "Allow"
    protocol                    =       "TCP"
    source_port_range           =       "*"
    destination_port_range      =       "443"
    source_address_prefix       =       "x4" 
    destination_address_prefix  =       "*"
    
    }
    security_rule {
    name                        =       "Allow_AzureMoniter_HTTP"
    priority                    =       220
    direction                   =       "Outbound"
    access                      =       "Allow"
    protocol                    =       "TCP"
    source_port_range           =       "*"
    destination_port_range      =       "80"
    source_address_prefix       =       "x" 
    destination_address_prefix  =       "*"
    
    }
    security_rule {
    name                        =       "Allow_AzureMoniter_SQL"
    priority                    =       230
    direction                   =       "Outbound"
    access                      =       "Allow"
    protocol                    =       "TCP"
    source_port_range           =       "*"
    destination_port_range      =       "1433"
    source_address_prefix       =       "x" 
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



#
# - Subnet-NSG Association
#

resource "azurerm_subnet_network_security_group_association" "subnet-nsgpublic" {
    subnet_id                    =       azurerm_subnet.publicsn.id
    network_security_group_id    =       azurerm_network_security_group.nsg.id
}


#
# - Public IP (To Login to Linux VM)
#

resource "azurerm_public_ip" "pip" {
    name                            =     "${var.prefix}-linuxvm-public-ip"
    resource_group_name             =     azurerm_resource_group.rg.name
    location                        =     azurerm_resource_group.rg.location
    allocation_method               =     var.allocation_method
}


#
# - Create a Storage account with Network Rules
#

resource "azurerm_storage_account" "sa" {
    name                          =    var.storage_account_name
    resource_group_name           =    azurerm_resource_group.rg.name
    location                      =    azurerm_resource_group.rg.location
    account_tier                  =    var.account_tier
    account_replication_type      =    var.account_replication_type
}



#
# - Create a Network Interface Card for Virtual Machine
#

resource "azurerm_network_interface" "nic" {
    name                              =   "${var.prefix}-linuxvm-nic"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
  #  tags                              =   var.tags
    ip_configuration                  {
        name                          =  "${var.prefix}-nic-ipconfig"
        subnet_id                     =   azurerm_subnet.sn.id
        public_ip_address_id          =   azurerm_public_ip.pip.id
        private_ip_address_allocation =   var.allocation_methods
    }
}


#
# - Create a Linux Virtual Machine
# 

resource "azurerm_linux_virtual_machine" "vm" {
    name                              =   "${var.prefix}-linuxvm"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    availability_set_id               =   azurerm_availability_set.availability_set.id
    network_interface_ids             =   [azurerm_network_interface.nic.id]
    size                              =   var.virtual_machine_size
    computer_name                     =   var.computer_name
    admin_username                    =   var.admin_username
    admin_password                    =   var.admin_password
    disable_password_authentication   =   false

    os_disk  {
        name                          =   "${var.prefix}-linuxvm-os-disk"
        caching                       =   var.os_disk_caching
        storage_account_type          =   var.os_disk_storage_account_type
        disk_size_gb                  =   var.os_disk_size_gb
    }

    source_image_reference {
        publisher                     =   var.publisher
        offer                         =   var.offer
        sku                           =   var.sku
        version                       =   var.vm_image_version
    }



    provisioner "file" {
        source      = "cmp_morpheus_ansible.sh"
        destination = "/home/cmpadmin/cmp_morpheus_ansible.sh"

        connection {
            type     = "ssh"
            user     = var.admin_username
            password = var.admin_password
            host     = azurerm_public_ip.pip.ip_address
        }
    }

        provisioner "remote-exec" {
            connection {
                type     = "ssh"
                user     = var.admin_username
                password = var.admin_password
			    host     = azurerm_public_ip.pip.ip_address
            }

            inline = [
		    "chmod +x /home/cmpadmin/cmp_morpheus_ansible.sh",
			"sudo apt-get update",
            "sudo apt install dos2unix -y",
            "sudo dos2unix -b /home/cmpadmin/cmp_morpheus_ansible.sh",
            "/home/cmpadmin/cmp_morpheus_ansible.sh"
            ]
    }

}
