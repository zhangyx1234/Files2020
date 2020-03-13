[TOC]

## 1、**Prometheus**自动发现被监控节点的配置方法？即图中的discover targets的file_sd方式

##### 1）创建json文件

```
#vi /usr/local/prometheus/file_ds_server.json
[
  {
    "targets":  ["172.17.0.10:9100"]
  }
]
```

##### 2）在prometheus配置文件中添加新的job

```
   ...
   - job_name: 'file_sd'
    file_sd_configs:
      - files:
        - /usr/local/prometheus/file_sd.json file
        refresh_interval: 10s
   ...

#注：因为配置文件有修改需要重新启动prometheus服务器
```

##### 3）有新的metrics节点加入时直接修改在json文件添加

```
#vi /usr/local/prometheus/file_ds_server.json
[
  {
    "targets":  ["172.17.0.10:9100","172.17.0.10:9100","172.17.0.10:9100"]
  }
]
```

##### 4）重新加载targets能够发现新的监控节点已经加入，无需重启服务器

添加前：

![avatar](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200303144303293.png)

添加后：

![avatar](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200303145039737.png)

注：webAPI：http://172.17.0.41:9090/



## 2、找一个Short-lived Jobs的示例，配置其向**Pushgateway**推送监控指标？

##### 1）安装pushgateway

```
#docker pull prom/pushgateway
#docker run -d   -p 9091:9091   prom/pushgateway

#访问http://172.17.0.41:9091
```

##### 2） 在prometheus配置文件中添加pushgateway

```
  ...
  - job_name: pushgateway
    static_configs:
      - targets: ['172.17.0.41:9091']
        labels:
          instance: pushgateway
  ...
```

##### 3）API的方式Push数据到pushgateway

 		Push 数据到 PushGateway 中，可以通过其提供的 API 标准接口来添加，默认 URL 地址为：http://<ip>:9091/metrics/job/<JOBNAME>{/<LABEL_NAME>/<LABEL_VALUE>}，

​	其中 <JOBNAME> 是必填项，为 job 标签值，后边可以跟任意数量的标签对，一般我们会添加一个 instance/<INSTANCE_NAME> 实例名称标签，来方便区分各个指标。
​	接下来，可以 Push 一个简单的指标数据到 PushGateway 中测试一下。

```
#向 {job="some_job"} 添加单条数据：
#echo "some_metric 3.14" | curl --data-binary @- http://172.17.0.41:9091/metrics/job/some_job

#添加更多更复杂数据，通常数据会带上 instance, 表示来源位置：
cat <<EOF | curl --data-binary @- http://172.17.0.41:9091/metrics/job/some_job/instance/some_instance
# TYPE some_metric counter
some_metric{label="val1"} 42
# TYPE another_metric gauge
# HELP another_metric Just an example.
another_metric 2398.283
EOF

cat <<EOF | curl --data-binary @- http://172.17.0.41:9091/metrics/job/some_job/instance/some_instance
some_metric{label="val1"} 42
another_metric 2398.283
EOF

#删除某个组下的某实例的所有数据：
 curl -X DELETE http:/172.17.0.41:9091/metrics/job/some_job/instance/some_instance

#删除某个组下的所有数据：
curl -X DELETE http://172.17.0.41:9091/metrics/job/some_job
```

##### 4）数据push成功截图

![avatar](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200306154218288.png)

## 3、对**AlertManager**进行配置，将告警发送到邮件方式，提供部署配置说明

##### 1）启动AlertManager

```
$ docker run --name alertmanager -d -p 9093:9093 prom/alertmanager:latest
```

​	AlertManager 默认启动的端口为 `9093`，启动完成后，浏览器访问 `http://172.17.0.47:9093` 可以看到默认提供的 UI 页面

##### 2）告警配置说明

​	AlertManager 默认配置文件为 `alertmanager.yml`，容器内路径为 `/etc/alertmanager/alertmanager.yml`

```
#docker exec -it  alertmanager  /bin/sh
#cat /etc/altermanager/alertmanager.yml

global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://172.17.0.123:5001/'
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']

```

主要配置的作用：

- global: 全局配置，包括报警解决后的超时时间、SMTP 相关配置、各种渠道通知的 API 地址等等。
- route: 用来设置报警的分发策略，它是一个树状结构，按照深度优先从左向右的顺序进行匹配。
- receivers: 配置告警消息接受者信息，例如常用的 email、wechat、slack、webhook 等消息通知方式。
- inhibit_rules: 抑制规则配置，当存在与另一组匹配的警报（源）时，抑制规则将禁用与一组匹配的警报（目标）。

##### 3）配置一下使用 Email 方式通知报警信息，这里以 163 邮箱为例，配置如下：

```
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.163.com:25'
  smtp_auth_username: '15933356856@163.com'
  smtp_from: '15933356856@163.com'
  smtp_auth_password: 'zyx1226'
  smtp_require_tls: false
route:
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 5s
  repeat_interval: 5m
  receiver: 'mail'
receivers:
- name: 'mail'
  email_configs:
  - to: '431062912@qq.com'
    send_resolved: true
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']    
 
```

关键的配置说明一下：

- smtp_smarthost: 这里为邮箱 SMTP 服务地址，同时要设置开启 POP3/SMTP 服务。

- smtp_auth_password: 这里为第三方登录 邮箱的授权码。

- smtp_require_tls: 是否使用 tls，根据环境不同，来选择开启和关闭。如果提示报错 email.loginAuth failed: 530 Must issue a STARTTLS command first，那么就需要设置为 true。着重说明一下，如果开启了 tls，提示报错 starttls failed: x509: certificate signed by unknown authority，需要在 email_configs 下配置 insecure_skip_verify: true 来跳过 tls 验证。

  

##### 4）修改AlertManager启动命令，将本地的alertmanager.yml文件挂载到容器内指定位置

```
#docker run -d   \
	--name alertmanager \
	-p 9093:9093  \
	-v /root/prom/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
	prom/alertmanager:latest

```

##### 5）需要在 Prometheus 配置 AlertManager 服务地址以及告警规则

新建报警规则文件 `node-up.rules` 如下：

```
$ mkdir -p /root/prometheus/rules && cd /root/prometheus/rules/
$ vim node-up.rules
groups:
- name: node-up
  rules:
  - alert: node-up
    expr: up{job="node-exporter"} == 0
    for: 15s
    labels:
      severity: 1
      team: node
    annotations:
      summary: "{{ $labels.instance }} 已停止运行超过 15s！"

$ vim 2.yml
groups:
- name: node-up
  rules:
  - alert: node-up
    expr: up{job="node-exporter"} == 0
    for: 15s
    labels:
      severity: 1
      team: node
    annotations:
      summary: 
        {
            "msgtype": "text",
            "text": {
                "content": "{{ $labels.instance }} 已停止运行超过 15s！"
             }
        }




```

**说明一下**：该 rules 目的是监测 node 是否存活，expr 为 PromQL 表达式验证特定节点 job="node-exporter" 是否活着，for 表示报警状态为 Pending 后等待 15s 变成 Firing 状态，一旦变成 Firing 状态则将报警发送到 AlertManager，labels 和 annotations 对该 alert 添加更多的标识说明信息，所有添加的标签注解信息，以及 prometheus.yml 中该 job 已添加 label 都会自动添加到邮件内容中

##### 6） 修改 `prometheus.yml` 配置文件，添加 rules 规则文件

```
...
# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - 172.317.0.47:9093

rule_files:
  - "/usr/local/prometheus/rules/*.rules"
...
```

##### 7）Prometheus 重启服务并停止node-exporter

```
#systemctl restart prometheus  # prometheus服务机

#docker stop   node-exporter    # node 监控主机执行
```

##### 8）QQ邮箱收到告警截图

![avatar](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200306151423745.png)



## 4、对**AlertManager**进行配置，将告警发送到微信方式，提供部署配置说明

##### 1）配置yml文件

```
#vi  /root/prom/alertmanager.yml

global:
  resolve_timeout: 5m
  smtp_from: '15933356856@163.com'
  smtp_smarthost: 'smtp.163.com:25'
  smtp_auth_username: '15933356856@163.com'
  smtp_auth_password: 'zyx1226'
  smtp_require_tls: false
route:
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 5s
  repeat_interval: 5m
  receiver: 'wechat'
receivers:
- name: 'email'
  email_configs:
  - to: '431062912@qq.com'
    send_resolved: true
- name: 'wechat'
  wechat_configs:
  - send_resolved: true
    to_party: '2'
    agent_id: 1000003
    corp_id: 'ww718b117b150277e6'   
    api_url: 'https://qyapi.weixin.qq.com/cgi-bin/'
    api_secret: 'bC0Vpk9cfvRl3R3bURqAeQyXADyrU1r1YuSLUy7DRxU'
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
```

##### 2）启动容器

```
#docker run -d   \
	--name alertmanager \
	-p 9093:9093  \
	-v /root/prom/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
	prom/alertmanager:latest
	
```

##### 3）告警截图

![avatar](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200312103806490.png)

## 5、对**AlertManager**进行配置，将告警发送到Webhook方式，提供部署配置说明

##### 1）配置yml文件

```
#vi  /root/prom/alertmanager.yml

global:
  resolve_timeout: 5m
  smtp_from: '15933356856@163.com'
  smtp_smarthost: 'smtp.163.com:25'
  smtp_auth_username: '15933356856@163.com'
  smtp_auth_password: 'zyx1226'
  smtp_require_tls: false
route:
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 5s
  repeat_interval: 5m
  receiver: 'web.hook'
receivers:
- name: 'email'
  email_configs:
  - to: '431062912@qq.com'
    send_resolved: true
- name: 'wechat'
  wechat_configs:
  - send_resolved: true
    to_party: '2'
    agent_id: 1000003
    corp_id: 'ww718b117b150277e6'   
    api_url: 'https://qyapi.weixin.qq.com/cgi-bin/'
    api_secret: 'bC0Vpk9cfvRl3R3bURqAeQyXADyrU1r1YuSLUy7DRxU'
- name: 'web.hook'
  webhook_configs:
  - send_resolved: true 
    url: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=fd274b2f-f1c6-4755-9161-440899b8edac'
    http_config: global.http_config
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']

```

##### 2）启动容器

```
#docker run -d   \
	--name alertmanager \
	-p 9094:9093  \
	-v /root/prom/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
	prom/alertmanager:latest
	
```

##### 3）告警截图



## 6、在测试云节点上部署：blackbox_exporter、memcached_exporter、 mysqld_exporter、node_exporter，提供部署配置说明，提供监控IP和端口，使上面程序保持运行(可用supervisor管理）

##### 1）supervisor安装

```
#yum install epel-release
#yum install -y supervisor

#systemctl enable supervisord # 开机自启动
#systemctl start supervisord # 启动supervisord服务

#systemctl status supervisord # 查看supervisord服务状态
#ps -ef|grep supervisord # 查看是否存在supervisord进程
```

#####  2）配置

```
#mkdir  /etc/supervisor
#echo_supervisord_conf > /etc/supervisor/supervisord.conf

#mkdir /etc/supervisor/config.d/
#vi /usr/lib/systemd/system/supervisord.service
。。。修改start路径
#systemctl daemon-reload
#systemctl restart supervisord

#vi /etc/supervisor/supervisord.conf
...修改如下
[inet_http_server]         ;HTTP服务器，提供web管理界面
port=127.0.0.1:9001        ;Web管理后台运行的IP和端口，改为0.0.0.0：9001，如果开放到公网，需要注意安全性  
username=user              ;登录管理后台的用户名
password=123               ;登录管理后台的密码
...
[include]
files = /etc/supervisor/config.d/*.ini    ;可以指定一个或多个以.ini结束的配置文件

#systemctl restart supervisord
#systemctl  status supervisord
```

##### 3） 子程序配置

以node_exporter为例

```
#vi  /etc/supervisor/config.d/node_exporter.ini

[program:node_exporter]
autostart = true
autorestart = true
command = /opt/prometheus/node_exporter/node_exporter #node-exporter执行路径
startretries = 3
user = root 

注意：需要安装对应的node-exporter
#对应的web管理界面为172.17.0.48:9001
```

##### 4）bash终端相关命令

```
1 supervisorctl status
2 supervisorctl stop celeryd
3 supervisorctl start celeryd
4 supervisorctl restart celeryd
5 supervisorctl reread
6 supervisorctl update
```



##### 5）进程安装

###### mysql_exporter安装

- 下载压缩包

```
#wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz
```

- 解压缩


```
 #tar -zxvf mysqld_exporter-0.12.1.linux-amd64.tar.gz
 #mkdir /usr/local/mysql_exporter/
 #mv mysqld_exporter-0.12.1.linux-amd64  /usr/local/mysql_exporter/
 #chmod +X /usr/local/mysql_exporter
```

- mysql_exporter连接到mysql


```
mysql> GRANT REPLICATION CLIENT,PROCESS ON *.* TO 'root'@'localhost' identified by '123456';
mysql> GRANT SELECT ON *.* TO 'root'@'localhost';
mysql> flush privileges;
```

- 创建my.cnf	

```
[client]
user = root
password = 123456
```

- 设置开机启动

```
#vim /usr/lib/systemd/system/mysql_exporter.service

[Unit]
Description=mysql_exporter
Documentation=https://prometheus.io/
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/mysql_exporter/mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter --config.my-cnf=/usr/local/mysql_exporter/mysqld_exporter-0.12.1.linux-amd64/my.cnf
[Install]
WantedBy=multi-user.target
	
#systemctl enable node_exporter
#systemctl start node_exporter
#systemctl stop node_exporter
#systemctl disable node_exporter

```

**注**：此处为了方便查看控制，顺便加入的启动服务，具体如果是supervisor管理的话，该过程可以不配置。

- 修改prometheus服务器配置文件并重启


```
#vim  /usr/local/prometheus/prometheus-2.15.2.linux-amd64/prometheus.yml
  新增：

- job_name: 'mysql'
  static_configs:
  - targets: ['172.17.0.48:9104']
      
#systemctl  restart prometheus
```

- supervisor子程序配置

```
#vi  /etc/supervisor/config.d/mysql_exporter.ini

[program:mysql_exporter]
autostart = true
autorestart = true
command = /usr/local/mysql_exporter/mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter --config.my-cnf=/usr/local/mysql_exporter/mysqld_exporter-0.12.1.linux-amd64/my.cnf 
startretries = 3
user = root 


#systemctl  restart  supervisord
```

###### blackbox_exporter安装

- 下载压缩包

```
#wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.16.0/blackbox_exporter-0.16.0.linux-amd64.tar.gz
```

- 解压缩

```
 #tar -zxvf blackbox_exporter-0.16.0.linux-amd64.tar.gz
 #mkdir /usr/local/blackbox_exporter/
 #mv blackbox_exporter-0.16.0.linux-amd64  /usr/local/blackbox_exporter/
 #chmod +X /usr/local/blackbox_exporter/blackbox_exporter-0.16.0.linux-amd64/
```

- supervisor子程序配置

```
#vi  /etc/supervisor/config.d/blackbox_exporter.ini

[program:blackbox_exporter]
autostart = true
autorestart = true
command = /usr/local/blackbox_exporter/blackbox_exporter-0.16.0.linux-amd64/blackbox_exporter --config.file=/usr/local/blackbox_exporter/blackbox_exporter-0.16.0.linux-amd64/blackbox.yml
startretries = 3
user = root 

#systemctl restart supervisord
```

- prometheus简单配置

```
#vim  /usr/local/prometheus/prometheus-2.15.2.linux-amd64/prometheus.yml

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - http://prometheus.io    # Target to probe with http.
        - https://prometheus.io   # Target to probe with https.
        - http://example.com:8080 # Target to probe with http on port 8080.
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 172.17.048:9115  # The blackbox exporter's real hostname:port.
```

###### memcached_exporter安装

- 下载压缩包

```
#wget https://github.com/prometheus/memcached_exporter/releases/download/v0.6.0/memcached_exporter-0.6.0.linux-amd64.tar.gz
```

- 解压缩

```
 #tar -zxvf memcached_exporter-0.6.0.linux-amd64.tar.gz
 #mkdir /usr/local/memcached_exporter/
 #mv memcached_exporter-0.6.0.linux-amd64  /usr/local/memcached_exporter/
 #chmod +X /usr/local/memcached_exporter/memcached_exporter-0.6.0.linux-amd64/
```

- supervisor子程序配置

```
#vi  /etc/supervisor/config.d/memcached_exporter.ini

[program:memcached_exporter]
autostart = true
autorestart = true
command = /usr/local/memcached_exporter/memcached_exporter-0.6.0.linux-amd64/memcached_exporter
startretries = 3
user = root 

#systemctl restart supervisord
```

- prometheus简单配置

```
#vim  /usr/local/prometheus/prometheus-2.15.2.linux-amd64/prometheus.yml

  - job_name: 'memcached_exporter'
    honor_labels: true
    static_configs:
    - targets: ['172.17.0.48:9150']

```



##### 6）supervisor web api

http://172.17.0.48:9001/   

用户名：user 

密码： 123

![avatar](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200312144926768.png)

##### 7）proemtheus web api

http://172.17.0.41:9090/

![image-20200312160725949](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200312160725949.png)



![image-20200312160750974](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200312160750974.png)

![image-20200312160813627](prometheus%E6%9C%80%E6%96%B0%E7%A0%94%E7%A9%B6.assets/image-20200312160813627.png)