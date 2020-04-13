#1
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default


#2
openstack keypair list

openstack flavor list

openstack image list

openstack network list

openstack security group list


#3
openstack network create  --share --external \
  --provider-physical-network provider \
  --provider-network-type flat provider

openstack subnet create --network provider \
  --allocation-pool start=172.17.0.41,end=172.17.0.50 \
  --dns-nameserver 202.106.0.20 --gateway 172.17.0.1 \
  --subnet-range 172.17.0.0/24 provider


#4
openstack server create --flavor m1.nano --image cirros \
  --nic net-id=9d714c7d-bbcd-4ffd-bac0-b15ab378f73e --security-group default \
  provider-instance


#5
openstack server list
