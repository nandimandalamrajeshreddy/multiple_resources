#!/bin/bash
##################  CONFIG Section ###########################################################
PER_KEY="https://www.percona.com/downloads/RPM-GPG-KEY-percona"
PER_PKG="https://repo.percona.com/yum/percona-release-latest.noarch.rpm"
MYPAS="XXX@12345"
SSTPAS="XXX*12345"

################## CODE SECTION ################################
#    -------- Morpheus,Satellite,nfs  software installation Code below --------
################################################################

function run_cmd() {
#       echo -e "$(date "+%m%d%Y %T") : ------------ run command $1"
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
        run_cmd firewall-cmd --permanent --add-port={3306/tcp,4444/tcp,4567/tcp,4568/tcp}
        run_cmd firewall-cmd --reload
        run_cmd yum install -y policycoreutils-python.x86_64
        #Satellite resiter and morpheus,nfs,file space increasing installation
        run_cmd semanage port -m -t mysqld_port_t -p tcp 3306
        run_cmd semanage port -m -t mysqld_port_t -p tcp 4444
        run_cmd semanage port -m -t mysqld_port_t -p tcp 4567
        run_cmd semanage port -a -t mysqld_port_t -p tcp 4568
        run_cmd cat >>/home/cmpadmin/PXC.te<<EOF
module PXC 1.0;
require {
          type unconfined_t;
          type mysqld_t;
          type unconfined_service_t;
          type tmp_t;
          type sysctl_net_t;
          type kernel_t;
          type mysqld_safe_t;
          class process { getattr setpgid };
          class unix_stream_socket connectto;
          class system module_request;
          class file { getattr open read write };
          class dir search;
}

   #============= mysqld_t ==============

allow mysqld_t kernel_t:system module_request;
allow mysqld_t self:process { getattr setpgid };
allow mysqld_t self:unix_stream_socket connectto;
allow mysqld_t sysctl_net_t:dir search;
allow mysqld_t sysctl_net_t:file { getattr open read };
allow mysqld_t tmp_t:file write;
EOF
        run_cmd sed -i '$d' PXC.te
        run_cmd checkmodule -M -m -o PXC.mod PXC.te
        run_cmd semodule_package -o PXC.pp -m PXC.mod
        run_cmd semodule -i PXC.pp
        run_cmd wget ${PER_KEY} && rpm --import RPM-GPG-KEY-percona
        run_cmd yum install -y ${PER_PKG}
        run_cmd yum clean all
        run_cmd yum update -y --skip-broken
        run_cmd yum install -y Percona-XtraDB-Cluster-57
        run_cmd systemctl enable mysql
        run_cmd sleep 5
        run_cmd systemctl start mysql
        run_cmd sleep 20
        run_cmd echo "[client]" > /root/.my.cnf
        run_cmd echo "user=root" >> /root/.my.cnf
        run_cmd cat /var/log/mysqld.log | grep "temporary password" | awk 'NF>1{print $NF}' > /tmp/raw.dat
        run_cmd sed -i '2d;4d' /root/.my.cnf
        run_cmd echo "password=$(cat /tmp/raw.dat)" >> /root/.my.cnf >> /root/.my.cnf
        run_cmd sed -i '$d' /root/.my.cnf
        run_cmd chmod 400 /root/.my.cnf
        run_cmd sleep 30
sudo mysql  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYPAS}'" --connect-expired-password
        run_cmd sed -i '$d' /root/.my.cnf
        run_cmd echo "password=${MYPAS}" >> /root/.my.cnf
        run_cmd sed -i '$d' /root/.my.cnf
        run_cmd sleep 10
sudo mysql  -e "CREATE USER 'sstuser'@'localhost' IDENTIFIED BY '${SSTPAS}'"
sudo mysql  -e "GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost';"
sudo mysql  -e "FLUSH PRIVILEGES;"
        run_cmd systemctl stop mysql.service
        run_cmd sleep 30
        run_cmd cat >>/etc/my.cnf<<EOF
[mysqld]
pxc_encrypt_cluster_traffic=ON
max_connections = 300
wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
wsrep_cluster_name=morpheusdb-cluster
wsrep_cluster_address=gcomm://0.0.0.0,0.0.0.0,0.0.0.0
wsrep_node_name=morpheus-node01
wsrep_node_address=0.0.0.0
wsrep_sst_method=xtrabackup-v2
wsrep_sst_auth=sstuser:sstUserPassword
pxc_strict_mode=PERMISSIVE
wsrep_sync_wait=2
skip-log-bin
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
EOF
        run_cmd sed -i '$d' /etc/my.cnf
                run_cmd cat /tmp/ip1 /tmp/ip2  /tmp/ip3 > /tmp/raw.dat
        run_cmd sed -i '$d' /tmp/raw.dat
awk 'BEGIN { ORS = "," } { print }' /tmp/raw.dat > /tmp/cmpnode2.dat
echo "awk command ran sucessfully************"
#       run_cmd sed -i '$d' /tmp/cmpnode2.dat
        run_cmd truncate -s-1 /tmp/cmpnode2.dat
export gcomm=`echo gcomm://$(cat /tmp/cmpnode2.dat)`
        run_cmd sed -i 's|'gcomm://0.0.0.0,0.0.0.0,0.0.0.0'|'$gcomm'|' /etc/my.cnf
export wsrep=`echo wsrep_node_address=$(hostname -i)`
        run_cmd sed -i 's|'wsrep_node_address=0.0.0.0'|'$wsrep'|' /etc/my.cnf
export wsrepname=`echo wsrep_node_name=$(hostname)`
        run_cmd sed -i 's|'wsrep_node_name=morpheus-node01'|'$wsrepname'|' /etc/my.cnf
        run_cmd sed -i 's|'wsrep_sst_auth=sstuser:sstUserPassword'|'wsrep_sst_auth=sstuser:${SSTPAS}'|' /etc/my.cnf
        run_cmd rm -f /var/lib/mysql/ca.pem
        run_cmd rm -f /var/lib/mysql/server-cert.pem
        run_cmd rm -f /var/lib/mysql/server-key.pem
                run_cmd mv /tmp/ca.pem /var/lib/mysql/
                run_cmd mv /tmp/server-cert.pem /var/lib/mysql/
                run_cmd mv /tmp/server-key.pem /var/lib/mysql/
                run_cmd chown mysql:mysql /var/lib/mysql/ca.pem
                run_cmd chown mysql:mysql /var/lib/mysql/server-cert.pem
                run_cmd chown mysql:mysql /var/lib/mysql/server-key.pem
                run_cmd  sleep 10
        run_cmd systemctl start mysql.service

        echo "####################################################################################"
        echo -e "$(date "+%m%d%Y %T") : ------------ The Mysql software installed sucessfully on $a server"
        echo "####################################################################################"
