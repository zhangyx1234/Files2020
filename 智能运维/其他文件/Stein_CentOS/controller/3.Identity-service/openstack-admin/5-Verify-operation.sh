unset OS_AUTH_URL OS_PASSWORD

openstack --os-auth-url http://controller2:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin --os-password capitek2019 token issue

openstack --os-auth-url http://controller2:5000/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name demo --os-username demo --os-password capitek2019 token issue
