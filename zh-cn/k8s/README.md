# Kubernetes

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


## 服务器初始化配置

### 1. 安装要求

- 一台或多台机器，操作系统：Ubuntu 16.04+，CentOS 7+
- CPU:2核+
- 内存：2GB+
- 集群中所有机器内网或外网互通
- 禁止swap分区

### 2. 环境准备

![单master架构](../../_media/single-master.jpg)

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

### 3. 安装Docker/kubeadm/kubelet(所有节点)
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

### 4. 部署Kubernetes Master
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


### 5. 添加node节点

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

### 6. 部署容器网络组件(CNI)
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

### 7. 测试
```shell
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pod,svc
```

### 8. 部署Web UI

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

### 故障

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

### CNI组件的作用
CNI（container netowork interface，容器网络接口）：是一个容器网络规范，Kubernetes网络采用的就是这个CNI规范

CNI要求:
- 一个Pod对应一个IP
- 所有的Pod可以与任何其他Pod直接通信
- 所有节点可以与所有Pod直接通信
- Pod内部获取到的IP地址与其他Pod或节点通信时的IP地址是用一个

主流网络组件推荐：Flannel、Calico等

### 查看集群状态

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

---
---

## Kubectl命令行管理工具

### kubeconfig配置文件

kubectl命令默认会读取`$HOME/.kube/config`配置文件，否则会访问`localhost:8080`。

或者使用参数`--kubeconfig`指定配置文件
```shell
kubectl get node --kubeconfig=admin.conf
```

#### 文件格式：

**集群**
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: 
    server: https://172.16.4.6:6443
  name: kubernetes
```

**上下文**
```yaml
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
```

**当前上下文**
```yaml
current-context: kubernetes-admin@kubernetes
```

**客户端认证信息**
```yaml
users:
- name: kubernetes-admin
user:
    client-certificate-data: 
    client-key-data: 
```

### 牛刀小试

### 常见命令
[参考文献](https://kubernetes.io/zh/docs/reference/kubectl/overview/)
<table>
<thead>
  <tr>
    <th>命令类型</th>
    <th>命令</th>
    <th>描述</th>
  </tr>
</thead>
<tbody>
  <tr>
    <th rowspan="8">基础命令</th>
    <td>create</td>
    <td>通过文件名或标准输入创建资源</td>
  </tr>
  <tr>
    <td>expose</td>
    <td>为Deployment,Pod创建Service </td>
  </tr>
  <tr>
    <td>run</td>
    <td>在集群中运行一个特定的镜像 </td>
  </tr>
  <tr>
    <td>set</td>
    <td>在对象上设置特定的功能</td>
  </tr>
  <tr>
    <td>explain</td>
    <td>文档参考资料</td>
  </tr>
  <tr>
    <td>get</td>
    <td>显示一个或多个资源</td>
  </tr>
  <tr>
    <td>edit</td>
    <td>使用系统编辑器编译一个资源</td>
  </tr>
  <tr>
    <td>delete</td>
    <td>通过文件名、标准输入、资源名称或标签选择器来删除资源</td>
  </tr>
  <tr>
    <th rowspan="4">部署命令</th>
    <td>rollout</td>
    <td>管理Deployment、Daemonset资源的发布（例如状态、发布记录、回滚等）</td>
  </tr>
  <tr>
    <td>rolling-update</td>
    <td>滚动升级，仅限ReplicaionController</td>
  </tr>
  <tr>
    <td>scale</td>
    <td>对Deployment、ReplicaSet、RC或job资源扩容或缩容Pod数量</td>
  </tr>
  <tr>
    <td>autoscale</td>
    <td>为Deploy,RS,RC配置自动伸缩规则（依赖metrics-server和hpa）</td>
  </tr>
  <tr>
    <th rowspan="7">集群管理命令</th>
    <td>certificate</td>
    <td>修改证书资源</td>
  </tr>
  <tr>
    <td>cluster-info</td>
    <td>显示集群信息</td>
  </tr>
  <tr>
    <td>top</td>
    <td>查看资源利用率（依赖metrics-server）</td>
  </tr>
  <tr>
    <td>cordon</td>
    <td>标记节点不可调度</td>
  </tr>
  <tr>
    <td>uncordon</td>
    <td>标记节点可调度</td>
  </tr>
  <tr>
    <td>drain</td>
    <td>驱逐节点上的应用，准备下线维护</td>
  </tr>
  <tr>
    <td>taint</td>
    <td>修改节点taint标记</td>
  </tr>
  <tr>
    <th rowspan="7">故障诊断和调试命令</th>
    <td>describe</td>
    <td>显示资源详细信息</td>
  </tr>
  <tr>
    <td>logs</td>
    <td>查看Pod内容器日志，如果Pod有多个容器，-c参数指定容器名称</td>
  </tr>
  <tr>
    <td>attach</td>
    <td>附加到Pod内的一个容器</td>
  </tr>
  <tr>
    <td>exec</td>
    <td>在容器内执行命令</td>
  </tr>
  <tr>
    <td>port-forward</td>
    <td>为Pod创建本地端口映射</td>
  </tr>
  <tr>
    <td>proxy</td>
    <td>为Kubernetes API server创建代理</td>
  </tr>
  <tr>
    <td>cp</td>
    <td>拷贝文件或目录到容器中，或者从容器内向外拷贝</td>
  </tr>
  <tr>
    <th rowspan="4">高级命令</th>
    <td>apply</td>
    <td>从文件名或标准输入对资源创建/更新</td>
  </tr>
  <tr>
    <td>patch</td>
    <td>使用补丁方式修改、更新资源的某些字段</td>
  </tr>
  <tr>
    <td>replace</td>
    <td>从文件名或标准输入替换一个资源</td>
  </tr>
  <tr>
    <td>convert</td>
    <td>在不同API版本之间转换对象定义</td>
  </tr>
  <tr>
    <th rowspan="3">设置命令</th>
    <td>lable</td>
    <td>给资源设置、更新标签</td>
  </tr>
  <tr>
    <td>annotate</td>
    <td>给资源设置、更新注解</td>
  </tr>
  <tr>
    <td>completion</td>
    <td>kubectl工具自动补全，source<(kubectl completion bash) (依赖软件包bash-completion)</td>
  </tr>
  <tr>
    <th rowspan="5">其他命令</th>
    <td>api-resources</td>
    <td>查看所有资源</td>
  </tr>
  <tr>
    <td>api-versions</td>
    <td>打印受支持的API版本</td>
  </tr>
  <tr>
    <td>config</td>
    <td>修改kubeconfig文件（用于访问API，比如配置认证信息）</td>
  </tr>
  <tr>
    <td>help</td>
    <td>所有命令帮助</td>
  </tr>
  <tr>
    <td>version</td>
    <td>查看kubectl和k8s版本</td>
  </tr>
</tbody>
</table>

### 使用deployment控制器部署
```shell
kubectl create deployment web --image=lizhenliang/java-demo
kubectl get deploy,pods
```

### 使用service将pod暴露出去
```shell
kubectl expose deployment web --port=80 --target-port=8080 --type=NodePort
kubectl get service
```

**访问应用**

端口随机生成的，可以通过`get svc`获取
http://NodeIP:Port


### 基本资源概念

- Pod：k8s最小部署单元，一组容器的集合
- Deployment：最常见的工作负载控制器，用于更高级部署和管理Pod
- Service：为一组Pod提供负载均衡，对外提供统一访问入口
- Label：标签，附加到某个资源上，拥有关联对象、查询和筛选
  - 查看标签
  ```shell
  kubectl get pods --show-labels
  NAME                     READY   STATUS    RESTARTS   AGE     LABELS
  nginx-6799fc88d8-qt6wh   1/1     Running   1          7h11m   app=nginx,pod-template-hash=6799fc88d8
  web-674477549d-2c7v6     1/1     Running   0          5h27m   app=web,pod-template-hash=674477549d
  web-674477549d-d8mx8     1/1     Running   0          5m      app=web,pod-template-hash=674477549d
  web-674477549d-gtxqk     1/1     Running   0          5m      app=web,pod-template-hash=674477549d
  ```
  - 筛选
  ```shell
  kubectl get pods -l app=nginx
  NAME                     READY   STATUS    RESTARTS   AGE
  nginx-6799fc88d8-qt6wh   1/1     Running   1          7h12m
  ```
- Namespaces：命名空间，将对象逻辑上隔离，也利于权限控制，从而形成多个虚拟集群
  - 应用场景
    - 根据不同团队划分命名空间
    - 根据项目划分命名空间
  - `kubectl get namespace`查看命名空间
    - default：默认命名空间
    - kube-system：K8S系统方面的命名空间
    - kube-public：公开的命名空间，谁都可以访问
    - kube-node-lease：K8S内容命名空间
  - 命名空间的指定
    - 命令行：`-n`
    - 配置文件：`namespace`字段
  - 创建命名空间
  ```shell
  kubectl create namespace test
  ```

---
---
## 资源编排（YAML）


模板示例：
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    # 这里是 Pod 模版
    spec:
      containers:
      - name: hello
        image: busybox
        command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600']
      restartPolicy: OnFailure
    # 以上为 Pod 模版
```

### YAML文件格式说明

**语法格式：**
- 缩进表示层级关系
- 不支持制表符`tab`缩进，使用空格缩进
- 通常开头缩进2个空格
- 字符后缩进1个空格，如：冒号、逗号等
- `---`表示YAML格式，一个文件的格式
- `#`注释

### YAML文件创建资源对象

**deployment示例文件：**
```yaml
# 控制器定义
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  # 被控制对象
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: lizhenliang/java-demo
```
| 字段名称   | 描述       |
| ---------- | ---------- |
| apiVersion | API版本    |
| kind       | 资源类型   |
| metadata   | 资源元数据 |
| spec       | 资源规格   |
| replicas   | 副本数量   |
| selector   | 标签选择器 |
| template   | Pod模板    |
| metadata   | Pod元数据  |
| spec       | Pod规格    |
| containers | 容器配置   |

**service示例文件：**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: default
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: web
  type: NodePort
```
| 字段名称 | 描述        |
| -------- | ----------- |
| ports    | 端口        |
| selector | 标签选择器  |
| type     | Service类型 |

**部署**

- create
适用于第一次创建
```shell
kubectl create -f deployment.yaml
```

- apply
支持创建，更新
```
kubectl apply -f deployment.yaml
```

**删除**
```
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
```

### 资源字段太多，如何记录

#### 使用create命令快速生成YAML
- 示例1：快速生成`deployment.yaml`文件
  ```shell
  kubectl create deployment web --image=nginx:1.18 -n default --dry-run=client -o yaml > example-deployment.yaml
  ```
  文件内容：
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    creationTimestamp: null
    labels:
      app: web
    name: web
    namespace: default
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: web
    strategy: {}
    template:
      metadata:
        creationTimestamp: null
        labels:
          app: web
      spec:
        containers:
        - image: nginx:1.18
          name: nginx
          resources: {}
  status: {}
  ```
- 示例2：快速生成`service.yaml`文件
  ```shell
    kubectl expose deployment web --port 80 --target-port=80 --type=NodePort -n default --dry-run=client -o yaml > example-service.yaml
  ```
  文件内容：
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    creationTimestamp: null
    labels:
      app: web
    name: web
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 80
    selector:
      app: web
    type: NodePort
  status:
    loadBalancer: {}
  ```

#### 通过get命令根据现有资源导出YAML

- 示例：
  ```shell
  kubectl get deployments.apps web -o yaml > example-deployment2.yaml
  ```
  文件内容
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    annotations:
      deployment.kubernetes.io/revision: "1"
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"creationTimestamp":null,"labels":{"app":"web"},"name":"web","namespace":"default"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"web"}},"strategy":{},"template":{"metadata":{"creationTimestamp":null,"labels":{"app":"web"}},"spec":{"containers":[{"image":"nginx:1.18","name":"nginx","resources":{}}]}}},"status":{}}
    creationTimestamp: "2021-03-03T02:06:52Z"
    generation: 1
    labels:
      app: web
    managedFields:
    - apiVersion: apps/v1
      fieldsType: FieldsV1
      fieldsV1:
        f:metadata:
          f:annotations:
            .: {}
            f:kubectl.kubernetes.io/last-applied-configuration: {}
          f:labels:
            .: {}
            f:app: {}
        f:spec:
          f:progressDeadlineSeconds: {}
          f:replicas: {}
          f:revisionHistoryLimit: {}
          f:selector:
            f:matchLabels:
              .: {}
              f:app: {}
          f:strategy:
            f:rollingUpdate:
              .: {}
              f:maxSurge: {}
              f:maxUnavailable: {}
            f:type: {}
          f:template:
            f:metadata:
              f:labels:
                .: {}
                f:app: {}
            f:spec:
              f:containers:
                k:{"name":"nginx"}:
                  .: {}
                  f:image: {}
                  f:imagePullPolicy: {}
                  f:name: {}
                  f:resources: {}
                  f:terminationMessagePath: {}
                  f:terminationMessagePolicy: {}
              f:dnsPolicy: {}
              f:restartPolicy: {}
              f:schedulerName: {}
              f:securityContext: {}
              f:terminationGracePeriodSeconds: {}
      manager: kubectl-client-side-apply
      operation: Update
      time: "2021-03-03T02:06:52Z"
    - apiVersion: apps/v1
      fieldsType: FieldsV1
      fieldsV1:
        f:metadata:
          f:annotations:
            f:deployment.kubernetes.io/revision: {}
        f:status:
          f:availableReplicas: {}
          f:conditions:
            .: {}
            k:{"type":"Available"}:
              .: {}
              f:lastTransitionTime: {}
              f:lastUpdateTime: {}
              f:message: {}
              f:reason: {}
              f:status: {}
              f:type: {}
            k:{"type":"Progressing"}:
              .: {}
              f:lastTransitionTime: {}
              f:lastUpdateTime: {}
              f:message: {}
              f:reason: {}
              f:status: {}
              f:type: {}
          f:observedGeneration: {}
          f:readyReplicas: {}
          f:replicas: {}
          f:updatedReplicas: {}
      manager: kube-controller-manager
      operation: Update
      time: "2021-03-03T02:06:55Z"
    name: web
    namespace: default
    resourceVersion: "183098"
    selfLink: /apis/apps/v1/namespaces/default/deployments/web
    uid: 8205a2d9-371c-4440-9dea-472f99295783
  spec:
    progressDeadlineSeconds: 600
    replicas: 1
    revisionHistoryLimit: 10
    selector:
      matchLabels:
        app: web
    strategy:
      rollingUpdate:
        maxSurge: 25%
        maxUnavailable: 25%
      type: RollingUpdate
    template:
      metadata:
        creationTimestamp: null
        labels:
          app: web
      spec:
        containers:
        - image: nginx:1.18
          imagePullPolicy: IfNotPresent
          name: nginx
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
  status:
    availableReplicas: 1
    conditions:
    - lastTransitionTime: "2021-03-03T02:06:55Z"
      lastUpdateTime: "2021-03-03T02:06:55Z"
      message: Deployment has minimum availability.
      reason: MinimumReplicasAvailable
      status: "True"
      type: Available
    - lastTransitionTime: "2021-03-03T02:06:52Z"
      lastUpdateTime: "2021-03-03T02:06:55Z"
      message: ReplicaSet "web-6c57bdf5f4" has successfully progressed.
      reason: NewReplicaSetAvailable
      status: "True"
      type: Progressing
    observedGeneration: 1
    readyReplicas: 1
    replicas: 1
    updatedReplicas: 1
  ```

#### 资源可用字段查询

- 示例
  ```shell
  # 查询pod可用字段
  kubectl explain pod
  # 查询pod下的spec下可用字段
  kubectl explain pod.spec
  ```

---
---

## 深入理解Pod对象：基本管理

### Pod基本概念

>Pod 是Kubernetes中创建和管理的、最小的、可部署的计算单元。一个Pod（就像一个豌豆荚）有一个容器或多个容器组成，这些容器共享存储、网络。

**特点**
- 一个Pod可以理解为是一个应用实例，提供服务
- Pod中容器始终部署在一个Node上
- Pod中容器共享网络、存储资源
- Kubernetes直接管理Pod，而不是容器

### Pod存在的意义

**主要用法**
- 运行单个容器：最常见用法，可以将Pod看做是单个容器的抽象封装
- 运行多个容器：封装多个紧密耦合且需要共享资源的应用程序

**运行多个容器的应用场景**
- 两个应用直接发生文件交互
- 两个应用需要通过`127.0.0.1`或者`socket`通信
- 两个应用需要发生频繁的调用

### Pod资源共享实现机制

- 共享网络：将业务容器网络加入到“负责网络的容器”实现网络共享。
- 共享存储：容器通过数据卷共享数据。

### Pod常用管理命令


**网络共享验证**
example-net-pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: test
  name: pod-net-test
  namespace: default
spec:
  containers:
  - image: busybox
    name: test
    command: ["/bin/sh","-c","sleep 360000"]
  - image: nginx
    name: web
```

**数据卷共享验证**
example-volume-pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: test
  name: pod-volume-test
  namespace: default
spec:
  containers:
  - image: busybox
    name: test
    command: ["/bin/sh","-c","sleep 360000"]
    volumeMounts:
    - name: data
      mountPath: /data
  - image: nginx
    name: web
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: data
    emptyDir: {}
```

- 创建Pod
```shell
kubectl apply -f example-pod.yaml
```
或者命令
```shell
kubectl run nginx --image=nginx
```

- 实时观察Pod状态
```shell
kubectl get pod -w
NAME                   READY   STATUS    RESTARTS   AGE
pod-net-test           2/2     Running   0          59s
```

- 观察pod发生的事件
```shell
kubectl describe pods pod-volume-test
```

- 进入容器
```shell
kubectl exec -it pod-net-test -- sh
```

- 查看日志
```shell
kubectl logs pod-net-test -c web -f 
```

- 进入指定的容器中
```shell
kubectl exec -it pod-net-test -c test -- sh
```

- 删除pod
```shell
kubectl delete -f example-volume-pod.yaml
# 或者
kubectl delete pod-volume-test
```

### k8s对pod状态的管理

```shell
kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE     IP               NODE        NOMINATED NODE   READINESS GATES
web-6c57bdf5f4-6x8ct   1/1     Running   0          4h24m   10.244.169.140   k8s-node2   <none>           <none>
```
- Pending：Pod未调度，或者Pod已调度正在拉去镜像中
- Running：Pod已经运行
- Failed：Pod内容器停止运行
- Success：Pod内容器正常结束
- Unkown：Master与Node失联

### 应用自修复（重启策略+健康检查）

#### 重启策略（restartPolicy）
- Always：当容器终止退出后，总是重启容器，默认策略
- OnFailure：当容器异常退出（退出状态码非0），才重启容器。
- Never：当容器终止退出，从不重启容器

#### 健康检查类型
- livenessProbe（存活检查）：如果检查失败，将杀死容器，根据Pod的`restartPolicy`来操作
- readinessProbe（就绪检查）：如果检查失败，Kubernetes会把Pod从`service endpoints`中剔除
- startupProbe（启动检查）：

#### 检查方法
- httpGet：发送HTTP请求，返回200-400范围状态码为成功
- exec：执行shell命令返回状态码是0为成功
- tcpSocket：发起`TCP Socket`建立成功

[参考文献](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

**示例yaml**
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      # 启动容器后多少秒健康检查
      initialDelaySeconds: 5
      # 以后间隔多少秒检查一次
      periodSeconds: 5
```
这个容器生命的前 30 秒， `/tmp/healthy`文件是存在的。 所以在这最开始的 30 秒内，执行命令`cat /tmp/healthy`会返回成功代码。 30 秒之后，执行命令` cat /tmp/healthy `就会返回失败代码。

- ` initialDelaySeconds `：容器启动后要等待多少秒后存活和就绪探测器才被初始化，默认是 0 秒，最小值是 0。
- ` periodSeconds `：执行探测的时间间隔（单位是秒）。默认是 10 秒。最小值是 1。
- ` timeoutSeconds `：探测的超时后等待多少秒。默认值是 1 秒。最小值是 1。
- ` successThreshold `：探测器在失败后，被视为成功的最小连续成功数。默认值是 1。 存活和启动探测的这个值必须是 1。最小值是 1。
- ` failureThreshold `：当探测失败时，Kubernetes 的重试次数。 存活探测情况下的放弃就意味着重新启动容器。 就绪探测情况下的放弃 Pod 会被打上未就绪的标签。默认值是 3。最小值是 1。


### Pod注入环境变量

#### 变量值定义方式

- 自定义变量值
- 变量值从Pod属性获取
- 变量值从Secret、ConfigMap获取

**示例**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-envars
spec:
  containers:
  - name: test
    image: busybox
    command: [ "sh", "-c", "sleep 36000"]
    env:
    - name: MY_NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    - name: MY_POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: MY_POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: MY_POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: NUMBER
      value: "123456"
    - name: NAME
      value: "hello"
```

### Init初始化容器应用

>Init Container：顾名思义，用于初始化工作，执行完就结束，可以理解为一次性任务。

- 支持大部分应用容器配置，但不支持健康检查 
- 优先应用容器执行

**应用场景:**
- 环境检查：例如确保应用容器依赖的服务启动后再启动应用容器
- 初始化配置：例如给应用容器准备配置文件

**示例：部署一个web网站，网站程序没有打包到镜像中，而是希望从代码 仓库中动态拉取放到应用容器中。**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  initContainers:
  - name: download
    image: busybox
    command:
    - wget
    - "-O"
    - "/opt/index.html"
    - http://www.ctnrs.com
    volumeMounts:
    - name: wwwroot
      mountPath: "/opt"
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: wwwroot
      mountPath: /usr/share/nginx/html
  volumes:
  - name: wwwroot
    emptyDir: {}
```

因此，Pod中会有这几种类型的容器：
- Infrastructure Container：基础容器
  - 维护整个Pod网络空间
- InitContainers：初始化容器
  - 先于业务容器开始执行
- Containers：业务容器
  - 并行启动


