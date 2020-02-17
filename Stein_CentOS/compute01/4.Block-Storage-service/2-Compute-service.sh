#1
yum install openstack-cinder targetcli python-keystone -y

#2
#Edit the /etc/cinder/cinder.conf

#3
systemctl enable openstack-cinder-volume.service target.service
systemctl restart openstack-cinder-volume.service target.service