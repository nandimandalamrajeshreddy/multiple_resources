#!/bin/bash
##################  CONFIG Section #############
#MP_PKG="morpheus-appliance_5.2.2-1_amd64.deb"
#MP_URL_DN="https://downloads.morpheusdata.com/files/"
echo "${publicip}" > /tmp/publicip.dat

echo "####################################################################################"
echo -e "$(date "+%m%d%Y %T") : ------------ The Ansible, Morpheus softwares start install"
echo "####################################################################################"
sudo apt-get update -y
# Install Ansible and Morpheus Packages
sudo wget "https://downloads.morpheusdata.com/files/morpheus-appliance_5.2.2-1_amd64.deb"
sudo dpkg -i morpheus-appliance_5.2.2-1_amd64.deb
# Configure Morpheus with Custom onfigurations
sudo morpheus-ctl reconfigure
export APP_EXTERNAL_IP=`echo https://$(cut -d " " -f 1 /tmp/publicip.dat)`
sudo sed -i 's|'https://Linuxvm'|'$APP_EXTERNAL_IP'|' /etc/morpheus/morpheus.rb
#Reconfigure Morpheus with updated URL
sudo morpheus-ctl reconfigure
sudo morpheus-ctl stop morpheus-ui
sudo morpheus-ctl start morpheus-ui
sudo morpheus-ctl status morpheus-ui
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get install -y python-requests
sudo apt-get install ansible -y
sudo chown morpheus-local.morpheus-local /opt/morpheus/.local/.ansible
sudo mkdir /opt/morpheus/.ansible
sudo chown morpheus-local.morpheus-local /opt/morpheus/.ansible
sudo mkdir /tmp/rajesh
echo "####################################################################################"
echo -e "$(date "+%m%d%Y %T") : ------------ The Ansible, Morpheus softwares are installed sucessfully on $a server"
echo "####################################################################################"
#}