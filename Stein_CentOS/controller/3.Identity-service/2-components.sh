#1
yum install openstack-keystone httpd mod_wsgi -y

#2
#Edit the /etc/keystone/keystone.conf file

#3
su -s /bin/sh -c "keystone-manage db_sync" keystone

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

keystone-manage bootstrap --bootstrap-password capitek2019 \
  --bootstrap-admin-url http://controller2:35357/v3/ \
  --bootstrap-internal-url http://controller2:5000/v3/ \
  --bootstrap-public-url http://controller2:5000/v3/ \
  --bootstrap-region-id RegionOne
