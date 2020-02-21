#1
openstack user create --domain default --password capitek2019 nova
openstack role add --project service --user nova admin

#2
openstack service create --name nova \
  --description "OpenStack Compute" compute

openstack endpoint create --region RegionOne \
  compute public http://controller2:8774/v2.1

openstack endpoint create --region RegionOne \
  compute internal http://controller2:8774/v2.1

openstack endpoint create --region RegionOne \
  compute admin http://controller2:8774/v2.1

#3
openstack user create --domain default --password capitek2019 placement
openstack role add --project service --user placement admin

#4
openstack service create --name placement --description "Placement API" placement

openstack endpoint create --region RegionOne placement public http://controller2:8778

openstack endpoint create --region RegionOne placement internal http://controller2:8778

openstack endpoint create --region RegionOne placement admin http://controller2:8778

#5
openstack project list
openstack user list
openstack role list
openstack service list
openstack endpoint list

