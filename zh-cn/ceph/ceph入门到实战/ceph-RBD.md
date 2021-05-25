## 1、pool

>ceph osd pool create {pool-name} {pg-num} [{pgp-num}] [replicated] [crush-rule-name] [expected-num-objects]
>
>ceph osd pool create {pool-name} {pg-num}  {pgp-num}   erasure [erasure-code-profile] [crush-rule-name] [expected_num_objects]

```shell
# 查询当前拥有的pool
ceph osd lspools

# 创建一个新的pool
ceph osd pool create ceph-demo 64 64

# 重名名为rbd的pool
ceph osd pool rename ceph-demo rbd
```

## 2、获取pool的参数值

>ceph osd pool get {pool-name} {key}

```shell
# 副本数
ceph osd pool get ceph-demo size

# pg
ceph osd pool get ceph-demo pg_num

# pgp
ceph osd pool get ceph-demo pgp_num

# crush_rule
ceph osd pool get ceph-demo crush_rule
```

## 3、设置pool的参数值

```shell
ceph osd pool set ceph-demo size 2
```

## 4、初始化RBD类型的pool

```shell
rbd pool init rbd
```

## 5、创建rbd块设备文件

```shell
# 查看对应pool存在的块设备文件
rbd -p rbd ls

# 创建块设备文件
rbd create -p rbd --image rbd-demo.img  --image-feature layering --size 10G

# 或者
# rbd create rbd/rbd-demo-1.img  --image-feature layering --size 10G

# 查看块设备信息
rbd -p rbd info rbd-demo.img

# 删除块设备文件
rbd rm -p rbd rbd-demo-1.img
```

## 5、关闭不支持的特性

```shell
rbd feature disable rbd/rbd-demo.img deep-flatten
rbd feature disable rbd/rbd-demo.img fast-diff
rbd feature disable rbd/rbd-demo.img object-map
rbd feature disable rbd/rbd-demo.img exclusive-lock

# 验证
rbd -p rbd info rbd-demo.img
```

## 6、使用内核的方式挂载块设备

```shell
rbd map rbd/rbd-demo.img
```

## 7、块设备使用

```shell
# 格式化块设备
mkfs.ext4 /dev/rbd0
lsblk
mkdir -p /mnt/rbd-demo
# 挂载
mount /dev/rbd0 /mnt/rbd-demo
df -h
```

## 8、扩容

```shell
# 块设备扩容
rbd resize rbd/rbd-demo.img --size 20G
rbd -p rbd info rbd-demo.img

# 分区扩容
resize2fs /dev/rbd0
df -h
```

## 9、查看创建的object

```shell
# 查看块设备object列表
rados -p rbd ls|grep `rbd -p rbd info rbd-demo.img|grep block_name_prefix|awk '{print $2}'`

# 查看其中一个object的信息
rados -p rbd stat rbd_data.11f7d039ced8.0000000000000a26
```

## 10、查看object分布情况

```shell
ceph osd map rbd rbd_data.11f7d039ced8.0000000000000a26
```