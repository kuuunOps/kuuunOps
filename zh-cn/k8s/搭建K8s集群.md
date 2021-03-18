# 搭建Kubernetes集群

部署方式：

- kubeadm
  `kubeadm`是一个工具，提供`kubeadm init`和`kubeadm join`，用于快速部署Kubernetes集群。
  
  部署地址：https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/

- 二进制
  推荐，从官方下载发行版的二进制包，手动部署每个组件，组成Kubernetes集群。 
  
  下载地址：https://github.com/kubernetes/kubernetes/releases


# 使用kubeadm搭建

>主要步骤：
>1. 安装docker
>2. 创建一个Master节点
>```bash
>kubeadm init
>```
>3. 将一个node节点加入到当前集群中
>```bash
>kubeadm join <Master节点的IP和端口>
>```
>4. 部署容器网络组件（CNI）
>```bash
>kubeadm apply -f calico.yaml
>```
>5. 部署Web UI（Dashboard）

# 服务器初始化配置

## 1. 安装要求

- 一台或多台机器，操作系统：Ubuntu 16.04+，CentOS 7+
- CPU:2核+
- 内存：2GB+
- 集群中所有机器内网或外网互通
- 禁止swap分区

## 2. 环境准备

### 2.1 主机规划
<table style="text-align:center">
  <thead>
    <tr>
      <th>角色</th>
      <th>主机名</th>
      <th>IP</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Master</td>
      <td>k8s-master</td>
      <td>172.16.4.41</td>
    </tr>
    <tr>
      <td  rowspan="2">Node</td>
      <td>k8s-node1</td>
      <td>172.16.4.52</td>
    </tr>
    <tr>
      <td>k8s-node2</td>
      <td>172.16.4.52</td>
    </tr>
  </tbody>
</table>

### 2.2 关闭防火墙
```shell
systemctl stop firewalld
systemctl disable firewalld
```

**K8s集群相关端口**
  - 控制节点端口
| 协议 | 方向 | 端口范围  | 作用                    | 使用者                       |
| ---- | ---- | --------- | ----------------------- | ---------------------------- |
| TCP  | 入站 | 6443      | Kubernetes API 服务器   | 所有组件                     |
| TCP  | 入站 | 2379-2380 | etcd 服务器客户端 API   | kube-apiserver, etcd         |
| TCP  | 入站 | 10250     | Kubelet API             | kubelet 自身、控制平面组件   |
| TCP  | 入站 | 10251     | kube-scheduler          | kube-scheduler 自身          |
| TCP  | 入站 | 10252     | kube-controller-manager | kube-controller-manager 自身 |
  - 工作节点端口
| 协议 | 方向 | 端口范围    | 作用           | 使用者                     |
| ---- | ---- | ----------- | -------------- | -------------------------- |
| TCP  | 入站 | 10250       | Kubelet API    | kubelet 自身、控制平面组件 |
| TCP  | 入站 | 30000-32767 | NodePort 服务† | 所有组件                   |

### 2.3关闭selinux
```shell
sudo sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
sudo setenforce 0  # 临时
```

### 2.4 关闭swap
```shell
sudo swapoff -a  # 临时
sudo vim /etc/fstab  # 永久
```

### 2.5 设置主机名
```shell
# 节点主机 k8s-master
hostnamectl set-hostname k8s-master
# 节点主机 k8s-node1
hostnamectl set-hostname k8s-node1
# 节点主机 k8s-node2
hostnamectl set-hostname k8s-node2
```

### 2.6 hosts解析
```shell
# 在所有节点上添加解析
cat >> /etc/hosts << EOF
172.16.4.41 k8s-master
172.16.4.51 k8s-node1
172.16.4.52 k8s-node2
EOF
```

### 2.7 时间同步
```bash
# apt install ntpdate -y
yum install ntpdate -y
ntpdate time.windows.com
```

---

## 3. 安装容器运行时（runC）

### 3.1 使用Docker作为容器运行时

>仅在kubernetes1.23版本以前支持，以后请使用其他容器运行时

1. 安装桥接流量模块
```shell
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
```

2. 配置内核参数，启用流量监听
```shell
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

2. 安装docker-ce
   
CentOS系统:

>网易镜像地址：http://mirrors.163.com/docker-ce/linux/centos/docker-ce.repo
>
>阿里镜像地址：https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
>
>清华大学镜像地址：https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo
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

Ubuntu系统:

```shell
# step 1: 安装必要的一些系统工具
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
curl -fsSL https://maven.aliyun.com/repository/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://maven.aliyun.com/repository/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新并安装Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce
# Step 5: 开启Docker服务
sudo service docker start
sudo systemctl enable docker.service

# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# apt-cache madison docker-ce
#   docker-ce | 17.03.1~ce-0~ubuntu-xenial | https://maven.aliyun.com/repository/docker-ce/linux/ubuntu xenial/stable amd64 Packages
#   docker-ce | 17.03.0~ce-0~ubuntu-xenial | https://maven.aliyun.com/repository/docker-ce/linux/ubuntu xenial/stable amd64 Packages
# Step 2: 安装指定版本的Docker-CE: (VERSION例如上面的17.03.1~ce-0~ubuntu-xenial)
# sudo apt-get -y install docker-ce=[VERSION]
```

4. 配置镜像加速
   
```shell
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s https://b9pmyelo.mirror.aliyuncs.com
```

### 3.2 使用Containerd作为容器运行时

1. 安装`containerd`依赖模块
```shell
# 配置模块
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
```

2. 配置内核参数
```shell
# 配置内核参数
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# 应用参数
sudo sysctl --system
```

3. 安装`containerd`
```shell
# 安装软件包
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 配置Docker镜像源
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 配置 containerd
yum update -y && sudo yum install -y containerd.io
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
# 重启 containerd
sudo systemctl restart containerd
```

4. 配置`containerd`镜像，Cgroup
   
`vi /etc/containerd/config.toml`
```toml
... ...
  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    selinux_category_range = 1024
    # 配置pause镜像仓库地址
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.2"
... ...
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          ...
          # 配置Cgroup
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
... ...
     [plugins."io.containerd.grpc.v1.cri".registry]
       [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
         [plugins."io.containerd.grpc.v1.cri".registry.mirrors."b9pmyelo.mirror.aliyuncs.com"]
           # 配置镜像加速地址
           endpoint = ["https://b9pmyelo.mirror.aliyuncs.com"]
      # 私有镜像仓库配置
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."reg.kuuun.com".tls]
          insecure_skip_verify = true
        [plugins."io.containerd.grpc.v1.cri".registry.configs."reg.kuuun.com".auth]
          username = "admin"
          password = "Harbor12345"
... ...
```
重启` containerd `
```shell
sudo systemctl enable containerd
sudo systemctl restart containerd
```

---

## 4. 安装` kubernetes `

### 4.1 配置` kubernetes `镜像
   
**CentOS系统**
```shell
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```


**Ubuntu系统**
```shell
apt-get update && apt-get install -y apt-transport-https
 
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
```

部署Master/Node
官方文档初始化参考
>https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file
>
>https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node

### 4.2 安装Master

**CentOS**
```shell
yum makecache fast && yum install -y kubelet kubeadm kubectl
systemctl enable --now kubelet
```

**Ubuntu**
```shell
apt-get update && apt-get install -y kubelet kubeadm kubectl
systemctl enable --now kubelet
```

### 4.3 安装Node

**CentOS**
```shell
yum makecache fast && yum install -y kubelet kubeadm
systemctl enable --now kubelet
```

**Ubuntu**
```shell
apt-get update && apt-get install -y kubelet kubeadm
systemctl enable --now kubelet
```

### 4.4 配置kubelet/crictl（可选）

> 使用containerd作为容器运行时需要进行额外配置
 
1. `/etc/sysconfig/kubelet `

```shell
cat >/etc/sysconfig/kubelet << EOF
KUBELET_EXTRA_ARGS="--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --cgroup-driver=systemd"
EOF
```

2. `/etc/crictl.yaml`

```shell
cat >/etc/crictl.yaml << EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF
```


### 4.5 集群初始化

>在Master节点执行初始化操作

- **使用命令行初始化**

```shell
kubeadm init \
  --apiserver-advertise-address=172.16.4.41 \
  --kubernetes-version=1.20.4 \
  --image-repository registry.aliyuncs.com/google_containers \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all
```

| 选项参数                    | 描述                                           |
| --------------------------- | ---------------------------------------------- |
| apiserver-advertise-address | 集群通告地址                                   |
| image-repository            | 拉取镜像仓库地址                               |
| kubernetes-version          | k8s的版本                                      |
| service-cidr                | 集群内部虚拟网络，Pod统一访问入口              |
| pod-network-cidr            | Pod网络，与下面部署的CNI网络组件yaml中保持一致 |

---
- **使用配置文件初始化**

`kubeadm init --config xxx.yml `

**配置文件示例**
```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: 1.20.4
imageRepository: registry.aliyuncs.com/google_containers
networking:
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
```

- 执行初始化命令

**初始化完成**
```shell
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.4.41:6443 --token i8h92d.twyoqkzbaokka06i \
    --discovery-token-ca-cert-hash sha256:baae370b27c6be8b42eb376cadcc616f9a5a3658b958077d7897641f41c2bc75
```

- 设置kubenetes管理认证
  
拷贝kubectl使用的连接k8s认证文件到默认路径

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

或者使用` root `用户设置环境变量

```shell
export KUBECONFIG=/etc/kubernetes/admin.conf
```

**kubeadm初始化流程：**
1. preflight：环境检查和拉取镜像
2. certs： 生成k8s证书和etcd证书，默认证书路径：/etc/kubernetes/pki
3. kubeconfig：生成kubeconfig的各种配置文件
4. kubelet-start：生成kubelet配置文件，启动kubelet
5. control-plane：部署管理节点组件，用镜像启动容器，使用命令查看容器`kubectl get pods -n kube-system`
6. etcd：部署etcd数据库服务，使用镜像启动
7. upload-config/kubelet/upload-certs：上传配置文件到k8s中
8. mark-control-plane：标记一个标签`"node-role.kubernetes.io/master=''"`,再添加一个污点`[node-role.kubernetes.io/master:NoSchedule]`
9. bootstrap-token：自动为kubelet颁发证书
10. addons：安装插件`CoreDNS`，`kube-proxy`
11. 拷贝k8s认证文件

---

## 5. 部署网络组件(CNI)

[参考文献](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network)

推荐Calico
>Calico是一个纯三层的数据中心网络方案，Calico支持广泛的平台，包括Kubernetes、OpenStack等。
>
>Calico 在每一个计算节点利用 Linux Kernel 实现了一个高效的虚拟路由器（ vRouter） 来负责数据转发，而每个 vRouter 通过 BGP 协议负责把自己上运行的 workload 的路由信息向整个 Calico 网络内传播。
>
>此外，Calico  项目还实现了 Kubernetes 网络策略，提供ACL功能。

[官方文献](https://docs.projectcalico.org/getting-started/kubernetes/quickstart)

下载配置文件
```shell
curl -o calico.yaml https://docs.projectcalico.org/manifests/calico.yaml
```
修改字段`CALICO_IPV4POOL_CIDR`内容与`kubeadm init`指定的网络一致（`--podSubnet`）。

```yaml
...
- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"
...
```
应用配置文件
```bash
kubectl apply -f calico.yaml
```

查看PODS状态
```bash
kubectl get pods -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-69496d8b75-k9kzr   1/1     Running   0          6m54s
calico-node-dctfc                          1/1     Running   0          6m54s
coredns-7f89b7bc75-7ps6t                   1/1     Running   0          9m6s
coredns-7f89b7bc75-bx2hn                   1/1     Running   0          9m6s
etcd-k8s-master                            1/1     Running   0          9m23s
kube-apiserver-k8s-master                  1/1     Running   0          9m23s
kube-controller-manager-k8s-master         1/1     Running   0          9m23s
kube-proxy-gn922                           1/1     Running   0          9m6s
kube-scheduler-k8s-master                  1/1     Running   0          9m23s
```

确认节点状态
```shell
kubectl get nodes
NAME         STATUS   ROLES                  AGE   VERSION
k8s-master   Ready    control-plane,master   10m   v1.20.4
```

---
## 6. 添加Node节点

在node节点上执行集群添加命令，命令为kubeadm init输出的kubeadm join命令
```shell
kubeadm join 172.16.4.41:6443 --token 0a2ndm.hg1plutf762btynv \
    --discovery-token-ca-cert-hash sha256:a74297b357905497873b3697eb55cef476bf1a71799566b61bb4dbcb81314654
```

查看节点，Node节点状态为：`NotReady`，需要等待Node节点的`calico`组件安装完成并运行
```bash
kubectl get nodes -w
NAME         STATUS     ROLES                  AGE   VERSION
k8s-master   Ready      control-plane,master   11m   v1.20.4
k8s-node1    NotReady   <none>                 3s    v1.20.4
k8s-node2    NotReady   <none>                 1s    v1.20.4
```

---

## 7. 测试
```shell
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pod,svc
```

---

## 8. 部署Web UI

```shell
curl -o  dashboard.yaml https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml
```

默认Dashboard只能集群内部访问，修改Service为NodePort类型，暴露到外部：

```yaml
---
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard

---
```
修改为
```yaml

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort

```
应用部署文件
```shell
kubectl apply -f recommended.yaml
```
查看部署的状态
```shell
kubectl get pods -n kubernetes-dashboard
NAME                                         READY   STATUS    RESTARTS   AGE
dashboard-metrics-scraper-7b59f7d4df-55hm5   1/1     Running   0          32m
kubernetes-dashboard-5dbf55bd9d-r59fd        1/1     Running   0          32m
```
通过浏览器打开地址:https://nodeip:30001

创建service account并绑定默认管理员集群角色cluster-admin
```shell
# 创建用户
kubectl create serviceaccount dashboard-admin -n kube-system
# 用户授权
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
# 获取用户Token
kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')
```

---


1. 安装`containerd`依赖模块
```shell
# 配置模块
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
```

2. 配置内核参数
```shell
# 配置内核参数
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# 应用参数
sudo sysctl --system
```

3. 安装`containerd`
```shell
# 安装软件包
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 配置Docker镜像源
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 配置 containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
# 重启 containerd
sudo systemctl restart containerd
```

4. 配置`containerd`镜像，Cgroup
   
`vi /etc/containerd/config.toml`
```toml
...
...
  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    selinux_category_range = 1024
    <!-- 配置pause镜像仓库地址 -->
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.2"
...
...
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
        <!-- 配置Cgroup -->
          SystemdCgroup = true
...
...
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
        <!-- 配置镜像加速地址 -->
          endpoint = ["https://b9pmyelo.mirror.aliyuncs.com"]
...
...
```

5. 设置kubelet
   
`vi /etc/sysconfig/kubelet`
```shell
KUBELET_EXTRA_ARGS="--container-runtime=remote --container-runtime-endpoint=/run/containerd/containerd.sock"
```

6. 重启kubelet
```shell
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

7. 验证
```shell
kubectl get nodes -o wide
```


---
# 故障及说明


| 问题描述                            | 解决方案                                                                                                                                                 |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 初始化错误                          | 执行`kubeadm reset`进行环境重新初始化，再进行`kubeadm init`                                                                                              |
| 拉取镜像慢或pod未就绪               | 到节点主机上手动拉取一下镜像                                                                                                                             |
| 关于systemd的警告                   | 设置`docker daemon`，在`/etc/docker/daemon.json`中添加参数，`"exec-opts": ["native.cgroupdriver=systemd"]`，重启Docker`systemctl restart docker.service` |
| `kubeadm join`的token过期           | 执行命令`kubeadm token create --print-join-command`生成新的token，[参考文献](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/)     |
| `kubectl get cs`组件状态`Unhealthy` | 主要是`/etc/kubernetes/manifests/kube-controller-manager.yaml`和`/etc/kubernetes/manifests/kube-scheduler.yaml`中的port=0，需要将其注释，再重启kubelet.  |


---

# CNI组件的作用
CNI（container netowork interface，容器网络接口）：是一个容器网络规范，Kubernetes网络采用的就是这个CNI规范

CNI要求:
- 一个Pod对应一个IP
- 所有的Pod可以与任何其他Pod直接通信
- 所有节点可以与所有Pod直接通信
- Pod内部获取到的IP地址与其他Pod或节点通信时的IP地址是用一个

主流网络组件推荐：Flannel、Calico等

# k8s基本操作

- **查看节点**
```shell
kubectl get node
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   3h19m   v1.20.4
k8s-node1    Ready    <none>   133m    v1.20.4
k8s-node2    Ready    <none>   128m    v1.20.4
```

- **查看组件状态**
```shell
kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE          ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true"}
```

- **查看所有的资源及缩写**
  
  `kubectl api-resources`


- **查看Apiserver代理的URL**
```shell
kubectl cluster-info
Kubernetes control plane is running at https://172.16.4.41:6443
KubeDNS is running at https://172.16.4.41:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

- **查看集群详情**
```shell
kubectl cluster-info dump
```

- **查看资源信息**
```shell
kubectl describe 资源类型/资源名称
```
示例
```shell
kubectl describe pods/nginx-6799fc88d8-qt6wh
kubectl describe svc/nginx
```

- **查看集群最新事件**
```shell
kubectl get event
```
