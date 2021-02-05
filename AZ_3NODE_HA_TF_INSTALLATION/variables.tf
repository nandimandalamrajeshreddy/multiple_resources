# Prefix and Tags

variable "subscription_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}

variable "client_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}

variable "client_secret"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}
variable "tenant_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
    default     =   "HA-TFVARS-TEST"
}

# Resource Group

variable "location" {
    description =   "Location of the resource group"
    type        =   string
    default     =   "East US"
}


# Availability Set

variable "managed" {
    type    =   string
    default =   true
}

variable "platform_fault_domain_count" {
    type    =   string
    default =   3
}

# Vnet and Subnet

variable "vnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.100.0.0/16"
}



variable "subnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.100.1.0/24"
}



variable "lb_sku" {
    description = "Load balancer of the SKU"
    type        =   string
    default     = "Standard"
}

# Public IP and NIC Allocation Method

variable "allocation_method" {
   description =   "Allocation method for Public IP Address and NIC Private ip address"
   type        =   string
  default     =   "Static"
}




# Public IP and NIC Allocation Method

#variable "allocation_method" {
 #   description =   "Allocation method for Public IP Address and NIC Private ip address"
 #   type        =   string
 #   default     =   "Static"
#}


variable "allocation_methods" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
    default     =   "Dynamic"
}

variable "storage_account_name" {
    description = "Variables for Storage account name(Storage account name should be unique(Eg:saopsdf2)"
    default     = "cmp25sarmadryrun1"
}

variable "account_tier" {
    description  =  "Variables for Storage accounts and containers"
    type         =  string
    default      =  "Standard"
       
}


    
variable "account_replication_type" {
    description  =  "Variables for Storage accounts and containers"
    type         =  string
    default      =  "LRS"
      
}

variable "publicip_dns" {
    description = "variables for publicip dns name"
    default = "cmpham3node"
}

# VM 

variable "virtual_machine_size" {
    description =   "Size of the VM"
    type        =   string
    default     =   "Standard_D4s_v3"
}

variable "computer_name" {
    description =   "Computer name"
    type        =   string
    default     =   "cmpnode"
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
    default     =   "XXXXXXX"
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
    default     =   "XXXXXXXXXXX"
}

variable "os_disk_caching" {
    default     =       "ReadWrite"
}

variable "os_disk_storage_account_type" {
    default     =       "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
    default     =       700
}

variable "publisher" {
    default     =       "RedHat"
}

variable "offer" {
    default     =       "RHEL"
}

variable "sku" {
    default     =       "7.8"
}

variable "vm_image_version" {
    default     =       "latest"
}