## 一、环境准备

### 1、主机规划

### 2、关闭防火墙、selinux、swap、重置IPtables，同步时间

```shell
# 关闭selinux
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

# 关闭防火墙
systemctl stop firewalld && systemctl disable firewalld

# 关闭swap
swapoff -a && free –h

# 重置iptables
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT

# 关闭dnsmasq
service dnsmasq stop && systemctl disable dnsmasq

# 同步时间
ntpdate ntp1.aliyun.com
```

### 3、调整内核

```shell
# 配置内核参数
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf 
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# 配置模块
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
```

## 二、安装docker

>配置镜像源

```shell
# step 1: 安装必要的一些系统工具
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
 
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新并安装Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce=19.03
 
# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# apt-cache madison docker-ce
#   docker-ce | 17.03.1~ce-0~ubuntu-xenial | https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial/stable amd64 Packages
#   docker-ce | 17.03.0~ce-0~ubuntu-xenial | https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial/stable amd64 Packages
# Step 2: 安装指定版本的Docker-CE: (VERSION例如上面的17.03.1~ce-0~ubuntu-xenial)
# sudo apt-get -y install docker-ce=[VERSION]
```
>配置docker

```shell
REGISTRE_MIRROR="https://b9pmyelo.mirror.aliyuncs.com"
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": ["${REGISTRE_MIRROR}"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo docker info
```

>验证

```shell
sudo docker run hello-world
```

## 三、安装 kubeadm、kubelet 和 kubectl

>配置镜像源

```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg
# 添加镜像源地址
cat << EOF |sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

```

>安装

```shell
# 确认要升级的版本
# sudo apt-get update
# sudo apt-cache madison kubeadm|sort -r
sudo apt-get update
sudo apt-get install -y kubelet=1.19.8-00 kubeadm=1.19.8-00 kubectl=1.19.8-00
sudo apt-mark hold kubelet kubeadm kubectl
kubeadm version
```

## 四、集群初始化

>初始化配置文件

```shell
K8S_VERSION="v1.19.8"
cat << EOF |sudo tee config.yaml 
apiVersion: kubeadm.k8s.io/v1beta2
clusterName: kubernetes
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: ${K8S_VERSION}
networking:
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
EOF
```
>初始化

```shell
# 拉取镜像
sudo kubeadm config images pull --config config.yaml
# 初始化
sudo kubeadm init --config config.yaml
```

## 五、安装网络插件

>calico

```shell
curl -o calico.yaml https://docs.projectcalico.org/manifests/calico.yaml
```

>配置IP自动发现

```shell
# 修改前
- name: IP
  value: "autodetect"

# 修改后
- name: IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
```

>配置CIDR

```shell
- name: CALICO_IPV4POOL_CIDR
  value: "10.200.0.0/16"
```

>部署

```shell
kubectl apply -f calico.yaml
```

## 六、添加node节点

```shell
sudo kubeadm join 172.16.4.40:6443 --token pssx6x.mt95boyyrabdjdws \
    --discovery-token-ca-cert-hash sha256:c34131aff478faef6789615962edc220a2cf628e907f48b7f4672b87932c2251
```

## 七、资源管理

```shell
curl -fsSLo metrics-server.yaml https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.4/components.yaml

# 更换镜像源
sed -i "s#image:.*#image: bitnami/metrics-server:0.4.4#" metrics-server.yaml

# 增加启动参数，跳过TLS证书验证
--kubelet-insecure-tls
```
>部署

```shell
kubectl apply -f metrics-server.yaml
kubectl top nodes
```

