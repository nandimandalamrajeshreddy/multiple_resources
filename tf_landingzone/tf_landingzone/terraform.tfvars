#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Terraform - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
subscription_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
client_id       = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
client_secret   = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
tenant_id       = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
prefix="TERRAFORM_PIPELINE_TEST1"
location="East US"
lock_level="CanNotDelete"
managed=true
platform_fault_domain_count=2
vnet_address_range="xxxxx"
allocation_method="Static"
allocation_methods="Dynamic"
storage_account_name="cmp251tod"
account_tier="Standard"
account_replication_type="LRS"
virtual_machine_size="Standard_D4s_v3"
computer_name="Linuxvm"
admin_username="<<--admin_username-->>"
admin_password="<<--admin_password-->>"
os_disk_caching="ReadWrite"
os_disk_storage_account_type="StandardSSD_LRS"
os_disk_size_gb=64
publisher="Canonical"
offer="UbuntuServer"
sku="18.04-LTS"
vm_image_version="latest"
