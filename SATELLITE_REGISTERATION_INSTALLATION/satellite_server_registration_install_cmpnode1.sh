#!/bin/bash
##################  CONFIG Section ###########################################################
SATE_PKG="https://satellite.dev.cmp.unisys-waf.com/pub/katello-ca-consumer-latest.noarch.rpm"
MP_PKG="morpheus-appliance-5.2.2-1.el7.x86_64.rpm"
MP_URL_DN="https://downloads.morpheusdata.com/files/morpheus-appliance-5.2.2-1.el7.x86_64.rpm"
SSHPAS="XXX*12345"
##################  CONFIG Section ###########################################################

################## CODE SECTION ##############################################################
#    -------- Morpheus,Satellite,nfs  software installation --------
##############################################################################################

function run_cmd() {
#	echo -e "$(date "+%m%d%Y %T") : ------------ run command $1"
	RED='\033[0;31m'
	GR='\033[0;32m'
	NC='\033[0m' # No Color
	
	# Run Command string
	sudo ${@}
	
	# Get Return Status
	rc=$?
	
	if [ $rc -ne 0 ]
	then
		echo -e "$(date "+%m%d%Y %T") : ------------ Run command failed : ${@}"
		echo -e "$(date "+%m%d%Y %T") : ------------${RED} INSTALLATION FAILED : Admin intervention required ${NC}"
		echo -e "$(date "+%m%d%Y %T") : ------------${RED} INSTALLATION FAILED : Exiting installation ${NC}"
		exit 1;
	else
		echo -e "$(date "+%m%d%Y %T") : ------------${GR} Run Command Success ${NC} : ${@}"
	fi
	return $rc
}

	echo "####################################################################################"
	echo -e "$(date "+%m%d%Y %T") : ------------ The Satellite, Morpheus softwares start install"
	echo "####################################################################################"
	run_cmd yum update -y
	run_cmd hostname -i > /tmp/ip1
	run_cmd sed -i '2d' /tmp/ip1

	# Install yum-config-manager is enable
	run_cmd yum-config-manager --enable rhel-7-server-optional-rpms
	run_cmd cd /home/cmpadmin
	
	#Satellite resiter and morpheus,nfs,file space increasing installation
	run_cmd curl --insecure --output katello-ca-consumer-latest.noarch.rpm ${SATE_PKG}
	run_cmd yum localinstall katello-ca-consumer-latest.noarch.rpm -y
	run_cmd subscription-manager register --org="XXXX" --activationkey="XXXX-XXX" --force
	run_cmd subscription-manager repos  --enable="*"
	run_cmd yum -y install katello-host-tools
	
	run_cmd yum -y install katello-host-tools-tracer
	run_cmd yum -y install katello-agent
	run_cmd yum repolist all | grep "rhel-7-server-optional-rpms"
	run_cmd yum repolist all
	run_cmd lvextend -L+12G /dev/mapper/rootvg-optlv
	run_cmd xfs_growfs /dev/mapper/rootvg-optlv
	run_cmd lvextend -L+15G /dev/mapper/rootvg-varlv
	run_cmd xfs_growfs /dev/mapper/rootvg-varlv
	run_cmd lvextend -L+4G /dev/mapper/rootvg-homelv
	run_cmd xfs_growfs /dev/mapper/rootvg-homelv
	run_cmd yum install nfs-utils -y
	run_cmd yum update -y
	run_cmd wget ${MP_URL_DN}
	run_cmd rpm -ivh ${MP_PKG}
	run_cmd echo export SSHPASS=${SSHPAS} >> /root/.bashrc
	run_cmd sed -i '$d' /root/.bashrc
	run_cmd sleep 10
source /root/.bashrc
	run_cmd yum install sshpass -y
	run_cmd sleep 5
source /root/.bashrc
sshpass -e scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /tmp/ip1 cmpadmin@cmpnode-2:/tmp/
sshpass -e scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /tmp/ip1 cmpadmin@cmpnode-3:/tmp/
	echo "########################################################################################################"
	echo -e "$(date "+%m%d%Y %T") : ------------ The $a server registered in satellite server  sucessfully"
	echo -e "$(date "+%m%d%Y %T") : ------------ The Morpheus software installed on $a server"
	echo "########################################################################################################"