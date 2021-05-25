## 1、创建mds服务

```shell
cd ${HOME}/ceph-cluster
ceph-deploy --overwrite-conf mds create node1

ssh node1 ceph -s

# 在添加其他mds节点
ceph-deploy --overwrite-conf mds create node2
ceph-deploy --overwrite-conf mds create node3

ssh node1 ceph -s
```

## 2、创建pool

```shell
ceph osd pool create cephfs_data 16
ceph osd pool create cephfs_metadata 16
```

## 3、创建fs

```shell
ceph fs new cephfs-demo cephfs_metadata cephfs_data
ceph fs ls
ceph mds stat
```

## 4、挂载文件系统

>基于内核

```shell
mkdir -p /mnt/cephfs
mount -t ceph 172.16.4.41:6789:/ /mnt/cephfs/ -o name=admin
df -h
ceph df
lsmod |grep ceph
```
>基于用户

```shell
# 安装客户端软件
sudo yum install ceph-fuse -y

# 创建挂载点
sudo mkdir -p /mnt/ceph-fuse/

# 挂载
sudo ceph-fuse -n client.admin -m 172.16.4.41:6789,172.16.4.42:6789,172.16.4.43:6789 /mnt/ceph-fuse/
df -h
```