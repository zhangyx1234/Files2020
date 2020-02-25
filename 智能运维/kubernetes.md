## 1、组件介绍

1、基本概念：什么是POD、控制器类型、k8s、 网络通讯模式

2、构建k8s：安装

3、资源清单：资源是什么、资源清单的语法、编写pod、Pod的生命周期

4、Pod控制器：掌握多个控制器的特点和使用方法

5、服务发现：掌握SVC的原理和构建方式；服务：有状态服务和无状态服务

6、存储：掌握多种存储类型的特点，有自己的见解

7、调度器：掌握调度器原理，根据pod要求定义到目标节点

8、安全：集群的认证、鉴权、访问控制、原理和流程

9、HELM：Linux yum  掌握HELM原理、 HELM的原理

10、运维：

11组件说明：

APIserver：所有组件访问的统一入口

CrontrollerManager：维持副本期望数目

Scheduler：负责介绍任务，选择合适的节点进行任务分配

ETCD：键值对数据库，存储K8S集群所有的重要信息（持久化）

Kubelet：直接跟容器引擎交互实现容器的生命周期管理

Kube-proxy：负责写入规则至IPTABLES、IPVS实现服务映射访问

CROEDNS：可以为集群中的SVC创建一个域名IP的对应关系

DASGBOARD：给k8s集群提供一个B/S结构的访问体系

INGRESS CONTROLLER：官方只能实现四层代理，INGRESS可以实现七层

FEDERATION：提供一个可以跨集群中心的多k8s统一管理能力

PROMETHEUS：提供一个K8集群的监控能力

ELK：提供k8s集群日志的统一分析介入平台

注：高可用集群副本数据最好是>=3的奇数个

## 2、基础概念

### 1）pod概念

启动pod就会启动容器pause，其他的容器共享pause的网络栈。

自主式的pod：不受管理，死亡后，不会重启，也不会新建。

控制器管理的pod：HPA，ReplicationController、ReplicaSet和Deployment、StatefulSet、DaemonSet、Job、Cron Job

​	RC：保持容器副本数始终在用户定义副本数，如果有容器异常退出，会自动创建新的pod来替代；异常多出来的容器也会自动回收；新版本用RS取代RC

​	RS：跟RC没有本质不同，RS支持集合式的selector

​	Deployment：RS可以独立使用，但大部分会使用Deployment进行自动管理RS，这样就无需担心不兼容问题（RS 不支持rolling-update，Deployment支持）

​	HPA：Horizontal POD Autoscaling 仅适用于Deployment和RS，v1版本仅依依据pod的cpu利用率扩容，在 v1alpha版本中，可根据内容和用户自定义的metric扩缩和扩容

​	StatefulSet：解决了有状态服务的问题，Deployment、RS是为了无服务状态设计的，主要的应用场景包括：

​			稳定的持久化存储：pod重新调度后还能访问到相同的持久化数据，基于PVC实现

​			稳定的网路标志：Pod重新调度后其PodName和HostName不变，

​			有序部署：部署扩展过程依据定义的顺序

​			有序收缩、有序删除：

​	DaemonSet：确保全部Node上运行一个Pod副本；新的Node加入集群时，也会新增一个Pod；Node移除集群时，Pod也会被收回；删除DaemonSet将删除它创建的所有Pod。典型用法如下：

​			运行集群存储daemon， 如在每个node上运行glusterd ceph

​			每个Node上运行日志手机daemon，例如fluentd、logstash

​			每个node上运行监控daemon   Node-Exporter



### 2）网络通信方式

## 3、 资源清单