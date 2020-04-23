#1
openstack user create --domain default --password-prompt cinder
openstack role add --project service --user cinder admin

#2
openstack service create --name cinderv2 \
--description "OpenStack Block Storage" volumev2
openstack service create --name cinderv3 \
--description "OpenStack Block Storage" volumev3

openstack endpoint create --region RegionOne \
volumev2 public http://controller2:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne \
volumev2 internal http://controller2:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne \
volumev2 admin http://controller2:8776/v2/%\(project_id\)s

openstack endpoint create --region RegionOne \
volumev3 public http://controller2:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne \
volumev3 internal http://controller2:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne \
volumev3 admin http://controller2:8776/v3/%\(project_id\)s

#3
openstack project list
openstack user list
openstack role list
openstack service list
openstack endpoint list