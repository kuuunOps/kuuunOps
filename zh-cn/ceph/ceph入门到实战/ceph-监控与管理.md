## 1、部署

>安装软件包

```shell
yum install ceph-mgr-dashboard -y
```
>启用dashbaord

```shell
ceph mgr module enable dashboard --force
```
>配置TLS

```shell
ceph dashboard create-self-signed-cert
```
>端口配置

```shell
ceph config set mgr mgr/dashboard/server_addr 172.16.4.41
ceph config set mgr mgr/dashboard/server_port 8080
ceph config set mgr mgr/dashboard/ssl_server_port 8443
ceph mgr services
```
>创建用户

```shell
cat << EOF |sudo tee cephadmin
cephadmin/cephpassword
EOF
ceph dashboard ac-user-create cephadmin -i cephadmin administrator
```