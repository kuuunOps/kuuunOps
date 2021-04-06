# Keepalivad

## Keepalived工作原理

Keepalived是以VRRP（虚拟路由冗余协议）协议为实现基础，实现路由的高可用。即在N台具有相同功能的路由服务器组成路由服务器组，且组中包含一个maser节点和N-1个backup节点，在master节点上有一个对外提供服务的VIP，maser节点持续向backup节点发送心跳信息，通知backup节点，当前maser节点还处于存活状态，当backup节点无法接收到maser节点的心跳信息，则判定maser节点以及宕机，这时就需要根据VRRP的优先级来选择一个backup节点提升为新的maser节点。

## Keepalived的主要模块

- core：keepalived核心，负责主进程的启动，维护以及全局配置文件的加载和解析
- check：负责健康检查，包括厂家的各种检查方式。
- vrrp：负责实现vrrp协议。

## Keepalived配置文件

- `global_defs`
- `static_ipaddress`
- `vrrp_script`
- `vrrp_instanc`
- `virtual_server`

### global_defs

```shell
global_defs {
# 邮件告警相关配置
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30

# 路由唯一标识，一般配置为主机IP   
   router_id LVS_DEVEL

   vrrp_skip_check_adv_addr
   vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}
```

### vrrp_script

```shell
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -20
  fall 10
  rise 2
}
```

### vrrp_instance

```shell
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        172.16.4.60/24
    }
    track_script {
        check_apiserver
    }
}
```