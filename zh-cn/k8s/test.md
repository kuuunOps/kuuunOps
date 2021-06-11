- 1. 签发根证书

```shell
# 生成CA私钥
openssl genrsa -out ca.key 2048
# 生成CA配置
cat > ca-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = ops-ca

[ v3_ext ]
basicConstraints=CA:TRUE
EOF
# 生成证书请求文件
openssl req -new -key ca.key  -config ca-csr.conf -out ca.csr
# 签发CA证书
openssl req -x509 -key ca.key -in ca.csr -config ca-csr.conf -extensions v3_ext  -days 40000  -out ca.crt
# 查看CA证书
openssl x509 -in ca.crt -noout -text
```

- 2. 签发etcd根证书

```shell
# 生成etcd服务CA私钥
openssl genrsa -out etcd-ca.key 2048
# etcd的CA配置
cat > etcd-ca-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = etcd-ca

[ v3_ext ]
basicConstraints=CA:TRUE
EOF

# 生成证书请求文件
openssl req -new -key etcd-ca.key  -config etcd-ca-csr.conf -out etcd-ca.csr
# 签发CA证书
openssl x509 -req -in etcd-ca.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out etcd-ca.crt -days 18250 -extensions v3_ext -extfile etcd-ca-csr.conf
# 查看CA证书
openssl x509 -in etcd-ca.crt -noout -text
```


- 3. 签发k8s根证书

```shell
# 生成k8s服务CA私钥
openssl genrsa -out kubernetes-ca.key 2048
# k8s的CA配置
cat > kubernetes-ca-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = kubernetes-ca

[ v3_ext ]
basicConstraints=CA:TRUE
EOF

# 生成证书请求文件
openssl req -new -key kubernetes-ca.key  -config kubernetes-ca-csr.conf -out kubernetes-ca.csr
# 签发CA证书
openssl x509 -req -in kubernetes-ca.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kubernetes-ca.crt -days 18250 -extensions v3_ext -extfile kubernetes-ca-csr.conf
# 查看CA证书
openssl x509 -in kubernetes-ca.crt -noout -text
```

---

1. etcd证书

- etcd-server证书

```shell
# 生成etcd服务端key
openssl genrsa -out etcd-server.key 2048
# etcd服务server配置，用于server和集群认证，也可以每个server生成一套
cat > etcd-server-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = kube-etcd

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 172.16.4.241
IP.2 = 172.16.4.242
IP.3 = 172.16.4.243
IP.4 = 127.0.0.1

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

# 生成etcd服务server签发请求
openssl req -new -key etcd-server.key  -config etcd-server-csr.conf -out etcd-server.csr
# 签发etcd服务server证书
openssl x509 -req -in etcd-server.csr -CA etcd-ca.crt -CAkey etcd-ca.key -CAcreateserial -out etcd-server.crt -days 18250 -extensions v3_ext -extfile etcd-server-csr.conf
# 查看证书
openssl x509 -in etcd-server.crt -noout -text
```

- etcd客户端证书

```shell
# 生成etcd客户端key
openssl genrsa -out etcd-client.key 2048
# etcd服务client配置
cat > etcd-client-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = kube-etcd
O = system:masters

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=clientAuth
EOF

# 生成etcd服务client签发请求
openssl req -new -key etcd-client.key  -config etcd-client-csr.conf -out etcd-client.csr
# 签发etcd服务client证书
openssl x509 -req -in etcd-client.csr -CA etcd-ca.crt -CAkey etcd-ca.key -CAcreateserial -out etcd-client.crt -days 18250 -extensions v3_ext -extfile etcd-client-csr.conf
# 查看证书
openssl x509 -in etcd-client.crt -noout -text
```

2. k8s证书

- apiserver

```shell
openssl genrsa -out apiserver.key 2048
cat > apiserver-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = kube-apiserver

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 172.16.4.240
IP.3 = 172.16.4.241
IP.4 = 172.16.4.242
IP.5 = 172.16.4.243



[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

openssl req -new -key apiserver.key  -config apiserver-csr.conf -out apiserver.csr
openssl x509 -req -in apiserver.csr -CA kubernetes-ca.crt -CAkey kubernetes-ca.key -CAcreateserial -out apiserver.crt -days 18250 -extensions v3_ext -extfile apiserver-csr.conf
# 查看证书
openssl x509 -in apiserver.crt -noout -text
```

- kube-scheduler

```shell
openssl genrsa -out scheduler.key 2048

cat > scheduler-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = system:kube-scheduler
O = system:masters
OU = System

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl req -new -key scheduler.key  -config scheduler-csr.conf -out scheduler.csr
openssl x509 -req -in scheduler.csr -CA kubernetes-ca.crt -CAkey kubernetes-ca.key -CAcreateserial -out scheduler.crt -days 18250 -extensions v3_ext -extfile scheduler-csr.conf
# 查看证书
openssl x509 -in scheduler.crt -noout -text
```

- kube-controller-manager

```shell
openssl genrsa -out controller-manager.key 2048

cat > controller-manager-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = system:kube-controller-manager
O = system:masters
OU = System

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl req -new -key controller-manager.key  -config controller-manager-csr.conf -out controller-manager.csr
openssl x509 -req -in controller-manager.csr -CA kubernetes-ca.crt -CAkey kubernetes-ca.key -CAcreateserial -out controller-manager.crt -days 36500 -extensions v3_ext -extfile controller-manager-csr.conf
# 查看证书
openssl x509 -in controller-manager.crt -noout -text
```