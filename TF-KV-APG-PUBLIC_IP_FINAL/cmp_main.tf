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
# - Create a Availability Set
#

resource "azurerm_availability_set" "availability_set" {
   name                          = "${var.prefix}-availability_set"
   location                      = data.azurerm_resource_group.rg.location
   resource_group_name           = data.azurerm_resource_group.rg.name
   managed                       = var.managed
   platform_fault_domain_count   = var.platform_fault_domain_count

}


#
# - Public IP (To Login to Linux VM)
#

resource "azurerm_public_ip" "pip" {
    name                            =     "${var.prefix}-linuxvm-public-ip"
    resource_group_name             =     data.azurerm_resource_group.rg.name
    location                        =     data.azurerm_resource_group.rg.location
    allocation_method               =     var.allocation_method
    sku                             =     "Standard"
}

#
# - Create a Storage account with Network Rules
#

resource "azurerm_storage_account" "sa" {
    name                          =    var.storage_account_name
    resource_group_name           =    data.azurerm_resource_group.rg.name
    location                      =    data.azurerm_resource_group.rg.location
    account_tier                  =    var.account_tier
    account_replication_type      =    var.account_replication_type
}



#
# - Create a Network Interface Card for Virtual Machine
#

resource "azurerm_network_interface" "nic" {
    name                              =   "${var.prefix}-linuxvm-nic"
    resource_group_name               =   data.azurerm_resource_group.rg.name
    location                          =   data.azurerm_resource_group.rg.location
  #  tags                              =   var.tags
    ip_configuration                  {
        name                          =  "${var.prefix}-nic-ipconfig"
        subnet_id                     =   data.azurerm_subnet.sn.id
#        public_ip_address_id          =   azurerm_public_ip.pip.id
        private_ip_address_allocation =   var.allocation_methods
    }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nicbap" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "${var.prefix}-nic-ipconfig"
  backend_address_pool_id = azurerm_application_gateway.agw.backend_address_pool[0].id
}

#resource "tls_private_key" "private_key_ssh" {
#  algorithm = "RSA"
#  rsa_bits = 4096
#}

#resource "local_file" "private_key_pem" {
#   filename   = "cmpadmin.pem"
#   file_permission = "400"
#   content     = tls_private_key.private_key_ssh.private_key_pem
#}

#resource "local_file" "public_key_pem" {
#   filename   = "cmpadmin_pub.pem"
#   file_permission = "400"
#   content     = tls_private_key.private_key_ssh.public_key_openssh
#}

#
# - Create a Linux Virtual Machine
# 

resource "azurerm_linux_virtual_machine" "vm" {
    name                              =   "${var.prefix}-linuxvm"
    resource_group_name               =   data.azurerm_resource_group.rg.name
    location                          =   data.azurerm_resource_group.rg.location
    availability_set_id               =   azurerm_availability_set.availability_set.id
    network_interface_ids             =   [azurerm_network_interface.nic.id]
    size                              =   var.virtual_machine_size
    computer_name                     =   var.computer_name
    admin_username                    =   var.admin_username
    admin_password                    =   var.admin_password
    disable_password_authentication   =   false

    #admin_ssh_key {
    #     username   = var.admin_username
    #     public_key = tls_private_key.private_key_ssh.public_key_openssh
    #}
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
}

resource "azurerm_virtual_machine_extension" "vmext" {
  name                               =   "LinuxVM-RunScripts"
  virtual_machine_id                 =   azurerm_linux_virtual_machine.vm.id
  publisher                          =   "Microsoft.Azure.Extensions"
  type                               =   "CustomScript"
  type_handler_version               =   "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("cmp_morpheus_ansible.sh", {publicip="${azurerm_public_ip.pip.ip_address}"}))}"
    }
SETTINGS

}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = "cmpapplicationgatecerts"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "purge",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }
}

resource "azurerm_key_vault_certificate" "kvcert" {
  name         = "generated-applgwcerts"
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["sinaglenodemorpheusgw.com"]
      }

      subject            = "CN=sinaglenodemorpheusgw.com"
      validity_in_months = 12
    }
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [azurerm_key_vault_certificate.kvcert]

  create_duration = "60s"
}

# -
# - Managed Service Identity
# -

resource "azurerm_user_assigned_identity" "agw" {
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "${local.prefix}-hub-agw1-msi"
}

resource "azurerm_key_vault_access_policy" "kvap" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.agw.principal_id

  secret_permissions = [
    "get"
  ]
}






# -
# - Variables
# -

locals {
  prefix   = "singlenodeapgw"
  rg_name  = "mygroup1" #An existing Resource Group for the Application Gateway 
  sku_name = "WAF_v2" #Sku with WAF is : WAF_v2
  sku_tier = "WAF_v2"
  zones    = ["2"] #Availability zones to spread the Application Gateway over. They are also only supported for v2 SKUs.
  capacity = {
    min = 1 #Minimum capacity for autoscaling. Accepted values are in the range 0 to 100.
    max = 3 #Maximum capacity for autoscaling. Accepted values are in the range 2 to 125.
  }
  #subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/virtualNetworks/myvnet1/subnets/mysubnet1" #Fill Here a dedicated subnet if for the Application Gateway

  appname = "cmp"
  backend_address_pool = {
    name  = "${local.appname}-pool1"
    fqdns = ["sinaglenodemorpheusgw.com"]
  }
  frontend_port_name             = "${local.appname}-feport"
  frontend_ip_configuration_name = "${local.appname}-feip"
  http_setting_name              = "${local.appname}-be-htst"
  listener_name                  = "${local.appname}-httplstn"
  request_routing_rule_name      = "${local.appname}-rqrt"
  redirect_configuration_name    = "${local.appname}-rdrcfg"
}



# -
# - Application Gateway
# -

resource "azurerm_application_gateway" "agw" {
  depends_on          = [azurerm_key_vault_certificate.kvcert, time_sleep.wait_60_seconds]
  name                = "${local.prefix}-hub-agw-test"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  enable_http2        = true
  zones               = local.zones
  tags                = data.azurerm_resource_group.rg.tags

  sku {
    name = local.sku_name
    tier = local.sku_tier
  }

  autoscale_configuration {
    min_capacity = local.capacity.min
    max_capacity = local.capacity.max
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }


  waf_configuration {
    enabled  = true
	  firewall_mode = "Prevention"
	  rule_set_type = "OWASP"
	  rule_set_version = "3.0"
  }
  gateway_ip_configuration {
    name      = "${local.prefix}-hub-agw1-ip-configuration"
    subnet_id = data.azurerm_subnet.sng.id
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}-public"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  frontend_port {
    name = "${local.frontend_port_name}-80"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-443"
    port = 443
  }

  backend_address_pool {
    name  = local.backend_address_pool.name
  }

  ssl_certificate {
    name                = azurerm_key_vault_certificate.kvcert.name
    key_vault_secret_id = azurerm_key_vault_certificate.kvcert.secret_id
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
   # host_name             = local.backend_address_pool.fqdns[0]
    request_timeout       = 20
  }

  http_listener {
    name                           = "${local.listener_name}-http"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-public"
    frontend_port_name             = "${local.frontend_port_name}-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "${local.listener_name}-https"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-public"
    frontend_port_name             = "${local.frontend_port_name}-443"
    protocol                       = "Https"
    ssl_certificate_name           = azurerm_key_vault_certificate.kvcert.name
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}-https"
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}-https"
    backend_address_pool_name  = local.backend_address_pool.name
    backend_http_settings_name = local.http_setting_name
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = "${local.listener_name}-https"
  }

  request_routing_rule {
    name                        = "${local.request_routing_rule_name}-http"
    rule_type                   = "Basic"
    http_listener_name          = "${local.listener_name}-http"
    redirect_configuration_name = local.redirect_configuration_name
  }
}