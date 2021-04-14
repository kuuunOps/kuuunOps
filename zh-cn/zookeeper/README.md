# Zookeeper

## 数据一致性的保证

- 全局可线性化（`Linearizable`）写入：先到达`Leader`的写请求会被先处理，`Leader`决定写请求的执行顺序。
- 客户端`FIFO`顺序：来自给定客户端的请求按照发送顺序执行。

## 重要配置项

- `clientPort`：zookeeper对客户端提供服务的端口。
- `dataDir`：用来保存快照文件的目录。如果没有设置`dataLogDir`，事务日志文件也会保存到这个目录。
- `dataLogDir`：用来保存事务日志文件的目录。因为`zookeeper`在提交一个事务之前，需要保证事务日志记录的落盘，所以需要为`dataLogDir`分配一个独占的存储设备。


## 节点硬件要求

>给zookeeper分配独占的服务器，要给zookeeper的事务日志分配独立的存储设备。

- 内存：`zookeeper`需要在内存中保存`data tree`。对于一般的zookeeper应用场景，8G的内存足够了。
- CPU：`zookeeper`对CPU的消耗不高。只要保证`zookeeper`能够有一个独占的CPU核即可。所以使用一个双核的CPU
- 存储：因为存储设备的写延迟会直接影响事务提交的效率，建议为`dataLogDir`分配一个独占的SSD盘。

```shell
# Define some default values that can be overridden by system properties
zookeeper.root.logger=INFO, CONSOLE

zookeeper.console.threshold=INFO

zookeeper.log.dir=.
zookeeper.log.file=zookeeper.log
zookeeper.log.threshold=INFO
zookeeper.log.maxfilesize=256MB
zookeeper.log.maxbackupindex=20

zookeeper.tracelog.dir=${zookeeper.log.dir}
zookeeper.tracelog.file=zookeeper_trace.log

log4j.rootLogger=${zookeeper.root.logger}

#
# console
# Add "console" to rootlogger above if you want to use this 
#
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.Threshold=${zookeeper.console.threshold}
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n

#
# Add ROLLINGFILE to rootLogger to get log file output
#
log4j.appender.ROLLINGFILE=org.apache.log4j.RollingFileAppender
log4j.appender.ROLLINGFILE.Threshold=${zookeeper.log.threshold}
log4j.appender.ROLLINGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}
log4j.appender.ROLLINGFILE.MaxFileSize=${zookeeper.log.maxfilesize}
log4j.appender.ROLLINGFILE.MaxBackupIndex=${zookeeper.log.maxbackupindex}
log4j.appender.ROLLINGFILE.layout=org.apache.log4j.PatternLayout
log4j.appender.ROLLINGFILE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n

#
# Add TRACEFILE to rootLogger to get log file output
#    Log TRACE level and above messages to a log file
#
log4j.appender.TRACEFILE=org.apache.log4j.FileAppender
log4j.appender.TRACEFILE.Threshold=TRACE
log4j.appender.TRACEFILE.File=${zookeeper.tracelog.dir}/${zookeeper.tracelog.file}

log4j.appender.TRACEFILE.layout=org.apache.log4j.PatternLayout
### Notice we are including log4j's NDC here (%x)
log4j.appender.TRACEFILE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L][%x] - %m%n
```

## 集群配置

- 准备zookeeper节点服务器。每个zookeeper节点有两个挂载盘。
- 所有节点安装jdk8
- 在所有节点为`dataLogDir`初始化一个独立的文件系统路径`/data`，编辑`/data/zookeeper/myid`。

## 监控

增加命令白名单

```shell
4lw.commands.whitelist=*
```

```shell
# 查看服务状态
[root@ansible ~]# echo ruok|ncat localhost 2181
imok

# 查看配置信息
[root@ansible ~]# echo conf|ncat localhost 2181
clientPort=2181
secureClientPort=-1
dataDir=/tmp/zookeeper/version-2
dataDirSize=0
dataLogDir=/data/zookeeper/2181/version-2
dataLogSize=424
tickTime=2000
maxClientCnxns=60
minSessionTimeout=4000
maxSessionTimeout=40000
serverId=0
[root@ansible ~]# echo conf|ncat localhost 2181
clientPort=2181
secureClientPort=-1
dataDir=/tmp/zookeeper/version-2
dataDirSize=0
dataLogDir=/data/zookeeper/2181/version-2
dataLogSize=424
tickTime=2000
maxClientCnxns=60
minSessionTimeout=4000
maxSessionTimeout=40000
serverId=0

# 查看节点状态
[root@ansible ~]# echo stat|ncat localhost 2181
Zookeeper version: 3.5.9-83df9301aa5c2a5d284a9940177808c01bc35cef, built on 01/06/2021 19:49 GMT
Clients:
 /127.0.0.1:43356[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/0
Received: 2
Sent: 1
Connections: 1
Outstanding: 0
Zxid: 0x0
Mode: standalone
Node count: 5

# 查看客户端状态
[root@ansible ~]# echo dump|ncat localhost 2181
SessionTracker dump:
Session Sets (3)/(1):
0 expire at Wed Apr 14 10:02:38 CST 2021:
0 expire at Wed Apr 14 10:02:48 CST 2021:
1 expire at Wed Apr 14 10:02:58 CST 2021:
        0x1001813b7630000
ephemeral nodes dump:
Sessions with Ephemerals (1):
0x1001813b7630000:
        /lock
Connections dump:
Connections Sets (4)/(2):
0 expire at Wed Apr 14 10:02:36 CST 2021:
1 expire at Wed Apr 14 10:02:46 CST 2021:
        ip: /127.0.0.1:43364 sessionId: 0x0
0 expire at Wed Apr 14 10:02:56 CST 2021:
1 expire at Wed Apr 14 10:03:06 CST 2021:
        ip: /127.0.0.1:43358 sessionId: 0x1001813b7630000

# 查看watch信息
[root@ansible ~]# echo wchc|ncat localhost 2181
0x1001813b7630000
        /lock

# 查询节点类型
[root@ansible zookeeper]# echo srvr |nc localhost 2181
Zookeeper version: 3.5.9-83df9301aa5c2a5d284a9940177808c01bc35cef, built on 01/06/2021 19:49 GMT
Latency min/avg/max: 0/0/5
Received: 70
Sent: 69
Connections: 2
Outstanding: 0
Zxid: 0x6
Mode: standalone
Node count: 7
```

## JMX

>zookeeper支持JMX，大量的监控和管理工作多可以通过JMX来做。可以把zookeeper的JMX数据集成到Prometheus，使用Prometheus来做zookeeper的监控

开启远程JMX

1. 设置JMX环境变量

```shell
export JMXPORT=8081
# 再重启zk
```
2. 设置`zkServer.sh`中启动参数，可以配置访问授权策略

```shell
ZOOMAIN="-Dcom.sun.management.jmxremote
 -Dcom.sun.management.jmxremote.local.only=false
 -Djava.rmi.server.hostname=172.16.4.70
 -Dcom.sun.management.jmxremote.rmi.port=8081
 -Dcom.sun.management.jmxremote.port=8081
 -Dcom.sun.management.jmxremote.ssl=false
 -Dcom.sun.management.jmxremote.authenticate=true
 -Dcom.sun.management.jmxremote.access.file=/usr/local/zookeeper/conf/jmxremote.access
 -Dcom.sun.management.jmxremote.password.file=/usr/local/zookeeper/conf/jmxremote.password
 -Dzookeeper.jmx.log4j.disable=true
 org.apache.zookeeper.server.quorum.QuorumPeerMain"
```


创建授权文件

>`/usr/local/jdk/jre/lib/management`中有相关文件说明

```shell
# 创建用户，配置权限
[root@ansible zookeeper]# cat conf/jmxremote.access
monitorRole   readonly
controlRole   readwrite \
              create javax.management.monitor.*,javax.management.timer.* \
              unregister
# 配置用户密码
[root@ansible zookeeper]# cat conf/jmxremote.password
monitorRole  1234567
controlRole  1234567
```

## Observer

>Observer和zookeeper机器其他节点唯一的交互式接收来自leader的inform信息，更新自己的本地存储，不参与提交和选举的投票过程。
>
>https://zookeeper.apache.org/doc/r3.5.3-beta/zookeeperObservers.html

```shell
server.1=ali-1:2222:2223
server.2=ali-2:2222:2223
server.3=ali-3:2222:2223
server.4=ali-4:2222:2223:observer
```

## 动态调整集群成员

>https://zookeeper.apache.org/doc/r3.5.3-beta/zookeeperReconfig.html#sc_reconfig_file

```shell
autopurge.purgeInterval=1
initLimit=30000
syncLimit=10
autopurge.snapRetainCount=10
skipACL=yes
maxClientCnxns=2000
4lw.commands.whitelist=*
maxSessionTimeout=60000000
tickTime=2000
dataDir=/data/
reconfigEnabled=true
dataLogDir=/data/logs
preAllocSize=131072

# 关键参数
reconfigEnabled=true
dynamicConfigFile=conf/dyn.cfg
```

```shell
# dyn.cfg
server.2=zoo2:2888:3888;2181
server.3=zoo3:2888:3888;2181
server.5=zoo5:2888:3888;2181
```

```shell
addauth digest super:kuuun
```

## 本地存储架构

- 内存中存储数据`data tree`
- 持久化设备存储事务日志

>每一个对zookeeper data tree都会作为一个事务执行。每一个事务都有一个zxid。zxid是一个64位的整数。zxid有两个组成部分，高4个字节保存的是epoch，低4个字节保存的是connter。

## 查看事务日志

```shell
[root@ansible version-2]# /usr/local/zookeeper/bin/zkTxnLogToolkit.sh log.7
ZooKeeper Transactional Log File with dbid 0 txnlog format version 2
4/14/21 12:59:22 PM CST session 0x10018a68e750000 cxid 0x0 zxid 0x7 createSession 30000
4/14/21 1:02:14 PM CST session 0x10018980fa90000 cxid 0x0 zxid 0x8 closeSession
4/14/21 1:19:10 PM CST session 0x10018a68e750000 cxid 0x0 zxid 0x9 closeSession
EOF reached after 3 txns.
```

## 查看快照文件

>zk每一次重启都会产生快照

```shell
java -cp /usr/local/zookeeper/lib/zookeeper-3.5.9.jar:/usr/local/zookeeper/lib/slf4j-api-1.7.25.jar:/usr/local/zookeeper/lib/zookeeper-jute-3.5.9.jar org.apache.zookeeper.server.SnapshotFormatter  snapshot.9
```

## Epoch文件

>只存于集群状态环境zk

两个文件分别反映了指定的server进程已经看到的和参与的epoch number。尽管这些文件不包含任何应用级别的数据，但他们对于数据一致性来说很重要，所以在你对数据文件进行备份时，不要漏掉这2个文件。

## Kakfa

>Confluent发行版kafka

- 下载Confluent

```shell
curl -O http://packages.confluent.io/archive/6.1/confluent-community-6.1.1.tar.gz
```

- 配置

在`etc/kafka/zookeeper.properties`配置`dataDir`
在`etc/kafka/server.properties`配置`log.dirs`，`broker.id`，`zookeeper.connect`

```shell
# 启动单节点zk
[root@ansible confluent-6.1.1]# ./bin/zookeeper-server-start -daemon etc/kafka/zookeeper.properties
# 连接测试
[root@ansible confluent-6.1.1]# ./bin/zookeeper-shell ansible:2182
Connecting to ansible:2182
Welcome to ZooKeeper!
JLine support is disabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
# 启动kafka
[root@ansible confluent-6.1.1]# ./bin/kafka-server-start -daemon etc/kafka/server.properties
```