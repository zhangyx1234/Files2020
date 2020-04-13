#1
openstack project list

#2
openstack project create --domain default \
  --description "Service Project" service

#3
openstack project create --domain default \
  --description "Demo Project" demo

openstack user create --domain default \
  --password capitek2019 demo

openstack role create user

openstack role add --project demo --user demo user

#4
openstack project list
openstack user list
openstack role list
