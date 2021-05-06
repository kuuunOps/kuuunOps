## 部署etcd集群

## 1. 配置etcd

>复制相关的证书文件

```shell
mkdir -p /etc/etcd /var/lib/etcd
chmod 700 /var/lib/etcd
cd $HOME
cp etcd-ca.pem etcd-server-key.pem etcd-server.pem etcd-healthcheck-client.pem etcd-healthcheck-client-key.pem /etc/etcd/
```

>配置`etcd.service`

```shell
ETCD_NAME=$(hostname -s)
ETCD_IP=172.20.10.11
# etcd所有节点的ip地址
ETCD_NAMES=(node-1 node-2 node-3)
ETCD_IPS=(172.20.10.11 172.20.10.12 172.20.10.13)

cat <<EOF > /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/etcd-server.pem \\
  --key-file=/etc/etcd/etcd-server-key.pem \\
  --peer-cert-file=/etc/etcd/etcd-server.pem \\
  --peer-key-file=/etc/etcd/etcd-server-key.pem \\
  --trusted-ca-file=/etc/etcd/etcd-ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/etcd-ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${ETCD_IP}:2380 \\
  --listen-peer-urls https://${ETCD_IP}:2380 \\
  --listen-client-urls https://${ETCD_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${ETCD_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${ETCD_NAMES[0]}=https://${ETCD_IPS[0]}:2380,${ETCD_NAMES[1]}=https://${ETCD_IPS[1]}:2380,${ETCD_NAMES[2]}=https://${ETCD_IPS[2]}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
---
## 2. 启动etcd集群

```shell
systemctl daemon-reload && systemctl enable etcd && systemctl restart etcd
```

---

## 3. 验证

```shell
# 查看集群成员启动状态
ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/etcd-ca.pem \
  --cert=/etc/etcd/etcd-healthcheck-client.pem \
  --key=/etc/etcd/etcd-healthcheck-client-key.pem

# 查看集群成员健康状态
ETCDCTL_API=3 etcdctl endpoint health \
  --endpoints=https://172.20.10.11:2379,https://172.20.10.12:2379,https://172.20.10.13:2379 \
  --cacert=/etc/etcd/etcd-ca.pem \
  --cert=/etc/etcd/etcd-healthcheck-client.pem \
  --key=/etc/etcd/etcd-healthcheck-client-key.pem
```