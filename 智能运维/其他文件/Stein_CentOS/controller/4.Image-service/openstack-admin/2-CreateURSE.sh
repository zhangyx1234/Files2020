#1
openstack user create --domain default --password capitek2019 glance
openstack role add --project service --user glance admin

#2
openstack service create --name glance \
  --description "OpenStack Image" image

#3
openstack endpoint create --region RegionOne \
  image public http://controller2:9292

openstack endpoint create --region RegionOne \
  image internal http://controller2:9292

openstack endpoint create --region RegionOne \
  image admin http://controller2:9292

#4
openstack project list
openstack user list
openstack role list
openstack service list
openstack endpoint list
