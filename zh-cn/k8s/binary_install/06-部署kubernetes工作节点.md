## 部署kubernetes工作节点

## 1. 安装containerd

```shell
# 设定containerd的版本号
VERSION=1.4.4
# 下载压缩包
wget https://github.com/containerd/containerd/releases/download/v${VERSION}/cri-containerd-cni-${VERSION}-linux-amd64.tar.gz
# 解压
tar xf cri-containerd-cni-1.4.4-linux-amd64.tar.gz -C /
# 生成containerd配置文件
mkdir -p /etc/containerd
# 默认配置生成配置文件
containerd config default > /etc/containerd/config.toml
# 定制化配置（可选）
vi /etc/containerd/config.toml
# 启动containerd
systemctl enable containerd
systemctl restart containerd
# 检查状态
systemctl status containerd
```
>定制化配置`/etc/containerd/config.toml`

```shell
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

---

## 2. 配置kubelet

```shell
mkdir -p /etc/kubernetes/pki/
mkdir -p /etc/kubernetes/manifests
mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem ca.pem ca-key.pem /etc/kubernetes/pki/
mv ${HOSTNAME}.kubeconfig /etc/kubernetes/kubeconfig
IP=172.20.10.12
# 写入kubelet配置文件
cat <<EOF > /etc/kubernetes/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/etc/kubernetes/pki/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "169.254.25.10"
podCIDR: "10.200.0.0/16"
address: ${IP}
readOnlyPort: 0
staticPodPath: /etc/kubernetes/manifests
healthzPort: 10248
healthzBindAddress: 127.0.0.1
kubeletCgroups: /systemd/system.slice
resolvConf: "/etc/resolv.conf"
runtimeRequestTimeout: "15m"
kubeReserved:
  cpu: 200m
  memory: 512M
tlsCertFile: "/etc/kubernetes/pki/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/etc/kubernetes/pki/${HOSTNAME}-key.pem"
EOF
```

>配置kubelet服务

```shell
cat <<EOF > /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/etc/kubernetes/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/etc/kubernetes/kubeconfig \\
  --network-plugin=cni \\
  --node-ip=${IP} \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

## 3. 配置nginx-proxy

>nginx配置文件

```shell
mkdir -p /etc/nginx
# master ip列表
MASTER_IPS=(172.20.10.11 172.20.10.12)
# 执行前请先copy一份，并修改好upstream的 'server' 部分配置
cat <<EOF > /etc/nginx/nginx.conf
error_log stderr notice;

worker_processes 2;
worker_rlimit_nofile 130048;
worker_shutdown_timeout 10s;

events {
  multi_accept on;
  use epoll;
  worker_connections 16384;
}

stream {
  upstream kube_apiserver {
    least_conn;
    server ${MASTER_IPS[0]}:6443;
    server ${MASTER_IPS[1]}:6443;
  }

  server {
    listen        127.0.0.1:6443;
    proxy_pass    kube_apiserver;
    proxy_timeout 10m;
    proxy_connect_timeout 1s;
  }
}

http {
  aio threads;
  aio_write on;
  tcp_nopush on;
  tcp_nodelay on;

  keepalive_timeout 5m;
  keepalive_requests 100;
  reset_timedout_connection on;
  server_tokens off;
  autoindex off;

  server {
    listen 8081;
    location /healthz {
      access_log off;
      return 200;
    }
    location /stub_status {
      stub_status on;
      access_log off;
    }
  }
}
EOF
```
>nginx manifest

```shell
cat <<EOF > /etc/kubernetes/manifests/nginx-proxy.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-proxy
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    k8s-app: kube-nginx
spec:
  hostNetwork: true
  dnsPolicy: ClusterFirstWithHostNet
  nodeSelector:
    kubernetes.io/os: linux
  priorityClassName: system-node-critical
  containers:
  - name: nginx-proxy
    image: docker.io/library/nginx:1.19
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        cpu: 25m
        memory: 32M
    securityContext:
      privileged: true
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8081
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8081
    volumeMounts:
    - mountPath: /etc/nginx
      name: etc-nginx
      readOnly: true
  volumes:
  - name: etc-nginx
    hostPath:
      path: /etc/nginx
EOF
```

---
## 4. 配置kube-proxy

>配置文件

```shell
mv kube-proxy.kubeconfig /etc/kubernetes/
# 创建 kube-proxy-config.yaml
cat <<EOF > /etc/kubernetes/kube-proxy-config.yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 0.0.0.0
clientConnection:
  kubeconfig: "/etc/kubernetes/kube-proxy.kubeconfig"
clusterCIDR: "10.200.0.0/16"
mode: ipvs
EOF
```
>kube-proxy 服务文件

```shell
cat <<EOF > /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/etc/kubernetes/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
---

## 5. 启动服务

```shell
# 服务启动
systemctl daemon-reload
systemctl enable kubelet kube-proxy
systemctl restart kubelet kube-proxy
# 验证日志
journalctl -f -u kubelet
journalctl -f -u kube-proxy
```
