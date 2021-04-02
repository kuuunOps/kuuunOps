# Kafka

>- Apache Kafka是一款开源的消息引擎系统。根据维基百科的定义，消息引擎系统是一组规范。企业利用这组在不同系统之间传递语义准确的消息，实现松耦合的异步式消息传递。通俗来讲，就是系统A发送消息给消息引擎，系统B从消息引擎系统中读取A发送的消息。
>- 消息引擎系统要设定具体的传输协议，即我用什么方法把消息传输出去，常见的方法有2种：点对点模型；发布/订阅模型。Kafka同时支持这两种消息引擎模型。
>- 系统A不能直接发消息给系统B，中间还要隔一个消息引擎，是为了“削峰填谷”。

---

## Kafka中名词术语

- 消息：Record。Kafka 是消息引擎嘛，这里的消息就是指 Kafka 处理的主要对象。
- 主题：Topic。主题是承载消息的逻辑容器，在实际使用中多用来区分具体的业务。
- 分区：Partition。一个有序不变的消息序列。每个主题下可以有多个分区。
- 消息位移：Offset。表示分区中每条消息的位置信息，是一个单调递增且不变的值。
- 副本：Replica。Kafka 中同一条消息能够被拷贝到多个地方以提供数据冗余，这些地方就是所谓的副本。副本还分为领导者副本和追随者副本，各自有不同的角色划分。副本是在分区层级下的，即每个分区可配置多个副本实现高可用。
- 生产者：Producer。向主题发布新消息的应用程序。
- 消费者：Consumer。从主题订阅新消息的应用程序。
- 消费者位移：Consumer Offset。表征消费者消费进度，每个消费者都有自己的消费者位移。
- 消费者组：Consumer Group。多个消费者实例共同组成的一个组，同时消费多个分区以实现高吞吐。
- 重平衡：Rebalance。消费者组内某个消费者实例挂掉后，其他消费者实例自动重新分配订阅主题分区的过程。Rebalance 是 Kafka 消费者端实现高可用的重要手段。

---

## Apache Kafka 真的只是消息引擎吗？

Apache Kafka 是消息引擎系统，也是一个分布式流处理平台

---

## Kafka常见版本

- Apache Kafka，也称社区版 Kafka。优势在于迭代速度快，社区响应度高，使用它可以让你有更高的把控度；缺陷在于仅提供基础核心组件，缺失一些高级的特性。
- Confluent Kafka，Confluent 公司提供的 Kafka。优势在于集成了很多高级特性且由 Kafka 原班人马打造，质量上有保证；缺陷在于相关文档资料不全，普及率较低，没有太多可供参考的范例。
- CDH/HDP Kafka，大数据云公司提供的 Kafka，内嵌 Apache Kafka。优势在于操作简单，节省运维成本；缺陷在于把控度低，演进速度较慢。

---

## Kafka的版本号

- 0.7版本：只提供了最基础的消息队列
- 0.8版本：引入副本机制，至此Kafka成为了一个真正意义上万的分布式高可靠消息队列解决方案。
- 0.9版本：增加了基础的安全认证/权限功能；使用Java重写了新版本消费者API；引入了Kafka Connect组件
- 0.10.0.0版本：引入了Kafka Streams，正式升级成为分布式流处理平台。
- 0.11.0.0版本：提供了幂等性ProducerAPI以及事务API；对Kafka消息格式做了重构
- 1.0和2.0版本：主要还是KafkaStream的各种改进。

---

## Kafka集群部署方案

| 因素     | 考量点                                  | 建议                                                              |
| -------- | --------------------------------------- | ----------------------------------------------------------------- |
| 操作系统 | 操作系统I/O模型                         | 将kafka部署在Linux系统上                                          |
| 磁盘     | 磁盘I/O性能                             | 普通环境使用机械磁盘，不需要搭建RAID                              |
| 磁盘容量 | 根据消息数、留存时间预估磁盘容量        | 实际使用中建议预留20%~30%的磁盘空间                               |
| 宽带     | 根据实际宽带资源和业务SLA预估服务器数量 | 对于千兆网络，建议每台服务器安装700Mbps来计算，避免大流量下的丢包 |

---

## Kafka集群重要参数配置

### Broker端参数

1. 存储相关
- `log.dirs`：只要设置这个参数。多路径设置：`/home/kafka1,/home/kafka2,/home/kafka3`
- `log.dir`：不要设置

2. 与zk相关
- `zookeeper.connect`:多套kafka集群共用设置：`zk1:2181,zk2:2181,zk3:2181/kafka1`和`zk1:2181,zk2:2181,zk3:2181/kafka2`

3. 与Broker相关
- `listeners`：学名叫监听器，其实就是告诉外部连接者要通过什么协议访问指定主机名和端口开放的 Kafka 服务。
- `advertised.listener`：和 listeners 相比多了个 advertised。Advertised 的含义表示宣称的、公布的，就是说这组监听器是 Broker 用于对外发布的。
- `host.name/port`：不要设置

4. 与Topic相关
- `auto.create.topics.enable`：是否允许自动创建 Topic。关闭
- `unclean.leader.election.enable`：是否允许 Unclean Leader 选举。关闭
- `auto.leader.rebalance.enable`：是否允许定期进行 Leader 选举。关闭

5. 与数据流程相关
- `log.retention.{hours|minutes|ms}`：这是个“三兄弟”，都是控制一条消息数据被保存多长时间。从优先级上来说 ms 设置最高、minutes 次之、hours 最低。
- `log.retention.bytes`：这是指定 Broker 为消息保存的总磁盘容量大小。
- `message.max.bytes`：控制 Broker 能够接收的最大消息大小。

---

### Topic级别参数

- `retention.ms`：规定了该 Topic 消息被保存的时长。默认是 7 天，即该 Topic 只保存最近 7 天的消息。一旦设置了这个值，它会覆盖掉 Broker 端的全局参数值。
- `retention.bytes`：规定了要为该 Topic 预留多大的磁盘空间。和全局参数作用相似，这个值通常在多租户的 Kafka 集群中会有用武之地。当前默认值是 -1，表示可以无限使用磁盘空间。
- `max.message.bytes`：决定了Broker能够正常接收该Topic的最大消息大小。

```shell
bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name transaction --alter --add-config max.message.bytes=10485760
```

---

### JVM参数

- KAFKA_HEAP_OPTS：指定堆大小。推荐6GB
- KAFKA_JVM_PERFORMANCE_OPTS：指定 GC 参数。

垃圾回收器

- 如果 Broker 所在机器的 CPU 资源非常充裕，建议使用 CMS 收集器。启用方法是指定-XX:+UseCurrentMarkSweepGC。
- 否则，使用吞吐量收集器。开启方法是指定-XX:+UseParallelGC。

```shell
$> export KAFKA_HEAP_OPTS=--Xms6g  --Xmx6g
$> export KAFKA_JVM_PERFORMANCE_OPTS= -server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -Djava.awt.headless=true
$> bin/kafka-server-start.sh config/server.properties
```

---

### 操作系统参数

- 文件描述符：超大值设置，例如：`ulimit -n 1000000`
- 文件系统类型：优先XFS
- Swappiness：设置一个接近0，但是不为0的值。
- 提交时间：

---

## 生产者分区机制原理

- Kafka的消息方式是三级结构：主体-分区-消息。主题下的每条消息只会保存在某一个分区中，而不会再多个分区中保存多分。
- 分区是实现负载均衡以及高吞吐量的关键。
- 分区策略：是决定生产者将消息发送到哪个分区的算法。Kafka提供了默认分区，也支持自定义分区。
- 常见分区策略：轮询策略、随机策略和按消息键保存顺序策略，还有一种基于地理位置的分区策略。

---

## 生产者压缩算法

- 在Kafka中，压缩发生在两个地方：生产端和Broker端。
- 让Broker重新压缩消息的2中例外情况：Broker端指定了和Producer不同的压缩算法：Broker端发生了消息格式转换。
- Producer端压缩、Broker端保持、Consumer端解压缩。
- 4种压缩算法性能：
  - 吞吐量：LZ4-->Snapp-->zstd和GZIP
  - 压缩比：zstd-->LZ4-->GZIP-->Snapp

---

## 无消息丢失配置

- 使用`producer.send(msg,callbacl)`
- 设置`acks=all`
- 设置`retries`为一个较大的值
- 设置`unclean.leader.election.enable=false`
- 设置`replcation.factor>=3`
- 设置`replcation.factor>min.insync.replicas`
- 确保消息消费完成再提交

- 不要使用 producer.send(msg)，而要使用 producer.send(msg, callback)。记住，一定要使用带有回调通知的 send 方法。
- 设置 acks = all。acks 是 Producer 的一个参数，代表了你对“已提交”消息的定义。如果设置成 all，则表明所有副本 Broker 都要接收到消息，该消息才算是“已提交”。这是最高等级的“已提交”定义。
- 设置 retries 为一个较大的值。这里的 retries 同样是 Producer 的参数，对应前面提到的 Producer 自动重试。当出现网络的瞬时抖动时，消息发送可能会失败，此时配置了 retries > 0 的 Producer 能够自动重试消息发送，避免消息丢失。
- 设置 unclean.leader.election.enable = false。这是 Broker 端的参数，它控制的是哪些 Broker 有资格竞选分区的 Leader。如果一个 Broker 落后原先的 Leader 太多，那么它一旦成为新的 Leader，必然会造成消息的丢失。故一般都要将该参数设置成 false，即不允许这种情况的发生。
- 设置 replication.factor >= 3。这也是 Broker 端的参数。其实这里想表述的是，最好将消息多保存几份，毕竟目前防止消息丢失的主要机制就是冗余。
- 设置 min.insync.replicas > 1。这依然是 Broker 端参数，控制的是消息至少要被写入到多少个副本才算是“已提交”。设置成大于 1 可以提升消息持久性。在实际环境中千万不要使用默认值 1。
- 确保 replication.factor > min.insync.replicas。如果两者相等，那么只要有一个副本挂机，整个分区就无法正常工作了。我们不仅要改善消息的持久性，防止数据丢失，还要在不降低可用性的基础上完成。推荐设置成 replication.factor = min.insync.replicas + 1。
- 确保消息消费完成再提交。Consumer 端有个参数 enable.auto.commit，最好把它设置成 false，并采用手动提交位移的方式。就像前面说的，这对于单 Consumer 多线程处理的场景而言是至关重要的。

---

## Kafka高级功能


