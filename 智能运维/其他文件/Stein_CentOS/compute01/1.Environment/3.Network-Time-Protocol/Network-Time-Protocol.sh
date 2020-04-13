#1
yum install chrony -y

#2
#Edit the /etc/chrony.conf file

#3
systemctl enable chronyd.service
systemctl restart chronyd.service
