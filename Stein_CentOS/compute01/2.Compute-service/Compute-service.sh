#1
yum install openstack-nova-compute -y

#2
#Edit the /etc/nova/nova.conf file

#3
systemctl enable libvirtd.service openstack-nova-compute.service
systemctl restart libvirtd.service openstack-nova-compute.service
