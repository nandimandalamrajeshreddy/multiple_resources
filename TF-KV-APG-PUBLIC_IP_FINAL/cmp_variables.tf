#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Linux VM - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

# Prefix and Tags

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
    default     =   "CMP25"
}



# Availability Set

variable "managed" {
    type    =   string
    default =   true
}

variable "platform_fault_domain_count" {
    type    =   string
    default =   2
}


# Public IP and NIC Allocation Method

variable "allocation_method" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
    default     =   "Static"
}


variable "allocation_methods" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
    default     =   "Dynamic"
}

# Storage 

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

# VM 

variable "virtual_machine_size" {
    description =   "Size of the VM"
    type        =   string
    default     =   "Standard_D4s_v3"
}

variable "computer_name" {
    description =   "Computer name"
    type        =   string
    default     =   "Linuxvm"
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
    default     =   "cmpadmin"
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
    default     =   "XX*XX"
}

variable "os_disk_caching" {
    default     =       "ReadWrite"
}

variable "os_disk_storage_account_type" {
    default     =       "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
    default     =       64
}

variable "publisher" {
    default     =       "Canonical"
}

#variable "private_key_path" {
#    default     =       "~/.ssh/id_rsa"
#}

variable "offer" {
    default     =       "UbuntuServer"
}

variable "sku" {
    default     =       "18.04-LTS"
}

variable "vm_image_version" {
    default     =       "latest"
}

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
