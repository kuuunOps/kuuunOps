## 部署kubernetes控制平面

>部署kubernetes的控制平面，每个组件有多个点保证高可用。实例中我们在两个节点上部署 API Server、Scheduler 和 Controller Manager。当然你也可以按照教程部署三个节点的高可用，操作都是一致的。

## 1. 配置 API Server

```shell
mkdir -p /etc/kubernetes/pki
# 准备证书文件
mv ca.pem ca-key.pem \
    kube-apiserver-key.pem kube-apiserver.pem \
    kube-apiserver-kubelet-client-key.pem kube-apiserver-kubelet-client.pem \
    service-account-key.pem service-account.pem \
    kube-front-proxy-ca.pem kube-front-proxy-client.pem kube-front-proxy-client-key.pem \
    etcd-ca.pem apiserver-etcd-client.pem apiserver-etcd-client-key.pem \
    /etc/kubernetes/pki

# 配置kube-apiserver.service
# 本机内网ip
IP=172.20.10.11
# apiserver实例数
APISERVER_COUNT=2
# etcd节点
ETCD_ENDPOINTS=(172.20.10.11 172.20.10.12 172.20.10.13)
# 创建 apiserver service
cat <<EOF > /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${IP} \\
  --allow-privileged=true \\
  --apiserver-count=${APISERVER_COUNT} \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/etc/kubernetes/pki/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/etc/kubernetes/pki/etcd-ca.pem \\
  --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.pem \\
  --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client-key.pem \\
  --etcd-servers=https://${ETCD_ENDPOINTS[0]}:2379,https://${ETCD_ENDPOINTS[1]}:2379,https://${ETCD_ENDPOINTS[2]}:2379 \\
  --event-ttl=1h \\
  --kubelet-certificate-authority=/etc/kubernetes/pki/ca.pem \\
  --kubelet-client-certificate=/etc/kubernetes/pki/kube-apiserver-kubelet-client.pem \\
  --kubelet-client-key=/etc/kubernetes/pki/kube-apiserver-kubelet-client-key.pem \\
  --service-account-issuer=api \\
  --service-account-key-file=/etc/kubernetes/pki/service-account.pem \\
  --service-account-signing-key-file=/etc/kubernetes/pki/service-account-key.pem \\
  --api-audiences=api,vault,factors \\
  --service-cluster-ip-range=10.233.0.0/16 \\
  --service-node-port-range=30000-32767 \\
  --proxy-client-cert-file=/etc/kubernetes/pki/kube-front-proxy-client.pem \\
  --proxy-client-key-file=/etc/kubernetes/pki/kube-front-proxy-client-key.pem \\
  --runtime-config='api/all=true' \\
  --requestheader-client-ca-file=/etc/kubernetes/pki/kube-front-proxy-ca.pem \\
  --requestheader-allowed-names=front-proxy-client \\
  --requestheader-extra-headers-prefix=X-Remote-Extra- \\
  --requestheader-group-headers=X-Remote-Group \\
  --requestheader-username-headers=X-Remote-User \\
  --tls-cert-file=/etc/kubernetes/pki/kube-apiserver.pem \\
  --tls-private-key-file=/etc/kubernetes/pki/kube-apiserver-key.pem \\
  --v=1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
---

## 2. 配置kube-controller-manager

```shell
# 准备kubeconfig配置文件
mv kube-controller-manager.kubeconfig /etc/kubernetes/

# 创建 kube-controller-manager.service
cat <<EOF > /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem \\
  --cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem \\
  --cluster-signing-duration=876000h0m0s \\
  --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/etc/kubernetes/pki/ca.pem \\
  --service-account-private-key-file=/etc/kubernetes/pki/service-account-key.pem \\
  --service-cluster-ip-range=10.233.0.0/16 \\
  --use-service-account-credentials=true \\
  --v=1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
---

## 3. 配置kube-scheduler

```shell
mv kube-scheduler.kubeconfig /etc/kubernetes

# 创建 scheduler service 文件
cat <<EOF > /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --authentication-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \\
  --authorization-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \\
  --kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \\
  --leader-elect=true \\
  --bind-address=0.0.0.0 \\
  --port=0 \\
  --v=1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
---

## 4. 启动服务

```shell
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl restart kube-apiserver
systemctl restart kube-controller-manager
systemctl restart kube-scheduler
```

---

## 5. 服务验证

>端口验证

```shell
netstat -ntlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 172.20.10.11:2379        0.0.0.0:*               LISTEN      61048/etcd
tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      61048/etcd
tcp        0      0 172.20.10.11:2380        0.0.0.0:*               LISTEN      61048/etcd
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      806/sshd
tcp6       0      0 :::6443                 :::*                    LISTEN      70270/kube-apiserve
tcp6       0      0 :::10252                :::*                    LISTEN      68395/kube-controll
tcp6       0      0 :::10257                :::*                    LISTEN      68395/kube-controll
tcp6       0      0 :::10259                :::*                    LISTEN      68410/kube-schedule
```

>日志验证

```shell
journalctl -f
```

---

## 6. 配置kubectl

```shell
# 创建kubectl的配置目录
mkdir ~/.kube/
# 把管理员的配置文件移动到kubectl的默认目录
mv ~/admin.kubeconfig ~/.kube/config
# 测试
kubectl get nodes
```
>在执行 kubectl exec、run、logs 等命令时，apiserver 会转发到 kubelet。这里定义 RBAC 规则，授权 apiserver 调用 kubelet API。

```shell
kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes
```