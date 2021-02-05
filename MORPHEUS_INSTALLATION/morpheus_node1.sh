APP_EXTERNAL_IP=`echo $(wget -qO - https://api.ipify.org)`
node1=`echo "$(cat /tmp/ip1)"`
node2=`echo "$(cat /tmp/ip2)"`
node3=`echo "$(cat /tmp/ip3)"`
node1nam='cmpnode-1'
node2nam='cmpnode-2'
node3nam='cmpnode-3'
pawd='XXXX5'


spinner()
{
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

#rpmfile='https://downloads.morpheusdata.com/files/morpheus-appliance-4.2.4-2.el7.x86_64.rpm'

#mkdir -p /home/cmpadmin/downloads/
#rm -rf /home/cmpadmin/downloads/*.*
#cd /home/cmpadmin/downloads/
#wget $rpmfile
#filename=$(ls /home/cmpadmin/downloads/)

#rm -rf /etc/morpheus/morpheus.rb

#rpm -ivh $filename

sleep 10 &
spinner

sed -e '/appliance_url/s/^/#/g' -i /etc/morpheus/morpheus.rb

echo "############################################################################################" >> /etc/hosts
cat >>/etc/hosts<<EOF
# BEGIN MORPHEUS AUTOMATED INSTALL MANAGED BLOCK
$node1 $node1nam
$node2 $node2nam
$node3 $node3nam
# END MORPHEUS AUTOMATED INSTALL MANAGED BLOCK
EOF
echo "############################################################################################" >> /etc/hosts

echo "############################################################################################" >> /etc/morpheus.rb
cat >>/etc/morpheus/morpheus.rb<<EOF
appliance_url 'https://$APP_EXTERNAL_IP'
elasticsearch['es_hosts'] = {'$node1' => 9200, '$node2' => 9200, '$node3' => 9200}
elasticsearch['node_name'] = '$node1'
elasticsearch['host'] = '0.0.0.0'
rabbitmq['host'] = '0.0.0.0'
rabbitmq['nodename'] = 'rabbit@$node1nam'
mysql['enable'] = false
mysql['host'] = '$node1'
mysql['morpheus_db'] = 'morpheus'
mysql['morpheus_db_user'] = 'morpheusDbUser'
mysql['morpheus_password'] = '$pawd'
EOF
echo "############################################################################################" >> /etc/morpheus.rb

morpheus-ctl reconfigure
sleep 140 &
spinner

source /root/.bashrc
sshpass -e scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /etc/morpheus/morpheus-secrets.json /opt/morpheus/embedded/rabbitmq/.erlang.cookie cmpadmin@cmpnode-2:/home/cmpadmin/
sshpass -e scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /etc/morpheus/morpheus-secrets.json /opt/morpheus/embedded/rabbitmq/.erlang.cookie cmpadmin@cmpnode-3:/home/cmpadmin/