
## Dashboard module
### 1、部署

>安装软件包

```shell
yum install ceph-mgr-dashboard -y
```
>启用dashbaord

```shell
ceph mgr module enable dashboard --force
```

### 2、配置

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
cephpassword
EOF
ceph dashboard ac-user-create cephadmin -i cephadmin administrator
```

### 3、访问

`https://172.16.4.41:8443`


## Alerts module
### 配置

>启用模块

```shell
ceph mgr module enable alerts
```
>SMTP

```shell
# 指定smtp服务
ceph config set mgr mgr/alerts/smtp_host 'smtp.163.com'
# 指定接收者
ceph config set mgr mgr/alerts/smtp_destination 'ceph_user@163.com'
# 指定发送者
ceph config set mgr mgr/alerts/smtp_sender 'ceph_admin@163.com'
```
>端口

```shell
# 是否启用SSL,默认启用SSL
ceph config set mgr mgr/alerts/smtp_ssl true
# 配置端口,默认端口465
ceph config set mgr mgr/alerts/smtp_port 465
```
>配置用户认证

```shell
# 邮件用户
ceph config set mgr mgr/alerts/smtp_user 'ceph_admin@163.com'
# 邮件密码
ceph config set mgr mgr/alerts/smtp_password 'XASIDKJKZIEHIZOZSU'
```

>配置名称

```shell
# 配置邮件名称
ceph config set mgr mgr/alerts/smtp_from_name 'Ceph Cluster'
```

>配置告警频率

```shell
ceph config set mgr mgr/alerts/interval "5m"
```

>手动触发

```shell
ceph alerts send
```

## Prometheus module

### 配置

>启用

```shell
ceph mgr module enable prometheus
```

>配置服务

```shell
ceph config set mgr mgr/prometheus/server_addr 0.0.0.0
ceph config set mgr mgr/prometheus/server_port 9283
```

>设置频率

```shell
ceph config set mgr mgr/prometheus/scrape_interval 20
```