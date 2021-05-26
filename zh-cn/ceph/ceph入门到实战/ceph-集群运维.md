## 1、管理systemd

```shell
sudo systemctl start ceph.target       # start all daemons
sudo systemctl status ceph-osd@12      # check status of osd.12

# 批量控制
sudo systemctl status ceph\*.service ceph\*.target

# 某类服务所有子服务
sudo systemctl start ceph-osd.target
sudo systemctl start ceph-mon.target
sudo systemctl start ceph-mds.target

# 具体的服务
sudo systemctl stop ceph-osd@1
sudo systemctl stop ceph-mon@ceph-server
sudo systemctl stop ceph-mds@ceph-server
```

## 2、日志

>日志存放目录：/var/log/ceph

## 3、集群的监控

>交互式

```shell
 ceph
ceph> health
HEALTH_OK

ceph> status
  cluster:
    id:     6e6d71a9-d2b7-4229-9faa-d1f7541249a7
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node1,node2,node3 (age 7h)
    mgr: node1(active, since 7h), standbys: node2, node3
    mds: cephfs-demo:1 {0=node1=up:active} 2 up:standby
    osd: 6 osds: 6 up (since 35m), 6 in (since 35m)
    rgw: 1 daemon active (node1)

  task status:
    scrub status:
        mds.node1: idle

  data:
    pools:   9 pools, 384 pgs
    objects: 2.70k objects, 1.9 GiB
    usage:   12 GiB used, 587 GiB / 600 GiB avail
    pgs:     384 active+clean


ceph>
```

>命令式

```shell
ceph status/-s
ceph health
```

>集群利用率

```shell
ceph df
```

>osd监控

```shell
ceph osd stat
ceph osd dump
ceph osd tree
ceph osd df
```

>mon监控

```shell
ceph mon stat
ceph mon dump
ceph quorum_status
```

>mds监控

```shell
ceph mds stat
ceph fs dump 
```

>查询admin socket信息

```shell
ceph daemon osd.0 foo
ceph daemon /var/run/ceph/ceph-osd.0.asok foo
ceph daemon /var/run/ceph/ceph-mon.node1.asok help
ceph --admin-daemon /var/run/ceph/ceph-mon.node1.asok config show
```

## 4、资源池管理

```shell
ceph osd lspools

osd pool default pg num = 100
osd pool default pgp num = 100
```

>创建资源池

```shell
ceph osd pool create {pool-name} {pg-num} [{pgp-num}] [replicated] \
     [crush-rule-name] [expected-num-objects]
ceph osd pool create {pool-name} {pg-num}  {pgp-num}   erasure \
     [erasure-code-profile] [crush-rule-name] [expected_num_objects]
```

>查看/设置参数

```shell
ceph osd pool get pool-demo 
ceph osd pool set pool-demo
```
>应用初始化

```shell
# application-name：rbd,cephfs,rgw
ceph osd pool application enable {pool-name} {application-name}
```

>资源配额

```shell
# ceph osd pool set-quota {pool-name} [max_objects {obj-count}] [max_bytes {bytes}]

ceph osd pool set-quota data max_objects 10000
ceph osd pool get-quota data
```

## 5、集群删除

```shell
# 删除pool，需要确认
ceph osd pool rm ceph-pool-demo ceph-pool-demo
Error EPERM: WARNING: this will *PERMANENTLY DESTROY* all data stored in pool ceph-pool-demo.  If you are *ABSOLUTELY CERTAIN* that is what you want, pass the pool name *twice*, followed by --yes-i-really-really-mean-it.

# 删除pool，需要开启允许删除参数
ceph osd pool rm ceph-pool-demo ceph-pool-demo --yes-i-really-really-mean-it
Error EPERM: pool deletion is disabled; you must first set the mon_allow_pool_delete config option to true before you can destroy a pool

ceph daemon /var/run/ceph/ceph-mon.node1.asok config show|grep mon_allow_pool_delete
    "mon_allow_pool_delete": "false",

# 临时设置
HOSTS=(node1 node2 node3)
for instance in ${HOSTS[@]};
do
  ssh $instance ceph daemon /var/run/ceph/ceph-mon.${instance}.asok config set mon_allow_pool_delete true
done

# 永久设置
sed  -i '/\[global\]/a\mon_allow_pool_delete = true' ceph.conf
ceph-deploy --overwrite-conf config push node1 node2 node3

HOSTS=(node1 node2 node3)
for instance in ${HOSTS[@]};
do
  ssh $instance systemctl restart ceph-mon.target
  ssh $instanc ceph daemon /var/run/ceph/ceph-mon.${instance}.asok config show|grep mon_allow_pool_delete
done


ceph osd pool rm ceph-pool-demo ceph-pool-demo --yes-i-really-really-mean-it
```