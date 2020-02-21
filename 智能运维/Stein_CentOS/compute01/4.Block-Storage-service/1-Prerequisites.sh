#1
yum install lvm2 -y


#2
systemctl enable lvm2-lvmetad.service
systemctl restart lvm2-lvmetad.service


#3
pvcreate /dev/sdc

vgcreate cinder-volumes /dev/sdc

