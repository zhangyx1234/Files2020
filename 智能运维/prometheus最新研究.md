## 1、**Prometheus**自动发现被监控节点的配置方法？即图中的discover targets的file_sd方式

```
1）创建json文件

vi /usr/local/prometheus/file_ds_server.json
[
  {
    "targets":  ["172.17.0.10:9100"]
  }
]

2）在prometheus配置文件中添加新的job
  
  - job_name: 'file_ds_server'
    file_sd_configs:
      - files:
        - /usr/local/prometheus/file_ds_server.json file路径
        refresh_interval: 10s 
        
注：因为配置文件有修改需要重新启动prometheus服务器

3）有新的metrics节点加入时直接修改在json文件添加

[
  {
    "targets":  ["172.17.0.10:9100","172.17.0.10:9100","172.17.0.10:9100"]
  }
]

4)重新加载targets能够发现新的监控节点已经加入，无需重启服务器

```

添加前：

![image-20200303144303293](C:\Users\chenh\AppData\Roaming\Typora\typora-user-images\image-20200303144303293.png)

添加后：

![image-20200303145039737](C:\Users\chenh\AppData\Roaming\Typora\typora-user-images\image-20200303145039737.png)

webAPI：http://172.17.0.41:9090/



## 2、找一个Short-lived Jobs的示例，配置其向**Pushgateway**推送监控指标？

## 3、对**AlertManager**进行配置，将告警发送到邮件方式，提供部署配置说明

## 4、对**AlertManager**进行配置，将告警发送到微信方式，提供部署配置说明

## 5、对**AlertManager**进行配置，将告警发送到Webhook方式，提供部署配置说明

## 6、在测试云节点上部署：blackbox_exporter、memcached_exporter、mysqld_exporter、node_exporter，提供部署配置说明，提供监控IP和端口，使上面程序保持运行(可用supervisor管理)

•