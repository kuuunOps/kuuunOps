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

```shell
rbd create rbd/rbd-test.img --image-feature layering --size=10G
rbd info rbd/rbd-test.img
rbd device map rbd/rbd-test.img
mkfs.ext4 /dev/rbd0
mount /dev/rbd0 /media/

# 创建快照
rbd snap create rbd/rbd-test.img@snap_$(date +%Y%m%d)
rbd snap ls rbd/rbd-test.img

# 恢复快照
umount /media/
rbd snap rollback rbd/rbd-test.img@snap_20210527
mount /dev/rbd0 /media/

# 删除快照
rbd snap rm rbd/rbd-test.img@snap_20210527
```