#1
yum install openstack-cinder -y


#2
#Edit the /etc/cinder/cinder.conf



#3
#Edit the /etc/nova/nova.conf


#4
su -s /bin/sh -c "cinder-manage db sync" cinder


#5
systemctl restart openstack-nova-api.service

systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service
