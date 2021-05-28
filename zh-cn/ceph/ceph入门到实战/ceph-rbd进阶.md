## 1、回收站

```shell
# 创建块设备镜像
rbd create rbd/ceph-trash.img --image-feature layering --size=10G
rbd info rbd/ceph-trash.img

# 删除到回收站
rbd trash move rbd/ceph-trash.img --expires-at 20210528
rbd trash ls

# 从回收站还原
rbd trash restore -p rbd 19ad399190ed7
```

## 2、快照

>创建快照

```shell
rbd create rbd/rbd-test.img --image-feature layering --size=10G
rbd info rbd/rbd-test.img
rbd device map rbd/rbd-test.img
mkfs.ext4 /dev/rbd0
mount /dev/rbd0 /media/

rbd snap create rbd/rbd-test.img@snap_$(date +%Y%m%d)
rbd snap ls rbd/rbd-test.img
```

>恢复快照

```shell
umount /media/
rbd snap rollback rbd/rbd-test.img@snap_20210527 
mount /dev/rbd0 /media/
```

>删除快照

```shell
rbd snap rm rbd/rbd-test.img@snap_20210527
```

>删除所有未保护的镜像快照

```shell
rbd snap purge rbd/rbd-test.img
```

>快照克隆

```shell
rbd snap create rbd/rbd-test.img@snap_$(date +%Y%m%d)
rbd snap ls rbd/rbd-test.img
# 将快照保护起来
rbd snap protect rbd/rbd-test.img@snap_$(date +%Y%m%d)
# 克隆新的镜像
rbd clone rbd/rbd-test.img@snap_$(date +%Y%m%d) rbd/rbd-test2.img
rbd clone rbd/rbd-test.img@snap_$(date +%Y%m%d) rbd/rbd-test3.img
rbd ls
rbd info rbd/rbd-test2.img
# 解除保护
# rbd snap unprotect rbd/rbd-test.img@snap_$(date +%Y%m%d)
```

>解除依赖关系

```shell
# 查看当前依赖
rbd children rbd/rbd-test.img@snap_$(date +%Y%m%d)
# 解除依赖
rbd flatten rbd/rbd-test2.img
rbd flatten rbd/rbd-test3.img
rbd children rbd/rbd-test.img@snap_$(date +%Y%m%d)
```

## 3、备份与恢复

```shell
# 导出
rbd export rbd/rbd-test.img@snap_$(date +%Y%m%d) /data/rbd-test.img
# 导入
rbd import /data/rbd-test.img rbd/rbd-test-new.img --image-feature layering
```
>增量导出

```shell
rbd snap create rbd/rbd-test.img@snap_v1_$(date +%Y%m%d)
rbd export-diff rbd/rbd-test.img@snap_v1_$(date +%Y%m%d) /data/rbd-test.img@v1
```
>增量导入

```shell
rbd import-diff /data/rbd-test.img@v1 rbd/rbd-test.img
```