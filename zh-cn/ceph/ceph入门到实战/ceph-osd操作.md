## 1、横向扩容

>横向扩容就是增加节点

## 2、纵向扩容

>纵向扩容指的就是再现有的节点增加磁盘

```shell
# 查看节点node1的磁盘状况
ceph-deploy disk list node1

# 删除磁盘分区
ceph-deploy disk zap node1 /dev/sdc

# 添加磁盘
ceph-deploy osd create node1 --data /dev/sdc

# 查看node1节点osd划分
ceph-deploy osd list node1
```

## 3、Rebalancing

>当新增OSD，会触发Rebalancing，将现有的PG数据进行重新计算和分配

```shell
# osd节点同步线程数
ceph --admin-daemon /var/run/ceph/ceph-mon.node1.asok config show |grep "osd_max_backfills"

# osd节点同步数据的网络使用cluster_network，生产环境要进行网络分离
```

>暂停rebalancing

```shell
ceph osd set norebalance
ceph osd set nobackfill
```

>恢复rebalancing

```shell
ceph osd unset norebalance
ceph osd unset nobackfill
```

## 4、删除OSD

```shell
# 查询OSD延迟状态
ceph osd perf

# 移除集群，等待数据重新分配
ceph osd tree
ceph osd out 3
ceph -w

# 停止osd服务
systemctl stop ceph-osd@3

# 清除osd
ceph osd purge 3 --yes-i-really-mean-it
```
>Luminous以前的版本，需要手动清除

```shell
# 1. 清除crush map
ceph osd crush remove
# 2. 删除认证信息
ceph auth del osd.3
# 3. 删除物理节点
ceph osd rm 3
```

## 5、重新添加被移除disk

```shell
lsblk
dmsetup ls
dmsetup remove ceph--b7055888--aabd--4148--a95b--04733f30e9c1-osd--block--6503606e--afaf--46f0--882b--2d199009155d
lsblk
```

