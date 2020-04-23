#1
yum install openstack-neutron openstack-neutron-ml2 \
  openstack-neutron-linuxbridge ebtables -y


#2
#Edit the /etc/neutron/neutron.conf

#Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file

#Edit the /etc/neutron/plugins/ml2/linuxbridge_agent.ini

#Edit the /etc/neutron/l3_agent.ini file

#Edit the /etc/neutron/dhcp_agent.ini file

#Edit the /etc/neutron/metadata_agent.ini file

#Create the /etc/neutron/plugin.ini


#3
#Edit the /etc/nova/nova.conf file


#4
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron


#5
systemctl restart openstack-nova-api.service

systemctl enable neutron-server.service \
  neutron-linuxbridge-agent.service neutron-dhcp-agent.service \
  neutron-metadata-agent.service
systemctl restart neutron-server.service \
  neutron-linuxbridge-agent.service neutron-dhcp-agent.service \
  neutron-metadata-agent.service

systemctl enable neutron-l3-agent.service
systemctl restart neutron-l3-agent.service
