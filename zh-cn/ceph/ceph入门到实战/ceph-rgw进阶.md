## 1、rgw高可用

>新增rgw

```shell
ceph-deploy rgw  create node2
# 修改监听端口
cat >> ceph.conf << EOF
[client.rgw.node2]
rgw_frontends = "civetweb port=80"
EOF
# 分发配置文件
ceph-deploy --overwrite-conf config push node1 node2 node3
# 重启服务
ssh node2 systemctl restart ceph-radosgw.target
curl node2
```

## 2、负载均衡器

>安装软件包

```shell
yum install keepalived haproxy -y
```

>配置keepalived

```shell
# 其中一台角色设置为MASTER，其他设置为BACKUP 
STATE=MASTER
# 监听的网卡接口
INTERFACE=eth0
# 集群ID
ROUTER_ID=51
# 集群优先级，MASTER设置为101,BACKUP设置为100
PRIORITY=101
# 配置认证信息
AUTH_PASS=111222
# 设置VIP的地址
RGW_VIP=172.16.4.45/24
# 设置VIP的端口
RGW_DEST_PORT=80

mkdir -p /etc/keepalived/

# 配置keepalived
cat << EOF | sudo tee /etc/keepalived/keepalived.conf 
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface ${INTERFACE}
    virtual_router_id ${ROUTER_ID}
    priority ${PRIORITY}
    authentication {
        auth_type PASS
        auth_pass ${AUTH_PASS}
    }
    virtual_ipaddress {
        ${RGW_VIP} device ${INTERFACE}
    }
    track_script {
        check_apiserver
    }
}
EOF

# 配置检测脚本
cat >/etc/keepalived/check_apiserver.sh<<EOF
#!/bin/sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure http://localhost:${RGW_DEST_PORT}/ -o /dev/null || errorExit "Error GET http://localhost:${RGW_DEST_PORT}/"
if ip addr | grep -q "${RGW_VIP}"; then
    curl --silent --max-time 2 --insecure http://${RGW_VIP}:${RGW_DEST_PORT}/ -o /dev/null || errorExit "Error GET http://${RGW_VIP}:${RGW_DEST_PORT}/"
fi
EOF
```

>配置haproxy

```shell
# 设置VIP的端口
RGW_DEST_PORT=80
# 设置源站的端口
RGW_SRC_PORT=7480
# 设置主机ID
HOST1_ID=rgw1
HOST2_ID=rgw2
# 设置主机IP
HOST1_ADDRESS=172.16.4.41
HOST2_ADDRESS=172.16.4.42

mkdir -p /etc/haproxy/
# 配置haproxy
cat << EOF| sudo tee /etc/haproxy/haproxy.cfg
# /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 1
    timeout http-request    10s
    timeout queue           20s
    timeout connect         5s
    timeout client          20s
    timeout server          20s
    timeout http-keep-alive 10s
    timeout check           10s

#---------------------------------------------------------------------
# apiserver frontend which proxys to the masters
#---------------------------------------------------------------------
frontend http_web
    bind *:${RGW_DEST_PORT}
    mode http
    default_backend rgw

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend rgw
    mode http
    balance     roundrobin
        server ${HOST1_ID} ${HOST1_ADDRESS}:${RGW_SRC_PORT} check
        server ${HOST2_ID} ${HOST2_ADDRESS}:${RGW_SRC_PORT} check
EOF
```
>启动服务

```shell
sudo systemctl enable haproxy --now
sudo systemctl enable keepalived --now
```
>测试

```shell
curl 172.16.4.45
```

>客户端s3cmd测试

```shell
s3cmd ls
s3cmd mb s3://test
```