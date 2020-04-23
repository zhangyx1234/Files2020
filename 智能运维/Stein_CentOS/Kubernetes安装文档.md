---
typora-root-url: kubernetes install\assertion
---

# 基于Kubeadm的Kubernetes安装

### 1. 准备工作

#### 1.1 设置主机名

```shell
hostnamectl set-hostname master #it can also be configured as node01 or node02 when setting nodes

yum install wget vim -y
```

#### 1.2 编辑 /etc/hosts 文件，添加域名解析

```shell
cat <<EOF >>/etc/hosts
172.17.0.46	master
172.17.0.47	node01
172.17.0.48	node02
EOF
```

#### 1.3 关闭防火墙、selinux和swap

```shell
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab
```

#### 1.4 配置内核参数，将桥接的IPV4流量传递到iptables的链

```shell
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# 执行命令是修改生效
modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf
```

#### 1.5 kube-proxy开启ipvs的前置条件

由于ipvs已经加入到了内核的主干，所以为kube-proxy开启ipvs的前提需要加载以下的内核模块，在所有节点执行以下脚本

```shell
yum install ipset ipvsadm -y

cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

# 授权并查看是否已经正确加载所需的内核模块
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

确保各个节点上已经安装了ipset软件包`yum install ipset`。 为了便于查看ipvs的代理规则，最好安装一下管理工具ipvsadm `yum install ipvsadm`。如果以上前提条件如果不满足，则即使kube-proxy的配置开启了ipvs模式，也会退回到iptables模式。

#### 1.6 配置国内Kubernetes源

```sh
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

#### 1.7 配置docker源

```shell
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
```

### 2、使用kubeadm部署Kubernetes

#### 2.1 软件安装

##### 2.1.1 安装docker

docker服务为容器运行提供计算资源，是所有容器运行的基本平台

```shell
yum list docker-ce.x86_64  --showduplicates |sort -r  #查看版本

yum makecache fast
yum install -y --setopt=obsoletes=0 docker-ce-18.09.7-3.el7 
systemctl enable docker 
systemctl start docker
docker –version

iptables -nvL # 确认一下iptables filter表中FOWARD链的默认策略(pllicy)为ACCEPT
```

配置docker0默认ip，重启docker（防止`docker` `ip`段与远端连接电脑冲突）

修改docker cgroup driver为systemd

```shell
vim /etc/docker/daemon.json
{
  "bip": "172.20.0.1/16"
}

{
  "exec-opts": ["native.cgroupdriver=systemd"]
}

systemctl restart docker

docker info | grep Cgroup  # Cgroup Driver: systemd
```

##### 2.1.2 安装kubeadm、kubelet、kubectl

```shell
yum makecache fast
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet
systemctl enable kubelet.service
```

Kubelet负责与其他节点集群通信，并进行本节点Pod和容器生命周期的管理。

Kubeadm是Kubernetes的自动化部署工具，降低了部署难度，提高效率。

Kubectl是Kubernetes集群管理工具。

```shell
swapoff -a
vim /etc/sysctl.d/k8s.conf #添加如下
vm.swappiness=0
sysctl -p /etc/sysctl.d/k8s.conf  # 使生效

vim /etc/sysconfig/kubelet # 添加如下
KUBELET_EXTRA_ARGS=--fail-swap-on=false
```

#### 2.2 部署master节点

##### 2.2.1 在master进行Kubernetes集群初始化

*请将版本号设置为最新版本

*apiserver的ip地址为主机地址

*Warning about driver

```shell
kubeadm init --kubernetes-version=1.15.0 \
--apiserver-advertise-address=172.17.0.42 \
--image-repository registry.aliyuncs.com/google_containers \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16
```

成功后返回如下信息：

```shell
kubeadm join 172.17.0.42:6443 --token cxvtzv.0f03zft5ct3vqxf3 --discovery-token-ca-cert-hash sha256:e92d249037b72c92848d722b18cbbbdea10eb807987b97d4d3b1c312e6f9ef8e

```

![微信截图_20190702155204](/../../assertion/微信截图_20190702155204.png)

记录生成的最后部分内容，此内容需要在其他节点加入Kuberntes集群时执行

##### 2.2.2 配置kubectl工具

```shell
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl get nodes
kubectl get cs
```

get nodes用以检查集群中的节点

get cs用以检查controller 和 scheduler的状态

返回如下图

![微信截图_20190702155525](/../../assertion/微信截图_20190702155525.png)

##### 2.2.3 部署flannel网络

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl get pod --all-namespaces -o wide
```



#### 2.3 部署node节点

*对所有node节点进行如下操作

执行master初始化后返回的内容，使node加入集群

```shell
kubeadm join 172.17.0.46:6443 --token o68rwc.x3k7871yftkwvzbs \
--discovery-token-ca-cert-hash sha256:201320d2ebda6b1a5f25c6b68c98e2173cec0ad7cd0743701565994e8e3f25d
```



#### 2.4 集群状态检测

*在master节点进行如下操作

##### 2.4.1 状态监测

在master节点输入命令检查集群状态，返回如下结果则集群状态正常

![微信截图_20190703115101](/../../assertion/微信截图_20190703115101.png)

创建Pod以验证集群是否正常

```shel
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pod,svc
```

返回如下图：

![微信截图_20190703135047](/../../assertion/微信截图_20190703135047.png)

```shell
kubectl get nodes
kubectl get cs
kubectl get pod
kubectl get svc
kubectl get pods -n kube-system -o wide
kubectl get pod --all-namespaces -o wide

kubectl get svc --all-namespaces
kubectl get services -n kube-system
```

##### 2.4.2 kube-proxy开启ipvs

修改ConfigMap的kube-system/kube-proxy中的config.conf，`mode: "ipvs"`

```shell
kubectl edit cm kube-proxy -n kube-system
```

之后重启各个节点上的kube-proxy pod：

```shell
kubectl get pod -n kube-system | grep kube-proxy | awk '{system("kubectl delete pod "$1" -n kube-system")}'
```

```shell
kubectl get pod -n kube-system | grep kube-proxy
kubectl logs kube-proxy-6pz25  -n kube-system
```

![1562297439157](/../../assets/1562297439157.png)

日志中打印出了`Using ipvs Proxier`，说明ipvs模式已经开启。

![1562318145376](/../../assets/1562318145376.png)

### 3. Kubernetes常用组件部署

*在master节点进行如下操作，使用Helm这个Kubernetes的包管理器

#### 3.1 Helm的安装

Helm由客户端命helm令行工具和服务端tiller组成

```shell
cd /usr/local/bin
curl -O https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
tar -zxvf helm-v2.14.1-linux-amd64.tar.gz
cd linux-amd64/
cp helm /usr/local/bin/
```

Helm Tiller是Helm的server，Tiller有多种安装方式，比如本地安装或以pod形式部署到Kubernetes集群中。我们这里采用pod安装的方式。

在国内环境中，我们直接使用`helm init`会无法拉取到tiller镜像，需要手动指定镜像地址，同时如果Kubernetes集群开启了rbac，还需要指定运行tiller的servicaccount，并为该serviceaccount作合适的授权

```shell
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.0 --service-account=tiller --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```

创建serviceaccount并授权的示例

```shell
vim helm-rbac.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system

kubectl create -f helm-rbac.yaml
```

```shell'
# 检查状态，是否安装成功
kubectl get pod -n kube-system -l app=helm
helm version
```

注意保持一致，需要手动升级

```shell
helm init --tiller-image registry.cn-hangzhou.aliyuncs.com/acs/tiller:v2.11.0 --upgrade
```

![1562581035878](/../../assets/1562581035878.png)



最后在node1上修改helm chart仓库的地址为azure提供的镜像地址

```shell
helm repo remove stable
helm repo add stable http://mirror.azure.cn/kubernetes/charts

helm repo list
```

![1562916363997](/../../assets/1562916363997.png)

查看验证所有部署成功

```shell
kubectl get pod --all-namespaces -o wide
```

![1562916519291](/../../assets/1562916519291.png)



#### 3.2 使用Helm部署Nginx Ingress

为了便于将集群中的服务暴露到集群外部，需要使用Ingress，Nginx Ingress Controller被部署在Kubernetes的边缘节点上，将master做为边缘节点，打上Label

```shell
kubectl label node master node-role.kubernetes.io/edge=

kubectl get node
```

![1562918277859](/../../assets/1562918277859.png)

```shell
# 查看版本
helm search nginx-ingress
```

![1562918325504](/../../assets/1562918325504.png)

同样，由于国内不能访问谷歌仓库，所以要提前从阿里云pull下来这相关镜像，镜像版本可从http://mirror.azure.cn/kubernetes/charts 下载`nginx-ingress`查看`values.yaml`

本次查询的版本为`nginx-ingress-controller:0.25.0`和`defaultbackend-amd64:1.5`

打开阿里云镜像仓库，搜索上面两个镜像。https://account.aliyun.com/login/login.htm?oauth_callback=https%3A%2F%2Fcr.console.aliyun.com%2Fcn-hangzhou%2Finstances%2Fimages 需要有账户

![1562918835079](/../../assets/1562918835079.png)

复制上面的公网地址即可

```shell
#注意选取正确的版本号，格式为[地址]：[版本号]，如果没有版本号则不用填写，意为lastest
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:0.25.0
docker pull registry.cn-hangzhou.aliyuncs.com/k8smonitor/defaultbackend-amd64:1.5

```

更改tag，使镜像与values中镜像配置一致，image ID 一致会有两个

```shell
docker tag 02149b6f439f quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.25.0
docker tag b5af743e5984 k8s.gcr.io/defaultbackend-amd64:1.5

docker images
```

![1562919002185](/../../assets/1562919002185.png)

在本地生成ingress-nginx.yaml 如下

```yaml
controller:
  replicaCount: 1
  hostNetwork: true
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  affinity:
    podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - nginx-ingress
            - key: component
              operator: In
              values:
              - controller
          topologyKey: kubernetes.io/hostname
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule
defaultBackend:
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule
```

运行配置文件，等待pod配置完成

```shell
helm repo update

helm install stable/nginx-ingress \
-n nginx-ingress \
--namespace ingress-nginx  \
-f ingress-nginx.yaml
```

查看pod状态

```shell
kubectl get pod -n ingress-nginx -o wide
```

![1562919265312](/../../assets/1562919265312.png)

```shell
# 删除 nginx-ingress
helm del --purge nginx-ingress
helm ls --all nginx-ingress
```

访问`http://172.17.0.42`返回default backend，则部署完成

![1562919436561](/../../assets/1562919436561.png)

*注意：防火墙保证关闭，云服务器的安全策略允许所有协议*



#### 3.3 使用Helm部署dashboard

同样，由于国内不能访问谷歌仓库，所以要提前从阿里云pull下来这相关镜像

```shell
docker pull registry.cn-hangzhou.aliyuncs.com/gaven_k8s/kubernetes-dashboard-amd64:v1.10.1
docker tag f9aed6605b81 k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1

docker images
```

![1562919002185](/../../assets/1562919002185.png)

创建`kubernetes-dashboard.yaml`文件

```shell
image:
  repository: k8s.gcr.io/kubernetes-dashboard-amd64
  tag: v1.10.1
ingress:
  enabled: true
  hosts: 
    - k8s.frognew.com
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  tls:
    - secretName: frognew-com-tls-secret
      hosts:
      - k8s.frognew.com
nodeSelector:
    node-role.kubernetes.io/edge: ''
tolerations:
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: PreferNoSchedule
rbac:
  clusterAdminRole: true
```

```shell
helm install stable/kubernetes-dashboard \
-n kubernetes-dashboard \
--namespace kube-system  \
-f kubernetes-dashboard.yaml
```

查看pod状态

```shell
kubectl get pod --all-namespaces -o wide
```

 修改service通过NodePort方式访问k8s dashboard

```shell
kubectl -n kube-system edit svc kubernetes-dashboard
# 进入后修改内容如下
spec:
  clusterIP: 10.106.68.90
  ports:
  - port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: ClusterIP ## <------修改为NodePort
status:
  loadBalancer: {}

# 查看 service
kubectl get svc -n kube-system
```

![1562920144950](/../../assets/1562920144950.png)

可看到给出的端口为`32123`，可通过https://172.17.0.42:32123 访问仪表盘

需要通过token登录，获得登录口令

```shell
kubectl -n kube-system get secret | grep kubernetes-dashboard-token
```

![1562919751576](/../../assets/1562919751576.png)

```shell
kubectl describe -n kube-system secret/kubernetes-dashboard-token-gtc67 
```

![1562919821322](/../../assets/1562919821322.png)

![1562920315180](/../../assets/1562920315180.png)

![1562920348890](/../../assets/1562920348890.png)

```shell
# 删除kubernetes-dashboard
helm del --purge kubernetes-dashboard
helm ls --all kubernetes-dashboard
```









