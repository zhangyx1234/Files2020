## 一、无密钥对

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

## 二、有密钥对

```
1、登录controller节点   接入到云主机
#ssh -i def-ssh-key-testcloud.pem centos@172.17.0.41
2、切换到root用户
#sudo su root
3、修改密码
#passwd root
4、修改ssh
vi /etc/ssh/sshd_config

Port 22
PermitRootLogin yesreboot
UsePAM yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

5、重新启动ssh
#systemctl restart sshd

6、出现错误时链接不上
#ssh-keygen -R "你的远程服务器ip地址"  
```

