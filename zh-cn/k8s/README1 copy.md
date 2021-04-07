## 容器的基本实现原理

- Namespace
  用来修改进程视图的主要方法。
- Cgroups
  用来制造约束的主要手段。最主要的作用，就是限制一个进程组能够使用的资源上限，包括 CPU、内存、磁盘、网络带宽等等。
- rootfs

容器，其实是一种特殊的进程而已。

---

## kubernetes架构中组件有哪些？

- Master：控制节点
  - `kube-apiserver`：负责API服务
  - `kube-scheduler`：负责调度PODs的相关工作
  - `kube-controler-manager`：负责容器编排
    - `Node Controller`： 负责在节点出现故障时进行通知和响应
    - `Job controller`：监测代表一次性任务的 Job 对象，然后创建 Pods 来运行这些任务直至完成
    - `Endpoints Controller`：负责Service与pod对应端点关系
    - `Service Account & Token Controllers`：为新的命名空间创建默认帐户和 API 访问令牌
  - etcd：负责保存集群数据的数据库
- Node：
  - `kubelet`：负责同容器运行时
  - `kube-proxy`：负责每个节点运行的网络代理，用以控制集群内部和集群外部与POD进行的通信
  - `Container Runtime`：容器运行环境是负责运行容器的软件。


---

## 基于kubeadm搭建高可用集群

### 一、资源准备

| 节点IP      | 节点角色 | 节点组件                                                            | 备注说明    |
| ----------- | -------- | ------------------------------------------------------------------- | ----------- |
| 172.16.4.60 | VIP      |                                                                     | 虚拟IP      |
| 172.16.4.61 | master   | kube-apiserver<br>kube-controller-manager<br>kube-scheduler<br>etcd | master节点1 |
| 172.16.4.62 | master   | kube-apiserver<br>kube-controller-manager<br>kube-scheduler<br>etcd | master节点2 |
| 172.16.4.63 | master   | kube-apiserver<br>kube-controller-manager<br>kube-scheduler<br>etcd | master节点3 |
| 172.16.4.64 | node     | kubelet<br>kube-proxy                                               | node节点    |
| 172.16.4.65 | node     | kubelet<br>kube-proxy                                               | node节点    |
| 172.16.4.66 | node     | kubelet<br>kube-proxy                                               | node节点    |

---
### 二、环境准备

- 所有服务器，关闭swap
- 所有服务器，关闭selinux
- 所有服务器，关闭防火墙
- 所有服务器，设置时间同步

---
### 三、安装keepalived+haproxy

1. 在所有的master节点（172.16.4.61，172.16.4.62，172.16.4.63）上安装keepalived

`/etc/keepalived/keepalived.conf`参考配置

```shell
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -20
  fall 5
  rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    authentication {
        auth_type PASS
        auth_pass 44
    }
    virtual_ipaddress {
        172.16.4.60/24 dev eth0
    }
    track_script {
        check_apiserver
    }
}
```
健康检查脚本`/etc/keepalived/check_apiserver.sh`参考

```shell
#!/bin/sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:8443/ -o /dev/null || errorExit "Error GET https://localhost:8443/"
if ip addr | grep -q "172.16.4.60"; then
    curl --silent --max-time 2 --insecure https://172.16.4.60:8443/ -o /dev/null || errorExit "Error GET https://172.16.4.60:8443/"
fi
```

2. 在所有的master节点（172.16.4.61，172.16.4.62，172.16.4.63）上安装haproxy

`/etc/haproxy/haproxy.cfg`参考配置

```shell
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 1
    timeout http-request    10s
    timeout queue           20s
    timeout connect         5s
    timeout client          20s
    timeout server          20s
    timeout http-keep-alive 10s
    timeout check           10s

#---------------------------------------------------------------------
# apiserver frontend which proxys to the masters
#---------------------------------------------------------------------
frontend apiserver
    bind *:8443
    mode tcp
    option tcplog
    default_backend apiserver

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
    option httpchk GET /healthz
    http-check expect status 200
    mode tcp
    option ssl-hello-chk
    balance     roundrobin
        server k8s-master-1 172.16.4.61:6443 check
        server k8s-master-2 172.16.4.62:6443 check
        server k8s-master-3 172.16.4.63:6443 check
```
---

### 三、安装Kubernetes

#### 1. 为所有节点安装docker(或其他容器运行时)

内核参数开启

```shell
# 安装桥接流量模块
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
# 配置内核参数，启用流量监听
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```
安装docker-ce

```shell
# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息

sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce
# Step 4: 开启Docker服务
sudo service docker start
sudo systemctl enable docker.service

# 注意：
# 官方软件源默认启用了最新的软件，您可以通过编辑软件源的方式获取各个版本的软件包。例如官方并没有将测试版本的软件源置为可用，您可以通过以下方式开启。同理可以开启各种测试版本等。
# vim /etc/yum.repos.d/docker-ee.repo
#   将[docker-ce-test]下方的enabled=0修改为enabled=1
#
# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# yum list docker-ce.x86_64 --showduplicates | sort -r
#   Loading mirror speeds from cached hostfile
#   Loaded plugins: branch, fastestmirror, langpacks
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            docker-ce-stable
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            @docker-ce-stable
#   docker-ce.x86_64            17.03.0.ce-1.el7.centos            docker-ce-stable
#   Available Packages
# Step2: 安装指定版本的Docker-CE: (VERSION例如上面的17.03.0.ce.1-1.el7.centos)
# sudo yum -y install docker-ce-[VERSION]
```
配置镜像加速

```shell
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s https://b9pmyelo.mirror.aliyuncs.com
```

#### 2. 安装kubenetes

```shell
# 添加镜像源地址
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
# 安装kubeadm,kubelet,kubectl（node节点可以不安装）
yum makecache fast && yum install -y kubelet kubeadm kubectl
systemctl enable --now kubelet
```

#### 3. 初始化集群

- 命令式

```shell
kubeadm init --control-plane-endpoint="172.16.4.60:8443" \
--image-repository="registry.aliyuncs.com/google_containers" \
--kubernetes-version "v1.20.0" \
--pod-network-cidr="10.244.0.0/16" \
--service-cidr="10.96.0.0/12" \
--upload-certs
```

- 声明式

`kubeadm init --config config.yaml --upload-certs`

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
clusterName: kubernetes
imageRepository: registry.aliyuncs.com/google_containers
controlPlaneEndpoint: 172.16.4.60:8443
kubernetesVersion: v1.20.0
networking:
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.244.0.0/16
```
输出结果参考如下

```shell
...
现在，您可以通过在根目录上运行以下命令来加入任意数量的控制平面节点：
kubeadm join 192.168.0.200:6443 --token 9vr73a.a8uxyaju799qwdjv --discovery-token-ca-cert-hash sha256:7c2e69131a36ae2a042a339b33381c6d0d43887e2de83720eff5359e26aec866 --control-plane --certificate-key f8902e114ef118304e561c3ecd4d0b543adc226b7a07f675f56564185ffe0c07

请注意，证书密钥可以访问集群内敏感数据，请保密！
为了安全起见，将在两个小时内删除上传的证书； 如有必要，您可以使用 kubeadm 初始化上传证书阶段，之后重新加载证书。

然后，您可以通过在根目录上运行以下命令来加入任意数量的工作节点：
kubeadm join 192.168.0.200:6443 --token 9vr73a.a8uxyaju799qwdjv --discovery-token-ca-cert-hash sha256:7c2e69131a36ae2a042a339b33381c6d0d43887e2de83720eff5359e26aec866
```

#### 4. 添加其他Control-Plane节点

```shell
kubeadm join 192.168.0.200:6443 --token 9vr73a.a8uxyaju799qwdjv --discovery-token-ca-cert-hash sha256:7c2e69131a36ae2a042a339b33381c6d0d43887e2de83720eff5359e26aec866 --control-plane --certificate-key f8902e114ef118304e561c3ecd4d0b543adc226b7a07f675f56564185ffe0c07
```

#### 5. 添加node节点

```shell
kubeadm join 192.168.0.200:6443 --token 9vr73a.a8uxyaju799qwdjv --discovery-token-ca-cert-hash sha256:7c2e69131a36ae2a042a339b33381c6d0d43887e2de83720eff5359e26aec866
=======
--service-cidr="10.96.0.0/12"


You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 172.16.4.60:8443 --token 8gt2tr.bpdmun9t60dbs8hb \
    --discovery-token-ca-cert-hash sha256:bdc308443571af6f5f6b053ce82775f6c7b7b4edcd44d98a9c0fc7ccf51d239d \
    --control-plane --certificate-key 4d9cdf2c1994b41fc44e9a707e4086cbfaddbe183ffb0849cfdf56348542f1fd

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.4.60:8443 --token 8gt2tr.bpdmun9t60dbs8hb \
    --discovery-token-ca-cert-hash sha256:bdc308443571af6f5f6b053ce82775f6c7b7b4edcd44d98a9c0fc7ccf51d239d



sudo kubeadm init phase upload-certs --upload-certs
```