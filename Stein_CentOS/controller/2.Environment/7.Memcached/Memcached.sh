#1
yum install memcached python-memcached -y

#2


#3
systemctl enable memcached.service
systemctl restart memcached.service

#4
netstat -apn|grep -i ":11211"
