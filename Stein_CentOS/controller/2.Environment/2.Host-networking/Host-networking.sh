#1
#Configure network

#2
sysctl -p

#3
systemctl disable firewalld.service
systemctl stop firewalld.service
