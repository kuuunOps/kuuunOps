## 1、crush查询

```shell
ceph osd crush tree
ceph osd crush dump
ceph osd crush rule ls
```

## 2、手动定义crush

```shell
# 导出规则
ceph osd getcrushmap -o crushmap.bin
cp crushmap.bin crushmap.bin.bak
# 解码成文本格式
crushtool -d crushmap.bin -o crushmap.conf

# 编译成二进制文件
crushtool -c crushmap.conf -o crushmap.bin
# 应用规则
ceph osd setcrushmap -i crushmap.bin

# 使用新的规则
ceph osd pool set ceph-demo crush_rule demo_rule
```

## 3、命令行模式

```shell
# 创建root
ceph osd crush add-bucket ssd root

# 创建host
ceph osd crush add-bucket node-1-ssd host
ceph osd crush add-bucket node-2-ssd host
ceph osd crush add-bucket node-3-ssd host
ceph osd crush move node-1-ssd root=ssd
ceph osd crush move node-2-ssd root=ssd
ceph osd crush move node-3-ssd root=ssd

# 迁移osd
ceph osd crush move osd.3 host=node-1-ssd root=ssd
ceph osd crush move osd.4 host=node-2-ssd root=ssd
ceph osd crush move osd.5 host=node-3-ssd root=ssd

# 调整设备
ceph osd crush rm-device-class osd.3
ceph osd crush rm-device-class osd.4
ceph osd crush rm-device-class osd.5
ceph osd crush set-device-class ssd osd.3
ceph osd crush set-device-class ssd osd.4
ceph osd crush set-device-class ssd osd.5

# 创建rule
ceph osd crush rule create-replicated ssd-demo ssd host ssd
```
