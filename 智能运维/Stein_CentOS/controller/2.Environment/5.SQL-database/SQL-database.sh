#1
yum install mariadb mariadb-server python2-PyMySQL -y

#2
#Edit the /etc/my.cnf.d/openstack.cnf file

#3
systemctl enable mariadb.service
systemctl restart mariadb.service

#4
mysql_secure_installation

#5
netstat -apn|grep -i ":3306"
