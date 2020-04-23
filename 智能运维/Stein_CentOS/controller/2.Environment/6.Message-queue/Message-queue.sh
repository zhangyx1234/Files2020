#1
yum install rabbitmq-server -y

#2
systemctl enable rabbitmq-server.service
systemctl restart rabbitmq-server.service

#3
rabbitmqctl add_user openstack capitek2019
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

#4
rabbitmqctl list_users
rabbitmqctl list_permissions
rabbitmqctl list_user_permissions openstack

#5
netstat -apn|grep -i ":5672"
