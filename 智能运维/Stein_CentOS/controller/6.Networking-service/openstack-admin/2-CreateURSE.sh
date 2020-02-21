#1
openstack user create --domain default --password capitek2019 neutron
openstack role add --project service --user neutron admin

#2
openstack service create --name neutron \
  --description "OpenStack Networking" network

openstack endpoint create --region RegionOne \
  network public http://controller2:9696

openstack endpoint create --region RegionOne \
  network internal http://controller2:9696

openstack endpoint create --region RegionOne \
  network admin http://controller2:9696

#3
openstack project list
openstack user list
openstack role list
openstack service list
openstack endpoint list

