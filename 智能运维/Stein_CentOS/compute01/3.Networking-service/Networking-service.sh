#1
yum install openstack-neutron-linuxbridge ebtables ipset -y


#2
#Edit the /etc/neutron/neutron.conf file

#Edit the /etc/neutron/plugins/ml2/linuxbridge_agent.ini file


#3
#Edit the /etc/nova/nova.conf file


#4
systemctl restart openstack-nova-compute.service
systemctl enable neutron-linuxbridge-agent.service
systemctl restart neutron-linuxbridge-agent.service
