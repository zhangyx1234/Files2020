安装grafana

wget https://dl.grafana.com/oss/release/grafana-6.6.1-1.x86_64.rpm 
sudo yum localinstall grafana-6.6.1-1.x86_64.rpm

```
1、下载并安装 
#wget https://dl.grafana.com/oss/release/grafana-6.6.1-1.x86_64.rpm 
#sudo yum localinstall grafana-6.6.1-1.x86_64.rpm
2、启动
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
3、打开web
http://172.17.0.48:3000
```

