systemctl stop firewalld.service

systemctl restart chronyd.service

systemctl restart libvirtd.service openstack-nova-compute.service

systemctl restart neutron-linuxbridge-agent.service

systemctl restart openstack-cinder-volume.service target.service lvm2-lvmetad.service
