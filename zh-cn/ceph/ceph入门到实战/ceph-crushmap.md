## 1、crush查询

```shell
ceph osd crush tree
ceph osd crush dump
ceph osd crush rule ls
```

## 2、定义crush-编辑配置文件

```shell
# 导出规则
ceph osd getcrushmap -o crushmap.bin
cp crushmap.bin crushmap.bin.bak
# 解码成文本格式
crushtool -d crushmap.bin -o crushmap.conf

# 手动编辑配置文件

# 编译成二进制文件
crushtool -c crushmap.conf -o crushmap.bin
# 应用规则
ceph osd setcrushmap -i crushmap.bin

# 使用新的规则
ceph osd pool set ceph-demo crush_rule demo_rule
```

## 3、定义crush-命令行模式

```shell
# 创建root
# ceph osd crush add-bucket <name> <type> {<args> [<args>...]}
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
# ceph osd crush rule create-replicated <name> <root> <type> {<class>}
ceph osd crush rule create-replicated ssd-demo ssd host ssd


# 备份
ceph osd getcrushmap -o crushmap.bin
```
>关闭crushmap自动管理，防止重启自动失效

```shell
cat >> ceph.conf << EOF
[osd]
osd crush update on start = false
EOF
ceph-deploy --overwrite-conf config push node1 node2 node3

HOSTS=(node1 node2 node3)
for instance in ${HOSTS[@]};
do
  ssh $instance systemctl restart ceph-osd.target
done
```

## 4、注意事项

- 1. 所有操作之前都要做备份
- 2. 架构要提前做好规划
- 3. 关闭crushmap自动管理