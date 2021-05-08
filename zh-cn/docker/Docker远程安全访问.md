## Docker远程安全访问

>Docker可以通过`REST API`进行远程访问和操纵。

### 1. Docker开启远程API

>方法一：配置`/etc/docker/daemon.json`

```shell
# 首先修改/usr/lib/systemd/system/docker.service，移除选项`-H fd://`
# 修改为如下样式
[Service]
Type=notify
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock

# 配置/etc/docker/daemon.json，添加如下样式
{
  "hosts": ["fd://","tcp://0.0.0.0:2376"]
}

# 重启服务
systemctl daemon-reload
systemctl restart docker
```

>方法二：配置`/usr/lib/systemd/system/docker.service`

```shell
# 添加选项参数`-H tcp://0.0.0.0:2376`
[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376 --containerd=/run/containerd/containerd.sock

# 重启服务
systemctl daemon-reload
systemctl restart docker
```
两种方法二选一，因为两种配置是相互冲突的。

>验证

```shell
# 如果成功会同时返回当前Client端信息，和远程Server端信息
docker -H=172.16.4.72:2376 version
```

### 2. 基于SSH安全访问API

>配置SSH免密登录

```shell
# 查看秘钥。如果没有，需要生成新的秘钥
if [ -f "$HOME/.ssh/id_rsa.pub" ] ; then
echo "The secret key already exists"
cat $HOME/.ssh/id_rsa.pub
else
echo "A new key is generated when the key does not exist"
ssh-keygen -t rsa -N '' -q -f $HOME/.ssh/id_rsa
cat $HOME/.ssh/id_rsa.pub
fi
# 复制秘钥
ssh-copy-id -i ${HOME}/.ssh/id_rsa.pub root@172.16.4.72
```

>创建上下文配置

```shell
# 查看当前上下文配置
docker context ls

# 创建新的上下文配置
docker context create --docker host=ssh://root@172.16.4.72 --description="Remote engine" 72-docker

# 切换上下文配置
docker context use 72-docker

# 验证
docker info

# 删除上下文配置
docker context rm 72-docker
```

---
### 3. 基于TLS安全访问API

>创建CA根证书

```shell
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -subj "/CN=172.16.4.72" -days 36500 -out ca.crt
```

>创建Server端证书

```shell
openssl genrsa -out server.key 4096
cat > server-csr.conf << EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = centos-vm-4-72

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 172.16.4.72
IP.2 = 127.0.0.1
DNS.1 = centos-vm-4-72

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment,digitalSignature
extendedKeyUsage=serverAuth
subjectAltName=@alt_names
EOF

openssl req -new -key server.key  -config server-csr.conf -out server.csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 36500 -extensions v3_ext -extfile server-csr.conf
```

>创建Client端证书

```shell
openssl genrsa -out client.key 4096
cat > client-csr.conf << EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = client


[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment,digitalSignature
extendedKeyUsage=clientAuth
EOF

openssl req -new -key client.key  -config client-csr.conf -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 36500 -extensions v3_ext -extfile client-csr.conf
```

>配置`/etc/docker/daemon.json`，开启远程API

```json
{
  "hosts": ["fd://","tcp://0.0.0.0:2376"]
}
```

>验证是否可以远程访问

```shell
docker -H=172.16.4.72:2376 version
```

>配置Server证书

```shell
mkdir /etc/docker/pki
cp ca.crt server.crt server.key /etc/docker/pki

```

>配置Client端

```shell
mkdir -p /etc/docker/pki
cp ca.crt client.crt client.key /etc/docker/pki
```

>验证

```shell
# docker CLI测试
docker --tlsverify --tlscacert=/etc/docker/pki/ca.crt \
--tlscert=/etc/docker/pki/client.crt \
--tlskey=/etc/docker/pki/client.key \
-H=172.16.4.72:2376 version

# https测试
curl https://172.16.4.72:2376/version \
  --cert /etc/docker/pki/client.crt \
  --key /etc/docker/pki/client.key \
  --cacert /etc/docker/pki/ca.crt
```
