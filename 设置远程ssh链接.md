1、设置远程连接

```
vi /etc/ssh/sshd_config

Port 22
PermitRootLogin yes
UsePAM yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

#systemctl restart sshd
```

2、创建云服务时设置密码

```
#!/bin/sh
passwd <<EOF
123456
123456
EOF
```

