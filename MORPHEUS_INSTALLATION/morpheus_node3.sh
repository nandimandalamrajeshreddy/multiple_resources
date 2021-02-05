APP_EXTERNAL_IP=`echo $(wget -qO - https://api.ipify.org)`
node1=`echo "$(cat /tmp/ip1)"`
node2=`echo "$(cat /tmp/ip2)"`
node3=`echo "$(cat /tmp/ip3)"`
node1nam='cmpnode-1'
node2nam='cmpnode-2'
node3nam='cmpnode-3'
pawd='XXXXX'

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
elasticsearch['node_name'] = '$node3'
elasticsearch['host'] = '0.0.0.0'
rabbitmq['host'] = '0.0.0.0'
rabbitmq['nodename'] = 'rabbit@$node3nam'
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

sed -n '1,6p' /etc/morpheus/morpheus-secrets.json > /home/cmpadmin/mysqlsecret
sed -n '7,11p' /home/cmpadmin/morpheus-secrets.json > /home/cmpadmin/rabbitsecret
sed -n '12,15p' /etc/morpheus/morpheus-secrets.json > /home/cmpadmin/ajpsecret

cat /home/cmpadmin/mysqlsecret > /etc/morpheus/morpheus-secrets.json
cat /home/cmpadmin/rabbitsecret >> /etc/morpheus/morpheus-secrets.json
cat /home/cmpadmin/ajpsecret >> /etc/morpheus/morpheus-secrets.json

\cp -Rf /home/cmpadmin/.erlang.cookie /opt/morpheus/embedded/rabbitmq/
sleep 140 &
spinner
morpheus-ctl stop rabbitmq
sleep 140 &
spinner
morpheus-ctl reconfigure
sleep 140 &
spinner

morpheus-ctl stop rabbitmq
sleep 140 &
spinner

morpheus-ctl start rabbitmq
sleep 140 &
spinner
source /opt/morpheus/embedded/rabbitmq/.profile
sleep 10 &
spinner
rabbitmqctl stop_app
sleep 240 &
spinner
rabbitmqctl join_cluster rabbit@$node1nam
sleep 180 &
spinner
rabbitmqctl start_app
sleep 180 &
spinner
rabbitmqctl cluster_status
morpheus-ctl reconfigure
sleep 140 &
spinner

rabbitmqctl set_policy -p morpheus --apply-to queues --priority 2 statCommands "statCommands.*" '{"expires":1800000, "ha-mode":"all"}'
echo "Policy 1 set"
rabbitmqctl set_policy -p morpheus --apply-to queues --priority 2 morpheusAgentActions "morpheusAgentActions.*" '{"expires":1800000, "ha-mode":"all"}'
echo "Policy 2 set"
rabbitmqctl set_policy -p morpheus --apply-to queues --priority 2 monitorJobs "monitorJobs.*" '{"expires":1800000, "ha-mode":"all"}'
echo "Policy 3 set"
rabbitmqctl set_policy -p morpheus --apply-to all --priority 1 ha ".*" '{"ha-mode":"all"}'
echo "Policy 4 set"

morpheus-ctl restart morpheus-ui