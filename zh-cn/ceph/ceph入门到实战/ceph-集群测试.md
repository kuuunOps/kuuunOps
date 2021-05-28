## 1、mon测试

>保持mon集群数为3个以上

## 2、mds测试

>保持mds集群数为1个以上，高可用为2个以上

## 3、rgw测试

>保持rgw集群书为1个以上，高可用为2个以上

## 4、osd测试

>减少故障的出现，出现的太多会造成读写变慢

## 5、IO测试

>安装软件包

```shell
yum install fio -y
```

>测试

```shell
# 4K随机写
fio -filename=/mnt/rbd-test/fio.img -direct=1 -iodepth 32 -thread -rw=randwrite -ioengine=libaio -bs=4K -size=200m -numjobs=8 -runtime=60 -group_reporting -name=mytest
# 4K随机读
fio -filename=/mnt/rbd-test/fio.img -direct=1 -iodepth 32 -thread -rw=randread -ioengine=libaio -bs=4K -size=200m -numjobs=8 -runtime=60 -group_reporting -name=mytest
# 4K随机读写
fio -filename=/mnt/rbd-test/fio.img -direct=1 -iodepth 32 -thread -rw=randrw -rwmixread=70 -ioengine=libaio -bs=4K -size=200m -numjobs=8 -runtime=60 -group_reporting -name=mytest
# 1M顺序写
fio -filename=/mnt/rbd-test/fio.img -direct=1 -iodepth 32 -thread -rw=write -ioengine=libaio -bs=1M -size=200m -numjobs=8 -runtime=60 -group_reporting -name=mytest
```

>bench简单测试

```shell
rbd bench rbd/rbd-test.img --io-size 4K --io-threads 32 --io-total 1G --io-pattern rand --io-type write
rbd bench rbd/rbd-test.img --io-size 4K --io-threads 32 --io-total 1G --io-pattern rand --io-type read
rbd bench rbd/rbd-test.img --io-size 4K --io-threads 32 --io-total 1G --io-pattern rand --rw-mix-read 70 --io-type readwrite
rbd bench rbd/rbd-test.img --io-size 1M --io-threads 32 --io-total 1G --io-pattern seq --io-type write
```