#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Terraform - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
subscription_id = "XXXXXXXXXXXXXXXXXXXXX"
client_id       = "XXXXXXXXXXXXXXXXXXXXXXXXXX"
client_secret   = "XXXXXXXXXXXXXXXXXXXXXXXX"
tenant_id       = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
prefix="TF_VAULT_APGW"
#location="East US"
#lock_level="CanNotDelete"
managed=true
platform_fault_domain_count=2
#vnet_address_range="XXXXXXXXXXXXXXX"
allocation_method="Static"
allocation_methods="Dynamic"
storage_account_name="bxd175sfg"
account_tier="Standard"
account_replication_type="LRS"
virtual_machine_size="Standard_B4ms"
computer_name="Linuxvm"
admin_username="cmpadmin"
admin_password="XXXX*12345"
os_disk_caching="ReadWrite"
os_disk_storage_account_type="StandardSSD_LRS"
os_disk_size_gb=64
publisher="Canonical"
offer="UbuntuServer"
sku="18.04-LTS"
vm_image_version="latest"
#private_key_path="~/.ssh/id_rsa"
