## 1、安装软件包

```shell
ssh node1 "yum install ceph-radosgw -y"
```

## 2、部署

```shell
cd ${HOME}/ceph-cluster
ceph-deploy rgw create node1
ssh node1 ceph -s
```

## 3、访问

```shell
curl http://gateway-node:7480
```

## 4、修改默认访问端口

>修改部署文件

```shell
cd ${HOME}/ceph-cluster

cat >>ceph.conf << EOF
[client.rgw.node1]
rgw_frontends = "civetweb port=80"
EOF

# 推送新的部署文件到各个节点上
ceph-deploy --overwrite-conf config  push node1 node2 node3

# 重启node1服务
ssh node1 systemctl restart ceph-radosgw.target

# 验证
curl http://172.16.4.41
```

## 5、配置https

```shell
[client.rgw.node1]
rgw_frontends = civetweb port=443s ssl_certificate=/etc/ceph/private/keyandcert.pem
```

## 6、基于s3风格使用-API

>创建授权用户

```shell
radosgw-admin user create --uid="ceph-s3-user" --display-name="Ceph S3 User Demo"

# 关键信息
# "user": "ceph-s3-user"
# "access_key": "M4HWVOXCX4S6Z0WWLWHW"
# "secret_key": "4Gor6pYreDJVHKNMtCh11cHhDuLWMq1LBpeJKHXd"
radosgw-admin user info --uid ceph-s3-user
```

>安装软件包

```shell
sudo yum install python-boto
```

>编写调用脚本

```shell
ACCESS_KEY="M4HWVOXCX4S6Z0WWLWHW"
SECRET_KEY="4Gor6pYreDJVHKNMtCh11cHhDuLWMq1LBpeJKHXd"
RADOS_HOST="172.16.4.41"
RADOS_PORT=80
BUCKET_NAME="ceph-s3-bucket"

cat << EOF | sudo tee s3test.py
import boto.s3.connection

access_key = "${ACCESS_KEY}"
secret_key = "${SECRET_KEY}"
conn = boto.connect_s3(
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        host="${RADOS_HOST}", port=${RADOS_PORT},
        is_secure=False, calling_format=boto.s3.connection.OrdinaryCallingFormat(),
       )

bucket = conn.create_bucket("${BUCKET_NAME}")

for bucket in conn.get_all_buckets():
    print "{name} {created}".format(
        name=bucket.name,
        created=bucket.creation_date,
    )
EOF

python s3test.py
```

## 7、基于s3风格使用-CLI

>安装软件包

```shell
yum install s3cmd -y
```

>配置

```shell

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key: M4HWVOXCX4S6Z0WWLWHW
Secret Key: 4Gor6pYreDJVHKNMtCh11cHhDuLWMq1LBpeJKHXd
Default Region [US]:

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: 172.16.4.41:80

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: 172.16.4.41:80/%(bucket)s

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program [/usr/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: no

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't connect to S3 directly
HTTP Proxy server name:

New settings:
  Access Key: M4HWVOXCX4S6Z0WWLWHW
  Secret Key: 4Gor6pYreDJVHKNMtCh11cHhDuLWMq1LBpeJKHXd
  Default Region: US
  S3 Endpoint: 172.16.4.41:80
  DNS-style bucket+hostname:port template for accessing a bucket: 172.16.4.41:80/%(bucket)s
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] y
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Not configured. Never mind.

Save settings? [y/N] y
Configuration saved to '/root/.s3cfg'
```
修改配置`/root/.s3cfg`，启用v2版本签名

```shell
sed  -i "s/signature_v2.*/signature_v2 = True/" .s3cfg
```

>使用

```shell
# 查看bucket
s3cmd ls

# 创建新bucket
s3cmd mb s3://s3cmd-demo

# 上传文件
s3cmd put /etc/fstab s3://s3cmd-demo/fstab-demo

# 上传目录
s3cmd put --recursive /etc/ s3://s3cmd-demo/etc/

# 下载文件
s3cmd get s3://s3cmd-demo/etc/profile profile-download

# 删除
s3cmd rm --recursive s3://s3cmd-demo/etc/
```

## 8、基于swift风格使用-API

>创建swift用户

```shell
sudo radosgw-admin subuser create --uid=ceph-s3-user --subuser=ceph-s3-user:swift --access=full
```

>创建swift用户的secret

```shell
sudo radosgw-admin key create --subuser=ceph-s3-user:swift --key-type=swift --gen-secret
```

>获取swift用户的secret

```shell
"secret_key": "0fS0DnoRABVkdQbBkvk6tKd1te1aJBmvLLvBKExF"
```

>安装软件包

```shell
sudo yum install python-setuptools python-pip
sudo pip install --upgrade python-swiftclient
```

>测试

```shell
swift -V 1 -A http://172.16.4.41:80/auth -U ceph-s3-user:swift -K '0fS0DnoRABVkdQbBkvk6tKd1te1aJBmvLLvBKExF' list

# 使用环境变量的注入信息
export ST_AUTH="http://172.16.4.41:80/auth"
export ST_USER="ceph-s3-user:swift"
export ST_KEY="0fS0DnoRABVkdQbBkvk6tKd1te1aJBmvLLvBKExF"

swift list
```

>创建bucket

```shell
swift post swift-demo
```

>上传

```shell
swift upload swift-demo /etc/passwd
swift upload swift-demo /etc/
```

>下载

```shell
swift download swift-demo etc/passwd
```