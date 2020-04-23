#!/bin/bash
yum repository-packages centos-openstack-stein remove -y
yum repository-packages centos-ceph-nautilus remove -y
yum repository-packages centos-qemu-ev remove -y

yum remove openstack-cinder targetcli python-keystone -y
yum remove memcached python-memcached -y
yum remove rabbitmq-server -y
yum remove mariadb mariadb-server python2-PyMySQL -y
yum remove python-openstackclient openstack-selinux -y
yum remove chrony -y

yum list installed | grep stein
yum list installed | grep ceph
yum list installed | grep qemu

###danger
#lsblk -f
#vgremove cinder-volumes -y
#parted /dev/sdc mklabel gpt
#lsblk -f

###danger
rm -rf /var/lib/cinder
rm -rf /var/lib/neutron/
rm -rf /var/lib/nova/
rm -rf /var/lib/glance/
rm -rf /var/lib/keystone/
rm -rf /var/lib/rabbitmq/
rm -rf /var/lib/mysql
