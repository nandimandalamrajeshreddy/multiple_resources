variable "tags" {
    description     =   "Tags"
    type            =   map(string)
    default         =   {
        "Author"        =   "Rajesh"
        "Deployed_with" =   "Terraform"
    }
}

#
# - Resource Group Variables
#

variable "resource_group" {
    description     =       "Create multiple resource groups"
    type            =       map(string)
    default         =       {
        "Dev-RG"        =       "Central US"
        "QA-RG"         =       "West US"
        "Prod-RG"       =       "West Europe"
    }
}

#
# - Virtual Network Variables
#

variable "virtual_network" {
    description     =       "Virtual Network variables"
    type            =       map(string)
    default         =       {
        "name"              =       "Dev-Vnet"
        "address_range"     =       "10.0.0.0/16"
    }
}

#
# - Subnet Variables
#

variable "subnet" {
    description     =       "Create multiple subnets"
    type            =       map(string)
    default         =       {
        "Web-Subnet"    =       "10.0.1.0/24"
        "App-Subnet"    =       "10.0.2.0/24"
        "DB-Subnet"     =       "10.0.3.0/24"
    }
}
