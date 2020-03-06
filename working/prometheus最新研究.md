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
   - job_name: 'file_ds_server'
    file_sd_configs:
      - files:
        - /usr/local/prometheus/file_ds_server.json file
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

![image-20200303144303293](C:\Users\chenh\AppData\Roaming\Typora\typora-user-images\image-20200303144303293.png)

添加后：

![image-20200303145039737](C:\Users\chenh\AppData\Roaming\Typora\typora-user-images\image-20200303145039737.png)



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

![image-20200306154150436](C:\Users\chenh\AppData\Roaming\Typora\typora-user-images\image-20200306154150436.png)

![image-20200306154218288](C:\Users\chenh\AppData\Roaming\Typora\typora-user-images\image-20200306154218288.png)

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
  - url: 'http://127.0.0.1:5001/'
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
  smtp_smarthost: 'smtp.163.com'
  smtp_auth_username: '15933356856@163.'
  smtp_auth_password: 'xing1110'
  smtp_require_tls: false
  smtp_hello: 'capitek.com.cn'
route:
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 5s
  repeat_interval: 5m
  receiver: 'email'
receivers:
- name: 'email'
  email_configs:
  - to: 'zhangyx@capitek.com.cn'
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

##### 5）需要在 Prometheus 配置 AlertManager 服务地址以及告警规则，新建报警规则文件 `node-up.rules` 如下：

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

![image-20200306151423745](C:\Users\chenh\AppData\Roaming\Typora\typora-user-images\image-20200306151423745.png)



## 4、对**AlertManager**进行配置，将告警发送到微信方式，提供部署配置说明

## 5、对**AlertManager**进行配置，将告警发送到Webhook方式，提供部署配置说明

## 6、在测试云节点上部署：blackbox_exporter、memcached_exporter、mysqld_exporter、node_exporter，提供部署配置说明，提供监控IP和端口，使上面程序保持运行(可用supervisor管理)

```

```

