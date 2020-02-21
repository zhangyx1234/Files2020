#1
yum install openstack-glance -y

#2
#Edit the /etc/glance/glance-api.conf

#3
#Edit the /etc/glance/glance-registry.conf

#4
su -s /bin/sh -c "glance-manage db_sync" glance

#5
systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl restart openstack-glance-api.service openstack-glance-registry.service

#6
netstat -nap|grep ":9292"
