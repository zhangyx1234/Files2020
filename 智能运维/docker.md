## 1、安装docker

```
#安装必要的工具
#yum install -y yum-utils device-mapper-persistent-data lvm2

#添加源
#yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#安装docker-ce
#yum makecache fast
#yum -y install docker-ce

#启动docker
#systemctl start docker

#修改配置，去ip冲突
#vi /etc/docker/daemon.json
{
  "bip": "172.20.0.1/16"
}

{
  "exec-opts": ["native.cgroupdriver=systemd"]
}

#systemctl restart docker

```

## 2、安装prometheus

1）prometheus安装

Prometheus 默认配置文件 prometheus.yml 在容器内路径为 /etc/prometheus/prometheus.yml

```
# docker run --name prometheus -d -p 9090:9090 prom/prometheus:latest
```

2）node-exporter安装

```
#docker run --name node-exporter -d -p 9100:9100 prom/node-exporter:latest
```



```
# docker run --name prometheus -d -p 9090:9090 prom/prometheus:latest
#Prometheus 默认配置文件 prometheus.yml 在容器内路径为 /etc/prometheus/prometheus.yml

#docker pull prom/prometheus

#启动node-exporter
#docker run -d -p 9100:9100 \
  -v "/proc:/host/proc:ro" \
  -v "/sys:/host/sys:ro" \
  -v "/:/rootfs:ro" \
  --net="host" \
  prom/node-exporter
# 查看端口 
#netstat -anpt
#访问 http://<ip>:9100/metrics

#启动promtheus
#mkdir /root/prom
#vi /root/prom/prometheus.yml

global:
  scrape_interval:     60s
  evaluation_interval: 60s
 
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
        labels:
          instance: prometheus
 
  - job_name: linux
    static_configs:
      - targets: ['172.17.0.10:9100','172.17.0.11:9100','172.17.0.12:9100']
        labels:
          instance: linux
 
  - job_name: mysql
    static_configs:
      - targets: ['172.17.0.10:9104',]
        labels:
          instance: mysql
 
  - job_name: 'file_ds'
    file_sd_configs:
      - files:
        - /etc/prometheus/file_ds_server.json
        refresh_interval: 10s
        labels:
          instance: file_ds
 
  - job_name: pushgateway
    static_configs:
      - targets: ['172.17.0.47:9091',]
        labels:
          instance: pushgateway   
           
#启动prometheus
docker run  -d \
  -p 9090:9090 \
  -v /root/prom/prometheus.yml:/etc/prometheus/prometheus.yml  \
  -v /root/prom/file_ds.json:/etc/prometheus/file_ds.json \
  prom/prometheus
```

```
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s

alerting:
  alertmanagers:
  - static_configs:
    - targets: [172.17.0.47:]

scrape_configs:
- job_name: 'prometheus'
  static_configs:
  - targets:
    - localhost:9090
    
  - job_name: 'linux'
    static_configs:
      - targets: ['172.17.0.10:9100','172.17.0.11:9100','172.17.0.12:9100']
 
  - job_name: 'mysql'
    static_configs:
      - targets: ['172.17.0.10:9104']
 
  - job_name: 'file_ds'
    file_sd_configs:
      - files:
        - /etc/prometheus/file_ds_server.json
        refresh_interval: 10s
 
  - job_name: 'pushgateway'
    static_configs:
      - targets: ['172.17.0.47:9091']
```

