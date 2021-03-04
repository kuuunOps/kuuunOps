# kubeadm快速部署一个K8S集群

主要步骤：
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

![单master架构](../../../_media/single-master.jpg)

| 角色       | IP          |
| ---------- | ----------- |
| k8s-master | 172.16.4.6  |
| k8s-node1  | 172.16.4.11 |
| k8s-node2  | 172.16.4.12 |

- 端口
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

- 关闭防火墙
```bash
$ sudo systemctl stop firewalld
$ sudo systemctl disable firewalld
```

- 关闭selinux
```bash
$ sudo sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
$ sudo setenforce 0  # 临时
```

- 关闭swap
```bash
$ sudo swapoff -a  # 临时
$ sudo vim /etc/fstab  # 永久
```

- 设置主机名
```bash
$ sudo hostnamectl set-hostname <hostname>
```

- master上添加hosts解析
```bash
    172.16.4.6 k8s-master
    172.16.4.11 k8s-node1
    172.16.4.12 k8s-node2
```

- 将桥接的IPv4流量传递到iptables的链
```bash
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system  # 生效
```

- 时间同步
```bash
apt install ntpdate -y
ntpdate time.windows.com
```

## 3. 安装Docker/kubeadm/kubelet(所有节点)
Kubernetes默认CRI（容器运行时）为Docker，因此先安装Docker。

1. 安装docker

安装docker
```shell
# step 1: 安装必要的一些系统工具
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新并安装Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce=5:19.03.15~3-0~ubuntu-bionic
```
配置镜像加速
```bash
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
```

设置docker daemon
```bash
#  /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
sudo systemctl restart docker.service
```

2. 添加阿里云kubernetes镜像源
```shell
apt-get update && apt-get install -y apt-transport-https
# 
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
# 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
```

3. 安装kubeadm，kubelet和kubectl
由于版本更新频繁，这里指定版本号部署
```bash
    apt-get update && apt-get install -y kubelet=1.19.0-00 kubeadm=1.19.0-00 kubectl=1.19.0-00
    systemctl enable kubelet
```

## 4. 部署Kubernetes Master
官方文档初始化参考
>https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file
>
>https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node

在master上执行
```bash
kubeadm init \
  --apiserver-advertise-address=172.16.4.6 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.19.0 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all
```

- apiserver-advertise-address 集群通告地址
- image-repository 拉取镜像地址
- kubernetes-version k8s的版本
- service-cidr 集群内部虚拟网络，Pod统一访问入口
- pod-network-cidr Pod网络，与下面部署的CNI网络组件yaml中保持一致

或者使用配置文件引导

kubeadm.conf
```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.19.0
imageRepository: registry.aliyuncs.com/google_containers
networking:
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
```
执行命令
```shell
kubeadm init --config kubeadm.conf --ignore-preflight-errors=all
W0302 12:59:11.557141    3575 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.19.0
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.16.4.6][certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [172.16.4.6 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [172.16.4.6 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 20.003496 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.19" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 325oi8.pfs18g5blz29qlo8
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.4.6:6443 --token 325oi8.pfs18g5blz29qlo8 \
    --discovery-token-ca-cert-hash sha256:118fe896af1c01afe5e543cacc880a92c6018ae9ab40af4b1b4b15e747d2a2ac
```
拷贝kubectl使用的连接k8s认证文件到默认路径
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
查看节点
```bash
kubectl get nodes
NAME         STATUS     ROLES    AGE    VERSION
k8s-master   NotReady   master   9m1s   v1.19.0
```

**总结：**
kubeadm初始化流程
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


## 5. 添加node节点

在node节点上执行集群添加命令，命令为kubeadm init输出的kubeadm join命令
```shell
kubeadm join 172.16.4.6:6443 --token 325oi8.pfs18g5blz29qlo8 \
    --discovery-token-ca-cert-hash sha256:118fe896af1c01afe5e543cacc880a92c6018ae9ab40af4b1b4b15e747d2a2ac
```

默认token有效期为24小时，当过期之后，该token就不可用了。这时就需要重新创建token，操作如下：
```shell
kubeadm token create
kubeadm token list
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
118fe896af1c01afe5e543cacc880a92c6018ae9ab40af4b1b4b15e747d2a2ac
kubeadm join 192.168.31.61:6443 --token 325oi8.pfs18g5blz29qlo8 --discovery-token-ca-cert-hash sha256:118fe896af1c01afe5e543cacc880a92c6018ae9ab40af4b1b4b15e747d2a2ac
```
或者使用快捷命令生成
```bash
kubeadm token create --print-join-command
```
[参考文献](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/)

## 6. 部署容器网络组件(CNI)
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
wget https://docs.projectcalico.org/manifests/calico.yaml
```
修改字段`CALICO_IPV4POOL_CIDR`内容与`kubeadm init`指定的网络一致。
默认为：
```yaml
...
- name: CALICO_IPV4POOL_CIDR
  value: "192.168.0.0/16"
...
```
应用配置文件
```bash
kubectl apply -f calico.yaml
```
再次查看节点状态
```bash
kubectl get pods -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-6949477b58-j9szj   1/1     Running   0          16m
calico-node-2qnqz                          1/1     Running   0          16m
calico-node-czwl8                          1/1     Running   1          16m
calico-node-qpc7k                          1/1     Running   0          16m
coredns-6d56c8448f-5vfdc                   1/1     Running   0          109m
coredns-6d56c8448f-sjcmd                   1/1     Running   0          109m
etcd-k8s-master                            1/1     Running   1          110m
kube-apiserver-k8s-master                  1/1     Running   1          110m
kube-controller-manager-k8s-master         1/1     Running   2          110m
kube-proxy-clpdg                           1/1     Running   2          109m
kube-proxy-rfqvm                           1/1     Running   0          40m
kube-proxy-zwzsb                           1/1     Running   0          44m
kube-scheduler-k8s-master                  1/1     Running   1          110m
```
再确认节点状态
```shell
kubectl get nodes
NAME         STATUS   ROLES    AGE    VERSION
k8s-master   Ready    master   112m   v1.19.0
k8s-node1    Ready    <none>   46m    v1.19.0
k8s-node2    Ready    <none>   42m    v1.19.0
```

## 7. 测试
```shell
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pod,svc
```

## 8. 部署Web UI

```shell
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml
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

## 故障

- 初始化错误后
执行清除并初始化环境
```shell
kubeadm reset
```
- 拉取镜像慢或pod未就绪
节点主机上手动拉取一下

- `kubectl get cs`组件状态`Unhealthy`
主要是`/etc/kubernetes/manifests/kube-controller-manager.yaml`和`/etc/kubernetes/manifests/kube-scheduler.yaml`中的port=0，需要将其注释，再重启kublet.
```shell
kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true"}
```

## CNI组件的作用
CNI（container netowork interface，容器网络接口）：是一个容器网络规范，Kubernetes网络采用的就是这个CNI规范

CNI要求:
- 一个Pod对应一个IP
- 所有的Pod可以与任何其他Pod直接通信
- 所有节点可以与所有Pod直接通信
- Pod内部获取到的IP地址与其他Pod或节点通信时的IP地址是用一个

主流网络组件推荐：Flannel、Calico等

## 查看集群状态

- 查看节点
```shell
kubectl get node
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   3h19m   v1.19.0
k8s-node1    Ready    <none>   133m    v1.19.0
k8s-node2    Ready    <none>   128m    v1.19.0
```

- 查看组件状态
```shell
kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE          ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true"}
```
通过`kubectl api-resources`可以查看所有的资源缩写


- 查看Apiserver代理的URL
```shell
kubectl cluster-info
Kubernetes master is running at https://172.16.4.6:6443
KubeDNS is running at https://172.16.4.6:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

- 查看集群详情
```shell
kubectl cluster-info dump
```

- 查看资源信息
```shell
kubectl describe 资源类型/资源名称
```
示例
```shell
kubectl describe pods/nginx-6799fc88d8-qt6wh
kubectl describe svc/nginx
```

- 查看集群最新事件
```shell
kubectl get event
```
