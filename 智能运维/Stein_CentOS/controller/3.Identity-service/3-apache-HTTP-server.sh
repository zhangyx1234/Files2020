#1
#Edit the /etc/httpd/conf/httpd.conf file

#2
#Create a /etc/httpd/conf.d/keystone/wsgi-keystone.conf file

#3
systemctl enable httpd.service
systemctl restart httpd.service

#4
netstat -apn|grep -i ":5000"
netstat -apn|grep -i ":35357"
