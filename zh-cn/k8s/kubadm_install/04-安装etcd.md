## 1、下载etcd

```shell
wget https://github.com/etcd-io/etcd/releases/download/v3.4.10/etcd-v3.4.10-linux-amd64.tar.gz
tar xf etcd-v3.4.10-linux-amd64.tar.gz
cd etcd-v3.4.10-linux-amd64
# 分发二进制文件
HOSTS=(centos-vm-4-241 centos-vm-4-242 centos-vm-4-243)
for instance in ${HOSTS[@]}; 
do
 scp etcd* root@${instance}:/usr/local/bin/
 ssh root@${instance} "chmod +x /usr/local/bin/etcd*"
done
```

## 2、配置etcd

```shell
ETCD_NAME=$(hostname -s)
ETCD_IP=172.16.4.241
# etcd所有节点的ip地址
ETCD_NAMES=(centos-vm-4-241  centos-vm-4-242  centos-vm-4-243)
ETCD_IPS=(172.16.4.241 172.16.4.242 172.16.4.243)

cat <<EOF > /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/pki/server.crt \\
  --key-file=/etc/etcd/pki/server.key \\
  --peer-cert-file=/etc/etcd/pki/peer.crt\\
  --peer-key-file=/etc/etcd/pki/peer.key \\
  --trusted-ca-file=/etc/etcd/pki/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/pki/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${ETCD_IP}:2380 \\
  --listen-peer-urls https://${ETCD_IP}:2380 \\
  --listen-client-urls https://${ETCD_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${ETCD_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${ETCD_NAMES[0]}=https://${ETCD_IPS[0]}:2380,${ETCD_NAMES[1]}=https://${ETCD_IPS[1]}:2380,${ETCD_NAMES[2]}=https://${ETCD_IPS[2]}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd \\
  --logger=zap
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

## 3、启动服务

```shell
systemctl enable etcd --now
systemctl status etcd
```

## 4、验证

```shell
# 查看集群成员启动状态
ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/pki/ca.crt \
  --cert=/etc/etcd/pki/healthcheck-client.crt \
  --key=/etc/etcd/pki/healthcheck-client.key -w table

# 查看集群成员健康状态
ETCDCTL_API=3 etcdctl endpoint health \
  --endpoints=https://172.16.4.241:2379,https://172.16.4.242:2379,https://172.16.4.243:2379 \
  --cacert=/etc/etcd/pki/ca.crt \
  --cert=/etc/etcd/pki/healthcheck-client.crt \
  --key=/etc/etcd/pki/healthcheck-client.key -w table
```