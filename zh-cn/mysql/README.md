# MySQL

---
## MySQL发行版

1. `Percona  Server`
   
   Percona Server由领先的MySQL咨询公司Percona发布。
   Percona Server是一款独立的数据库产品，其可以完全与MySQL兼容，可以在不更改代码的情况了下将存储引擎更换成XtraDB。是最接近官方MySQL Enterprise发行版的版本。
   
   Percona提供了高性能XtraDB引擎，还提供PXC高可用解决方案，并且附带了percona-toolkit等DBA管理工具箱。

2. `MariaDB`
   
   MariaDB由MySQL的创始人开发，MariaDB的目的是完全兼容MySQL，包括API和命令行，使之能轻松成为MySQL的代替品。
   MariaDB提供了MySQL提供的标准存储引擎，即MyISAM和InnoDB，10.0.9版起使用XtraDB（名称代号为Aria）来代替MySQL的InnoDB。

---

## MySQL三种存储引擎

| 引擎名称 | 描述                                                                                                                                                                                                                        |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MyISAM   | MySQL4和5使用默认的MyISAM存储引擎。表级锁、不支持事务和全文索引，适合一些CMS内容管理系统作为后台数据库使用，但是使用大并发、重负荷生产系统上，表锁结构的特性就显得力不从心；                                                |
| InnoDB   | 行级锁、事务安全（ACID兼容）、支持外键、不支持FULLTEXT类型的索引(5.6.4以后版本开始支持FULLTEXT类型的索引)。InnoDB存储引擎提供了具有提交、回滚和崩溃恢复能力的事务安全存储引擎。InnoDB是为处理巨大量时拥有最大性能而设计的。 |
| XtraDB   | XtraDB是InnoDB存储引擎的增强版本，被设计用来更好的使用更新计算机硬件系统的性能，同时还包含有一些在高性能环境下的新特性。                                                                                                    |

---

## MySQL5.6源码安装

安装依赖
```shell
yum install cmake
```
编译
```shell
cd mysql-5.6.17
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
```
创建MySQL用户
```shell
groupadd mysql
useradd -g mysql mysql
```
授权
```shell
chown -R mysql.mysql /usr/local/mysql
```
准备配置文件`my.cnf`，数据库初始化会使用配置文件进行初始操作。

数据库初始化，创建系统自带的数据库和表
```shell
cd /usr/local/mysql
./scripts/mysql_install_db \
--basedir=/usr/local/mysql \
--datadir=/usr/local/mysql/data \
--user=mysql
```
---

## MySQL二进制安装

1. 准备二进制包
```shell
tar xf  mysql-5.6.51-linux-glibc2.12-x86_64.tar.gz
mv mysql-5.6.51-linux-glibc2.12-x86_64 /usr/local/mysql
```
2. 创建mysql用户
```shell
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql
# mysql目录授权
chown -R mysql.mysql /usr/local/mysql
```
3. 准备配置文件，因为初始化会使用配置文件初始化
```shell
[mysql]
socket = /usr/local/mysql/data/mysql.sock
[mysqld]
default-storage-engine = innodb
innodb_buffer_pool_size = 6GB
innodb_file_per_table = 1
innodb_data_file_path = ibdata1:1G:autoextend
innodb_log_files_in_group = 2
innodb_log_file_size = 256MB
max_connections = 800
open_files_limit = 8000
innodb_open_files = 8000
expire_logs_days = 7
log_bin = mysql-bin
binlog_format = row
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
port = 3306
server_id = 10000471
socket = /usr/local/mysql/data/mysql.sock
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
[mysqladmin]
socket = /usr/local/mysql/data/mysql.sock
[mysqldump]
socket = /usr/local/mysql/data/mysql.sock
```

4. 初始化数据库
```shell
cd /usr/local/mysql
# 确保安装Linux异步插件libaio，否则会初始化失败。例如：yum install libaio-devel
./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
```

5. 启动服务
```shell
# 拷贝启动服务文件
cp ./support-files/mysql.server /etc/init.d/mysqld
/etc/init.d/mysqld start
```

---
## MySQL基本操作命令

1. 连接MySQL
```shell
# mysql -u 用户名 -h 主机IP -P 主机端口 -A 指定数据库 -p
mysql -uroot -h localhost -p
```

2. 修改密码
```shell
# mysqladmin -u 用户名 -p 旧密码 password 新密码
mysqladmin -uroot password 123456
```

3. 新增/授权用户
```sql
grant select on test.* to test@'%' identified by 'test';
```
5. 查询所有数据库
```sql
show databases;
```

6. 切换数据库
```sql
use mysql;
```

7. 显示库中所有的表
```sql
show tables;
```

8. 查看表结构
```sql
desc user;
```

9. 查了表数据
```shell
select * from user;
```

## MySQL简单增删改查

1. 创建数据库
```sql
create database test;
```
2. 删除数据库
```sql
drop database test;
```
3. 删除表
```sql
drop table test;
```
4. 插入数据
```sql
insert into test name,age values zhangsan,24;
```
5. 查询数据
```sql
select * from test;
```
6. 查询指定条数的数据
```sql
select * from test limit 0,2;
```
7. 删除表中的数据
```sql
delete from test where name='zhangsan';
```
8. 修改表中数据
```sql
update test  set age=30 where name='zhangsan'; 
```
7. 增加字段
```sql
alter table test add address var_char(255) default '';
```
8. 修改表名
```sql
rename table test to test2;
```
---

## MySQL备份数据库

1. 全库导出
```shell
mysqldump -u test -p123456 database_name > test.sql
```
2. 数据恢复
```sql
create database linux;
use linux;
source test.sql;
```
3. 导出表结构
```shell
mysqldump -u user_name -p -d –add-drop-table database_name > outfile_name.sql
```
4. 导出指定的表
```shell
mysqldump -u user_name -p database_name table_name > outfile_name.sql
```
5. 指定编码导出
```shell
mysqldump -uroot -p –default-character-set=utf8 –set-charset=utf8 –skip-opt database_name > outfile_name.sql
```

---

## MySQL调优

1. BIOS设置

- 选择`Performance Per Watt Optimized(DAPC)`模式，发挥CPU最大性能。
- `Memory Frequency（内存频率）`选择`Maximum Performance`（最佳性能）
- 内存设置菜单中，启用`Node Interleaving`，避免NUMA问题

2. 磁盘设置

- 优先使用SSD
- 如果是磁盘阵列存储，建议阵列卡同时配备CACHE及BBU模块，可明显提升IOPS。
- raid级别尽量选择raid10，而不是raid5.

3. 文件系统优化

- 使用deadline/noop这两种I/O调度器，千万别用cfq
- 使用xfs文件系统，千万别用ext3；ext4勉强可用，但业务量很大的话，则一定要用xfs；
- 文件系统mount参数中增加：`noatime`, `nodiratime`, `nobarrier`几个选项（`nobarrier`是xfs文件系统特有的）；

4. 内核优化

- 修改`vm.swappiness`参数，降低swap使用率。RHEL7/centos7以上则慎重设置为0，可能发生OOM,推荐设置为10。
- 调整`vm.dirty_background_ratio`、`vm.dirty_ratio`内核参数，以确保能持续将脏数据刷新到磁盘，避免瞬间I/O写。产生等待。
- 调整`net.ipv4.tcp_tw_recycle`、`net.ipv4.tcp_tw_reuse`都设置为1，减少TIME_WAIT，提高TCP效率。

---
## MySQL配置参数调优

- **default-storage-engine**
  设置存储引擎。推荐设置为InnoDB，强烈建议不要再使用MyISAM引擎

- **innodb_buffer_pool_size**
  设置缓冲池大小。这是你安装完InnoDB后第一个应该设置的选项。缓冲池是数据和索引缓存的地方：这个值越大越好，这能保证你在大多数的读取操作时使用的是内存而不是硬盘。典型的值是5-6GB(8GB内存)，20-25GB(32GB内存)，100-120GB(128GB内存)。

- **innodb_file_per_table**
  设置单表独立文件存放。这项设置告知InnoDB是否需要将所有表的数据和索引存放在共享表空间里（innodb_file_per_table = OFF），或者为每张表的数据单独放在一个.ibd文件（innodb_file_per_table = ON）。
  每张表一个文件可以保证在drop、truncate或者rebuild表时回收磁盘空间。这对于一些高级特性也是有必要的，比如数据压缩。但是不适合每张表一个文件的主要场景是：有非常多的表（比如10k+）。
  MySQL 5.6中，这个属性默认值是ON，对于之前的版本，必需在加载数据之前将这个属性设置为ON，因为它只对新创建的表有影响。

- **innodb_data_file_path**
  设置数据文件相关信息，文件名称，大小，特性。`innodb_data_file_path = ibdata1:1G:autoextend`不要用默认的10M,在高并发场景下，性能会有很大提升。

- **innodb_log_file_size**
  设置回滚日志文件大小。这是redo日志的大小。redo日志被用于确保写操作快速而可靠并且在崩溃时恢复，MySQL 5.5之前，redo日志的总尺寸被限定在4GB(默认可以有2个log文件)。这在MySQL 5.6里被提高。
  建议一开始就把innodb_log_file_size设置成512M(这样有1GB的redo日志)，这样会有充裕的写操作空间。如果应用程序需要频繁的写入数据，并且使用的时MySQL 5.6，可以一开始就把它这是成4G。

- **innodb_log_files_in_group**
  设置日志文件分组数量。推荐设置`innodb_log_files_in_group=2`基本可以满足大多数应用场景。

- **open_files_limit**
  设置打开文件数量限制。推荐设置为max_connection的10倍左右大小。

- **innodb_open_files**
  设置innodb引擎打开的文件数量。推荐设置为max_connection的10倍左右大小。

- **binlog_format**
  设置二进制日志文件格式，推荐设置为ROW，默认为Statement。日志格式一共有三种：Statement,ROW,Mixed

- **table_open_cache**
  设置表打开缓冲文件的数量。推荐设置为max_connection的10倍左右大小。

- **table_definition_cache**
  设置定义缓冲文件的数量。设置大约为max_connection的10倍左右大小。 

- **key_buffer_size**
  设置索引缓冲区大小。32M左右即可

- **query_cache_size** 
  设置查询缓冲。`InnoDB`建议关闭 

- **tmp_table_size**
  设置临时表的内存缓存大小。

- **max_heap_table_size**
  设置MEMORY内存引擎的表大小。
  
- **sort_buffer_size**
  设置排序缓冲大小。设置256K~2M即可

- **join_buffer_size**
  设置连接缓冲区大小。设置不宜过大

- **read_buffer_size**
  设置不宜过大

- **read_rnd_buffer_size**
  设置不宜过大

- **max_connections**
  如果经常看到‘Too many connections'错误，是因为max_connections的值太低了。这非常常见，因为应用程序没有正确的关闭数据库连接。max_connection值被设高了(例如1000或更高)之后一个主要缺陷是当服务器运行1000个或更高的活动事务时会变的没有响应。在应用程序里使用连接池或者在MySQL里使用进程池有助于解决这一问题。

- **innodb_flush_log_at_trx_commit**
  配置`redo log`日志写入方式。
  默认值为1，表示每一次事务提交或事务外的指令都需要把日志写入（flush）硬盘，这个过程是很费时的。当主要关注点是数据安全的时候这个值是最合适的，比如在一个主节点上。但是对于磁盘（读写）速度较慢的系统，会带来很巨大的开销，因为每次将改变flush到redo日志都需要额外的fsyncs。
  设置为2，它的意思是不写入硬盘而是写入系统缓存。日志仍然会每秒flush到硬盘，这对于一些场景是可以接受的，比如对于主节点的备份节点这个值是可以接受的。
  设置为0，速度就更快了，但在系统崩溃时可能丢失一些数据：只适用于备份节点。

- **innodb_flush_method**
  这项配置决定了数据和日志写入硬盘的方式。
  这个参数控制着innodb数据文件及redo log的打开、刷写模式。
  一般来说，如果你有硬件RAID控制器，并且其独立缓存采用write-back机制，并有着电池断电保护，那么应该设置配置为`O_DIRECT`；否则，大多数情况下应将其设为`fdatasync`（默认值）。
  三个可选值：`fdatasync`，`O_DIRECT`，`O_DSYNC`。


- **innodb_log_buffer_size**
  这项配置决定了为尚未执行的事务分配的缓存。
  其默认值（1MB）一般来说已经够用了，但是如果你的事务中包含有二进制大对象或者大文本字段的话，这点缓存很快就会被填满并触发额外的I/O操作。
  看看Innodb_log_waits状态变量，如果它不是0，增加innodb_log_buffer_size。

- **log_bin**
  如果想让数据库服务器充当主节点的备份节点，那么开启二进制日志是必须的。
  如果这么做了之后，还别忘了设置server_id为一个唯一的值。就算只有一个服务器，如果你想做基于时间点的数据恢复，这（开启二进制日志）也是很有用的。从你最近的备份中恢复（全量备份），并应用二进制日志中的修改（增量备份）。二进制日志一旦创建就将永久保存。所以如果你不想让磁盘空间耗尽，你可以用` PURGE BINARY LOGS `来清除旧文件，或者设置 `expire_logs_days `来指定过多少天日志将被自动清除。

- **skip_name_resolve**
  当客户端连接数据库服务器时，服务器会进行主机名解析，并且当DNS很慢时，建立连接也会很慢。
  因此建议在启动服务器时关闭skip_name_resolve选项而不进行DNS查找。唯一的局限是之后GRANT语句中只能使用IP地址了

- **slow_query_log**
  开启数据库慢查询日志。

- **slow_query_log_file**
  配置慢查询日志文件存放文件

- **long_query_time**
  设置慢查询日志记录的时间阈值。默认值为10秒
---

## MySQL慢查询语句分析

按查询语句次数排序
```shell
mysqldumpslow -s c -t 10 ./data/mysql-slow.log
```
按查询语句执行时间排序
```shell
mysqldumpslow -s t -t 10 ./data/mysql-slow.log
```

---
## MySQL主从复制原理

1. 用户端提交变更事件，master的转储线程（Binlog_dump_thread）将变更事件写入到bin_log中。
2. master通过网络将最新的bin_log事件传输给slave端。
3. slave接收到IO线程的bin_log事件，写入到中继日志`relay log`中。
4. slave中SQL线程读取中继日志中内容，转换为具体SQL语句内容进行执行。

---
## MySQL主从复制配置

#### 1、修改配置文件
master节点配置参考
```shell
# 节点标识，主、从节点不能相同，必须全局唯一
server-id = 1
# 表示开启MySQL 的 binlog 日志功能。
# mysql-bin表示日志文件的命名格式，会生成文件名为mysql-bin.000001、mysql-bin.000002 等的日志文件。
log-bin=mysql-bin
```
slave节点配置参考
```shell
server-id = 2
log-bin=mysql-bin
# 定义 relay-log 日志文件的命名格式。
relay-log = mysql-relay-bin
# 是个复制过滤选项，可以过滤掉不需要复制的数据库或表，
# 例如:"mysql.%"表示不复制mysql库下的所有对象，其他依此类推。
# 与此对应的是replicate_wild_do_table 选项，用来指定需要复制的数据库或表。
replicate-wild-ignore-table=mysql.%
replicate-wild-ignore-table=test.%
replicate-wild-ignore-table=information_schema.%
# 不要在主库上使用 binlog-do-db 或 binlog-ignore-db 选项，也不要在从库上使用 replicate-do-db 或 replicate-ignore-db 选项，因为这样可能产生跨库更新失败的问题。
# 推荐在从库上使用 replicate_wild_do_table 和 replicate-wild-ignore-table 两个选项来解决复制过滤问题。
```
#### 2、同步数据（可选）
如果主节点是已经存在数据的，需要先导出数据。
```sql
-- 开启只读锁，并再打开一个终端开始导出数据。
-- 注意：本终端不能关闭
flush tables with read lock;
```
同步完数据，重启主从节点数据库

#### 3、创建同步用户
在主库上创建同步用户并授权
```sql
grant replication slave on *.* to 'repl_user'@'172.16.4.72' identified by '123456';
-- 查看主库状态，记录文件名称File，文件位置Position
show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000005 |      333 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```
#### 4、配置从库
在从库手动指定主库信息
```sql
change master to master_host='172.16.4.71',master_user='repl_user',master_password='123456',master_log_file='mysql-bin.000005',master_log_pos=333;
```
启动从库复制功能
```sql
start slave;
-- 在从库上查看slave状态
-- 确保IO线程和SQL线程正常。并且没有Error错误信息
show slave status;
```
---

## MySQL常见备份策略

- 全量备份
- 差异备份
- 增量备份

---

## MySQL双主配置

- 1. 配置主从模式
- 2. 在从节点开启bin_log等其他相关参数，重启从库。
- 3. 开始正常配置主从。

---

## MySQL+Keepalived实现双主高可用

```shell
yum install keepalived
```

配置keepalived
```sql
global_defs { 
  notification_email {
    acassen@firewall.loc
    failover@firewall.loc sysadmin@firewall.loc
  }
  notification_email_from Alexandre.Cassen@firewall.loc 
    smtp_server 192.168.200.1
    smtp_connect_timeout 30
    router_id MySQLHA_DEVEL
}

vrrp_script check_mysqld {
  script "/etc/keepalived/mysqlcheck/check_slave.sh"
  interval 2
}

vrrp_instance HA_1 {
  #如果是不抢占模式，需要在 DB1 和 DB2 上均配置为 BACKUP interface eth0
  state MASTER
  virtual_router_id 80

  priority 100

  advert_int 2
  # 配置不抢占模式，只在优先级高的机器上设置即可，优先级低的机器不设置
  # nopreempt 

  authentication {
    auth_type PASS
    auth_pass qweasdzxc
  }

  track_script {
    check_mysqld
  }

  virtual_ipaddress {
    #mysql 的对外服务 IP，即 VIP
    172.16.4.60/24 dev eth0
  }
}
```

mysql状态检查脚本。
```shell
#!/bin/sh

slave_is=($(/usr/local/mysql/bin/mysql  -e "show slave status\G"|grep "Slave_.*_Running" |awk '{print $2}'))

if [ "${slave_is[0]}" = "Yes" -a "${slave_is[1]}" = "Yes" ]
then
  exit 0
else
  exit 1
fi
```

---

## Xtrabackup安装

>官网地址：https://www.percona.com/downloads

---

## Xtrabackup全量备份

```shell
# 备份语句示例
innobackupex --defaults-file=/etc/my.cnf --host=172.16.4.71 --port=3306 --user=root --password=123456  /data/
```
取消默认时间戳备份
```shell
innobackupex --defaults-file=/etc/my.cnf --host=172.16.4.72 --port=3306 --user=root --password=123456 --no-timestamp /data/full-backup
```
输出内容转储日志
```shell
innobackupex --defaults-file=/etc/my.cnf --host=172.16.4.72 --port=3306 --user=root --password=123456 --no-timestamp /data/full-backup 2>>/data/full-backup.log
```

---
## Xtrabackup全量恢复

1. 备份数据填充准备
```shell
innobackupex --defaults-file=/etc/my.cnf --apply-log /data/2021-03-29_14-22-23/
```

2. 进行数据恢复
```shell
innobackupex --defaults-file=/etc/my.cnf --copy-back /data/2021-03-29_14-22-23/
```

3. 启动数据库
```shell
# 修改数据目录权限
chown -R mysql.mysql /usr/local/mysql/data
# 启动
/etc/init.d/mysqld start
```

---

## xtrabackup备份压缩

```shell
innobackupex --defaults-file=/etc/my.cnf --host=172.16.4.71 --port=3306 --user=root --password=123456 --stream=tar /data/|gzip >full-backup.tar.gz
```


---

## Xtrabackup增量备份

```shell
innobackupex --defaults-file=/etc/my.cnf --incremental --host=172.16.4.72 --port=3306 --user=root --password=123456  --incremental-basedir=/data/full-backup /data/
```

---

## Xtrbackup增量还原

1. 还原基础全备的redo数据
```shell
innobackupex --apply-log --redo-only /data/full-backup/
```

2. 还原第一次redo数据
```shell
innobackupex --apply-log --redo-only /data/full-backup/ --incremental-dir=/data/2021-03-29_16-57-06/
```

3. 还原第二次redo数据
```shell
innobackupex --apply-log --redo-only /data/full-backup/ --incremental-dir=/data/2021-03-29_17-16-51
```

4. 对所有redo数据还原
```shell
innobackupex --defaults-file=/etc/my.cnf --copy-back /data/full-backup/
```

---

## MySQL复制模式

-  **异步复制（Asynchronous replication）**

>MySQL默认的复制即是异步的，主库在执行完客户端提交的事务后会立即将结果返给给客户端，并不关心从库是否已经接收并处理，这样就会有一个问题，主如果crash掉了，此时主上已经提交的事务可能并没有传到从上，如果此 时，强行将从提升为主，可能导致新主上的数据不完整。

-  **全同步复制（Fully synchronous replication）**

>当主库执行完一个事务，所有的从库都执行了该事务才返回给客户端。因为需要等待所有从库执行完该事务才能返回，所以全同步复制的性能必然会收到严重的影响。

-  **半同步复制（Semisynchronous replication）**

>介于异步复制和全同步复制之间，主库在执行完客户端提交的事务后不是立刻返回给客户端，而是等待至少一个从库接收 到并写到`relay log`中才返回给客户端。相对于异步复制，半同步复制提高了数据的安全性，同时它也造成了一定程度的延迟，这个延迟最少是一个TCP/IP往返的时间。所以，半同步复制最好在低延时的网络中使用。

**总结**

默认情况下MySQL的复制是异步的，Master上所有的更新操作写入Binlog之后 并不确保所有的更新都被复制到Slave之上。异步操作虽然效率高，但是在Master/Slave出现问题的时 候，存在很高数据不同步的风险，甚至可能丢失数据。 MySQL5.5引入半同步复制功能的目的是为了保 证在master出问题的时候，至少有一台Slave的数据是完整的。在超时的情况下也可以临时转入异步复制，保障业务的正常使用，直到一台salve追赶上之后，继续切换到半同步模式。

---

## MHA工作原理

- 从宕机崩溃的master保存二进制日志事件(binlogevents)。 
- 识别含有最新更新的slave。 
- 应用差异的中继日志(relay log)到其它slave。 
- 应用从master保存的二进制日志事件(binlogevents)。 
- 提升一个slave为新master。 
- 使其它的slave连接新的master进行复制。

MHA主要支持一主多从的架构，要搭建MHA,要求一个复制集群中必须最少有三台数据库服务器，一主二从，即一台充当master，一台充当备用master，另外一台充当从库，因为至少需要三台服务器。

---

## MHA角色

- `MHA Manager`
  
  可以单独部署 在一台独立的机器上管理多个master-slave集群，也可以部署在一台slave节点上。

- `MHA Node`
  
  运行在每台 MySQL服务器上，`MHA Manager`会定时探测集群中的master节点，当master出现故障时，它可以自动将最新数据的slave提升为新的master，然后将所有其他的slave重新指向新的master。

---
## MySQL配置半同步复制

>MySQL半同步插件是由谷歌提供，默认安装在`/usr/local/mysql/lib/plugin/`，分别是：`semisync_master.so`与`semisync_slave.so`。

1. 检测数据库是否支持动态加载插件

```sql
mysql> show variables like '%have_dynamic%';
+----------------------+-------+
| Variable_name        | Value |
+----------------------+-------+
| have_dynamic_loading | YES   |
+----------------------+-------+
1 row in set (0.00 sec)

```

2. 安装插件（所有数据库节点）

```sql
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
Query OK, 0 rows affected (0.01 sec)

mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
Query OK, 0 rows affected (0.00 sec)

-- 查看插件是否安装
mysql> show plugins ;

```

3. 配置`my.cnf`

```shell
# 1表示启用，0表示关闭，slave同样
rpl_semi_sync_master_enabled = 1
# 毫秒单位，主服务器等待确认消息10秒后，不在等待，变为异步方式
rpl_semi_sync_master_timeout = 1000 
rpl_semi_sync_slave_enabled = 1
# 0表示禁止 SQL 线程在执行完一个 relay log 后自动将其删除，对于MHA场景下，对于某些滞后从库的恢复依赖于其他从库的relay log，因此采取禁用自动删除功能
relay_log_purge = 0
```
重启服务

4. 查看状态

```sql
mysql> show variables like '%sem%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| rpl_semi_sync_master_enabled       | ON    |
| rpl_semi_sync_master_timeout       | 1000  |
| rpl_semi_sync_master_trace_level   | 32    |
| rpl_semi_sync_master_wait_no_slave | ON    |
| rpl_semi_sync_slave_enabled        | ON    |
| rpl_semi_sync_slave_trace_level    | 32    |
+------------------------------------+-------+
6 rows in set (0.00 sec)

```

---

## MHA配置



服务器规划

| 服务器IP    | 服务器角色        | 服务器组件                       |
| ----------- | ----------------- | -------------------------------- |
| 172.16.4.71 | master            | mysql<br>mha-node                |
| 172.16.4.72 | candidate master  | mysql<br>mha-node                |
| 172.16.4.73 | slave+mha-manager | mysql<br>mha-manager<br>mha-node |

### 1. 配置所有节点SSH互免密登录

为所有节点配置hosts
```shell
cat >> /etc/hosts << EOF
172.16.4.71 master
172.16.4.72 candidate_master
172.16.4.73 slave
EOF
```
在所有节点上操作

- 生成秘钥
```shell
ssh-keygen
```

- 推送秘钥
```
for host in master candidate_master slave ;do ssh-copy-id -i ~/.ssh/id_rsa.pub root@$host ;done
```


### 2. 配置主从数据库

>准备mysql数据包，安装mysql，但是环境使用MySQL版本为：mysql-5.6.51-linux-glibc2.12-x86_64.tar.gz

#### 1. 配置主从

1. 所有节点安装依赖包
```shell
[root@centos-vm-4-71 mysql]# yum install -y libaio-devel
```

2. 节点操作

- `master`

```shell
[root@centos-vm-4-71 ~]# tar xf mysql-5.6.51-linux-glibc2.12-x86_64.tar.gz
[root@centos-vm-4-71 ~]# mv mysql-5.6.51-linux-glibc2.12-x86_64 /usr/local/mysql
[root@centos-vm-4-71 ~]# vi /etc/my.cnf
[root@centos-vm-4-71 ~]# cat /etc/my.cnf
[mysqld]
server-id = 100001
default-storage-engine = innodb
log-bin = mysql-bin
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
binlog_format = row
log-bin-index = mysql-bin.index
relay_log_purge = 0
relay-log = relay-bin
relay-log-index = relay-bin.index
 
[mysqld_safe]
log-error=/usr/local/mysql/data/error.log
pid-file=/usr/local/mysql/data/mysql.pid
 
[root@centos-vm-4-71 ~]# groupadd mysql
[root@centos-vm-4-71 ~]# useradd -g mysql -s /sbin/nologin mysql
[root@centos-vm-4-71 ~]# chown -R mysql.mysql /usr/local/mysql
[root@centos-vm-4-71 ~]# cd /usr/local/mysql/
[root@centos-vm-4-71 mysql]# ./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
[root@centos-vm-4-71 mysql]# ln -sf /usr/local/mysql/bin/* /usr/bin/
[root@centos-vm-4-71 mysql]# cp support-files/mysql.server /etc/init.d/mysqld
[root@centos-vm-4-71 mysql]# systemctl enable mysqld
mysqld.service is not a native service, redirecting to /sbin/chkconfig.
Executing /sbin/chkconfig mysqld on
[root@centos-vm-4-71 mysql]# systemctl start mysqld
[root@centos-vm-4-71 mysql]# mysqladmin -uroot -p password
Enter password:
New password:
Confirm new password:
[root@centos-vm-4-71 mysql]# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.6.51-log MySQL Community Server (GPL)
 
Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.
 
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
 
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
 
mysql> grant replication slave on *.* to 'repl_user'@'172.16.4.%' identified by '123456';
Query OK, 0 rows affected (0.01 sec)
 
mysql> grant all privileges on *.* to 'manager'@'172.16.4.%' identified by '123456';
Query OK, 0 rows affected (0.00 sec)
 
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000003 |      681 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
 
mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
Query OK, 0 rows affected (0.00 sec)
 
mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
Query OK, 0 rows affected (0.01 sec)
 
mysql> ^DBye
[root@centos-vm-4-71 mysql]# vi /etc/my.cnf
# 增加半同步配置
rpl_semi_sync_master_enabled = 1
rpl_semi_sync_master_timeout = 1000
rpl_semi_sync_slave_enabled = 1
[root@centos-vm-4-71 mysql]# systemctl restart mysqld
[root@centos-vm-4-71 mysql]# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.51-log MySQL Community Server (GPL)
 
Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.
 
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
 
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
 
mysql> show variables like '%sem%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| rpl_semi_sync_master_enabled       | ON    |
| rpl_semi_sync_master_timeout       | 1000  |
| rpl_semi_sync_master_trace_level   | 32    |
| rpl_semi_sync_master_wait_no_slave | ON    |
| rpl_semi_sync_slave_enabled        | ON    |
| rpl_semi_sync_slave_trace_level    | 32    |
+------------------------------------+-------+
6 rows in set (0.00 sec)
```

--- 

- `candidate master`

```shell
[root@centos-vm-4-72 ~]# tar xf mysql-5.6.51-linux-glibc2.12-x86_64.tar.gz
[root@centos-vm-4-72 ~]# mv mysql-5.6.51-linux-glibc2.12-x86_64 /usr/local/mysql
[root@centos-vm-4-72 ~]# vi /etc/my.cnf
[root@centos-vm-4-72 ~]# cat /etc/my.cnf
[mysqld]
server-id = 100002
default-storage-engine = innodb
log-bin = mysql-bin
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
binlog_format = row
log-bin-index = mysql-bin.index
relay_log_purge = 0
relay-log = relay-bin
relay-log-index = relay-bin.index
 
[mysqld_safe]
log-error=/usr/local/mysql/data/error.log
pid-file=/usr/local/mysql/data/mysql.pid
[root@centos-vm-4-72 ~]# groupadd mysql
[root@centos-vm-4-72 ~]# useradd -g mysql mysql
[root@centos-vm-4-72 ~]# chown -R mysql.mysql /usr/local/mysql
[root@centos-vm-4-72 ~]# cd /usr/local/mysql/
[root@centos-vm-4-72 mysql]# ./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
[root@centos-vm-4-72 mysql]# ln -sf /usr/local/mysql/bin/* /usr/bin/
[root@centos-vm-4-72 mysql]# cp support-files/mysql.server /etc/init.d/mysqld
[root@centos-vm-4-72 mysql]# systemctl enable mysqld
mysqld.service is not a native service, redirecting to /sbin/chkconfig.
Executing /sbin/chkconfig mysqld on
[root@centos-vm-4-72 mysql]# systemctl start mysqld
[root@centos-vm-4-72 mysql]# mysqladmin -uroot -p password
Enter password:
New password:
Confirm new password:
[root@centos-vm-4-72 mysql]# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.6.51-log MySQL Community Server (GPL)
 
Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.
 
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
 
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
 
mysql> grant replication slave on *.* to 'repl_user'@'172.16.4.%' identified by '123456';
Query OK, 0 rows affected (0.00 sec)
 
mysql> grant all privileges on *.* to 'manager'@'172.16.4.%' identified by '123456';
Query OK, 0 rows affected (0.00 sec)

mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';
Query OK, 0 rows affected (0.01 sec)

mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
Query OK, 0 rows affected (0.00 sec)

mysql> ^DBye
[root@centos-vm-4-72 mysql]# vim /etc/my.cnf
# 增加半同步配置
rpl_semi_sync_master_enabled = 1
rpl_semi_sync_master_timeout = 1000
rpl_semi_sync_slave_enabled = 1
[root@centos-vm-4-72 mysql]# systemctl restart mysqld
[root@centos-vm-4-72 mysql]# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.6.51-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show variables like '%sem%';
+------------------------------------+-------+
| Variable_name                      | Value |
+------------------------------------+-------+
| rpl_semi_sync_master_enabled       | ON    |
| rpl_semi_sync_master_timeout       | 1000  |
| rpl_semi_sync_master_trace_level   | 32    |
| rpl_semi_sync_master_wait_no_slave | ON    |
| rpl_semi_sync_slave_enabled        | ON    |
| rpl_semi_sync_slave_trace_level    | 32    |
+------------------------------------+-------+
6 rows in set (0.00 sec)

mysql> change master to master_host='172.16.4.71',master_user='repl_user',master_password='123456',master_log_file='mysql-bin.000003',master_log_pos=681;
Query OK, 0 rows affected, 2 warnings (0.02 sec)
 
mysql> start slave;
Query OK, 0 rows affected (0.00 sec)
 
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.16.4.71
                  Master_User: repl_user
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 681
               Relay_Log_File: relay-bin.000002
                Relay_Log_Pos: 283
        Relay_Master_Log_File: mysql-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 681
              Relay_Log_Space: 450
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 100001
                  Master_UUID: cfbbad2b-91bb-11eb-a3d3-0050568d753b
             Master_Info_File: /usr/local/mysql/data/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
1 row in set (0.00 sec)
```

---

- `slave`

```shell
[root@centos-vm-4-73 ~]# tar xf mysql-5.6.51-linux-glibc2.12-x86_64.tar.gz
[root@centos-vm-4-73 ~]# mv mysql-5.6.51-linux-glibc2.12-x86_64 /usr/local/mysql
[root@centos-vm-4-73 ~]# vi /etc/my.cnf
[root@centos-vm-4-73 ~]# cat /etc/my.cnf
[mysqld]
server-id = 100003
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
default-storage-engine = innodb
log-bin = mysql-bin
binlog_format = row
relay-log = relay-bin
read_only = 1
relay_log_purge = 0
relay-log-index = relay-bin.index

[mysqld_safe]
log-error=/usr/local/mysql/data/error.log
pid-file=/usr/local/mysql/data/mysql.pid
[root@centos-vm-4-73 ~]# groupadd mysql
[root@centos-vm-4-73 ~]# useradd -g mysql -s /sbin/nologin mysql
[root@centos-vm-4-73 ~]# chown -R mysql.mysql /usr/local/mysql/
[root@centos-vm-4-73 ~]# cd /usr/local/mysql/
[root@centos-vm-4-73 mysql]# ./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
[root@centos-vm-4-73 mysql]# ln -sf /usr/local/mysql/bin/* /usr/bin/
[root@centos-vm-4-73 mysql]# cp support-files/mysql.server /etc/init.d/mysqld
[root@centos-vm-4-73 mysql]# systemctl enable mysqld
mysqld.service is not a native service, redirecting to /sbin/chkconfig.
Executing /sbin/chkconfig mysqld on
[root@centos-vm-4-73 mysql]# systemctl start mysqld
[root@centos-vm-4-73 mysql]# mysqladmin -uroot -p password
Enter password:
New password:
Confirm new password:
[root@centos-vm-4-73 mysql]# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.6.51-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> grant all privileges on *.* to 'manager'@'172.16.4.%' identified by '123456';
Query OK, 0 rows affected (0.00 sec)

mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
Query OK, 0 rows affected (0.00 sec)

mysql> ^DBye
[root@centos-vm-4-73 mysql]# vim /etc/my.cnf
# 增加配置
rpl_semi_sync_slave_enabled = 1
[root@centos-vm-4-73 mysql]# systemctl restart mysqld
[root@centos-vm-4-73 mysql]# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.51-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show variables like '%sem%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| rpl_semi_sync_slave_enabled     | ON    |
| rpl_semi_sync_slave_trace_level | 32    |
+---------------------------------+-------+
2 rows in set (0.00 sec)

mysql> change master to master_host='172.16.4.71',master_user='repl_user',master_password='123456',master_log_file='mysql-bin.000003',master_log_pos=681;
Query OK, 0 rows affected, 2 warnings (0.01 sec)

mysql> start slave;
Query OK, 0 rows affected (0.00 sec)

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.16.4.71
                  Master_User: repl_user
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000004
          Read_Master_Log_Pos: 120
               Relay_Log_File: relay-bin.000003
                Relay_Log_Pos: 283
        Relay_Master_Log_File: mysql-bin.000004
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 120
              Relay_Log_Space: 780
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 100001
                  Master_UUID: cfbbad2b-91bb-11eb-a3d3-0050568d753b
             Master_Info_File: /usr/local/mysql/data/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
1 row in set (0.00 sec)
```

### 3. 安装MHA

>MHA版本说明：
>
>MySQL版本5.6.x以下的需要使用，MHA版本为0.56
>
>MySQL版本5.7.x以上的需要使用，MHA版本为0.58
>
>作者网站：http://www.mysql.gr.jp/
>
>安装说明：https://gitee.com/kuuun/mha4mysql-manager/wikis/pages

#### 1. 安装依赖包

```shell
yum -y install perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Config-IniFiles ncftp perl-Params-Validate perl-CPAN perl-Test-Mock-LWP.noarch perl-LWP-Authen-Negotiate.noarch perl-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker
```

#### 2. 安装MHA

1. `master`

>安装`mha4mysql-node-0.56-0.el6.noarch.rpm`

```shell
[root@centos-vm-4-71 ~]# rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:mha4mysql-node-0.56-0.el6        ################################# [100%]
```

2. `candidate master`

>安装`mha4mysql-node-0.56-0.el6.noarch.rpm`

```shell
[root@centos-vm-4-72 ~]# rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:mha4mysql-node-0.56-0.el6        ################################# [100%]
```

3. `slave`

>安装`mha4mysql-node-0.56-0.el6.noarch.rpm`
>
>安装`mha4mysql-manager-0.56-0.el6.noarch.rpm`

```shell
[root@centos-vm-4-73 ~]# rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:mha4mysql-node-0.56-0.el6        ################################# [100%]
[root@centos-vm-4-73 ~]# rpm -ivh mha4mysql-manager-0.56-0.el6.noarch.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:mha4mysql-manager-0.56-0.el6     ################################# [100%]
```

#### 3. 配置MHA

>在slave节点上进行操作，因为`mha-manager`安装在此节点

1. 创建相关目录

```shell
[root@centos-vm-4-73 mha4mysql-manager]# mkdir -p /usr/local/masterha/{scripts,app1}
[root@centos-vm-4-73 ~]# git clone https://gitee.com/kuuun/mha4mysql-manager.git
Cloning into 'mha4mysql-manager'...
remote: Enumerating objects: 1460, done.
remote: Counting objects: 100% (1460/1460), done.
remote: Compressing objects: 100% (424/424), done.
remote: Total 1460 (delta 893), reused 1460 (delta 893), pack-reused 0
Receiving objects: 100% (1460/1460), 382.51 KiB | 0 bytes/s, done.
Resolving deltas: 100% (893/893), done.
[root@centos-vm-4-73 ~]# cd mha4mysql-manager
[root@centos-vm-4-73 mha4mysql-manager]# cp samples/scripts/* /usr/local/masterha/scripts/
[root@centos-vm-4-73 mha4mysql-manager]# cp samples/conf/masterha_default.cnf /etc/
[root@centos-vm-4-73 mha4mysql-manager]# cp samples/conf/app1.cnf /etc/
```

2. 全局配置

```shell
[root@centos-vm-4-73 ~]# cat /etc/masterha_default.cnf
[server default]
user=manager
password=123456
ssh_user=root
master_binlog_dir= /usr/local/mysql/data
remote_workdir=/var/log/masterha/app1
secondary_check_script= masterha_secondary_check -s master
ping_interval=3

repl_user=repl_user
repl_password=123456

master_ip_failover_script= /usr/local/masterha/scripts/master_ip_failover
# shutdown_script= /usr/local/masterha/scripts/power_manager
report_script= /usr/local/masterha/scripts/send_report
master_ip_online_change_script= /usr/local/masterha/scripts/master_ip_online_change
```

3. 应用配置文件

```shell
[root@centos-vm-4-73 ~]# cat /etc/app1.cnf
[server default]
manager_workdir=/usr/local/masterha/app1
manager_log=/usr/local/masterha/app1/manager.log

[server1]
hostname=master
candidate_master=1

[server2]
hostname=candidate_master
candidate_master=1

[server3]
hostname=slave
no_master=1
```

4. 配置VIP

>/usr/local/masterha/scripts/master_ip_failover

```perl
#!/usr/bin/env perl

#  Copyright (C) 2011 DeNA Co.,Ltd.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#  Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## Note: This is a sample script and is not complete. Modify the script based on your environment.

use strict;
use warnings FATAL => 'all';

use Getopt::Long;
use MHA::DBHelper;

my (
  $command,        $ssh_user,         $orig_master_host,
  $orig_master_ip, $orig_master_port, $new_master_host,
  $new_master_ip,  $new_master_port,  $new_master_user,
  $new_master_password
);

my $vip='172.16.4.70/24';
my $if='eth0';
my $ssh_add_vip="/usr/sbin/ip address add $vip dev $if";
my $ssh_del_vip="/usr/sbin/ip address del $vip dev $if";

GetOptions(
  'command=s'             => \$command,
  'ssh_user=s'            => \$ssh_user,
  'orig_master_host=s'    => \$orig_master_host,
  'orig_master_ip=s'      => \$orig_master_ip,
  'orig_master_port=i'    => \$orig_master_port,
  'new_master_host=s'     => \$new_master_host,
  'new_master_ip=s'       => \$new_master_ip,
  'new_master_port=i'     => \$new_master_port,
  'new_master_user=s'     => \$new_master_user,
  'new_master_password=s' => \$new_master_password,
);

exit &main();


sub add_vip {
  `ssh $ssh_user\@$new_master_host "$ssh_add_vip"`;
}
sub del_vip {
  `ssh $ssh_user\@$orig_master_host "$ssh_del_vip"`;
}

sub main {
  if ( $command eq "stop" || $command eq "stopssh" ) {

    # $orig_master_host, $orig_master_ip, $orig_master_port are passed.
    # If you manage master ip address at global catalog database,
    # invalidate orig_master_ip here.
    my $exit_code = 1;
    eval {
      print "Disabling the VIP on old master: $orig_master_host \n";
      &del_vip();
      # updating global catalog, etc
      $exit_code = 0;
    };
    if ($@) {
      warn "Got Error: $@\n";
      exit $exit_code;
    }
    exit $exit_code;
  }
  elsif ( $command eq "start" ) {

    # all arguments are passed.
    # If you manage master ip address at global catalog database,
    # activate new_master_ip here.
    # You can also grant write access (create user, set read_only=0, etc) here.
    my $exit_code = 10;
    eval {
      print "Enabling the VIP - $vip on the new master - $new_master_host \n";
      &add_vip();
      $exit_code = 0;
    };
    if ($@) {
      warn $@;

      # If you want to continue failover, exit 10.
      exit $exit_code;
    }
    exit $exit_code;
  }
  elsif ( $command eq "status" ) {

    # do nothing
    exit 0;
  }
  else {
    &usage();
    exit 1;
  }
}

sub usage {
  print
"Usage: master_ip_failover --command=start|stop|stopssh|status --orig_master_host=host --orig_master_ip=ip --orig_master_port=port --new_master_host=host --new_master_ip=ip --new_master_port=port\n";
}
```


5. 测试配置

```shell
[root@centos-vm-4-73 ~]# masterha_check_ssh --conf=/etc/app1.cnf
Wed Mar 31 10:26:38 2021 - [info] Reading default configuration from /etc/masterha_default.cnf..
Wed Mar 31 10:26:38 2021 - [info] Reading application default configuration from /etc/app1.cnf..
Wed Mar 31 10:26:38 2021 - [info] Reading server configuration from /etc/app1.cnf..
Wed Mar 31 10:26:38 2021 - [info] Starting SSH connection tests..
Wed Mar 31 10:26:39 2021 - [debug]
Wed Mar 31 10:26:38 2021 - [debug]  Connecting via SSH from root@master(172.16.4.71:22) to root@candidate_master(172.16.4.72:22)..
Wed Mar 31 10:26:38 2021 - [debug]   ok.
Wed Mar 31 10:26:38 2021 - [debug]  Connecting via SSH from root@master(172.16.4.71:22) to root@slave(172.16.4.73:22)..
Wed Mar 31 10:26:38 2021 - [debug]   ok.
Wed Mar 31 10:26:39 2021 - [debug]
Wed Mar 31 10:26:38 2021 - [debug]  Connecting via SSH from root@candidate_master(172.16.4.72:22) to root@master(172.16.4.71:22)..
Wed Mar 31 10:26:39 2021 - [debug]   ok.
Wed Mar 31 10:26:39 2021 - [debug]  Connecting via SSH from root@candidate_master(172.16.4.72:22) to root@slave(172.16.4.73:22)..
Wed Mar 31 10:26:39 2021 - [debug]   ok.
Wed Mar 31 10:26:40 2021 - [debug]
Wed Mar 31 10:26:39 2021 - [debug]  Connecting via SSH from root@slave(172.16.4.73:22) to root@master(172.16.4.71:22)..
Wed Mar 31 10:26:39 2021 - [debug]   ok.
Wed Mar 31 10:26:39 2021 - [debug]  Connecting via SSH from root@slave(172.16.4.73:22) to root@candidate_master(172.16.4.72:22)..
Wed Mar 31 10:26:39 2021 - [debug]   ok.
Wed Mar 31 10:26:40 2021 - [info] All SSH connection tests passed successfully.
[root@centos-vm-4-73 ~]# masterha_check_repl --global-conf=/etc/masterha_default.cnf --conf=/etc/app1.cnf
Wed Mar 31 10:58:43 2021 - [info] Reading default configuration from /etc/masterha_default.cnf..
Wed Mar 31 10:58:43 2021 - [info] Reading application default configuration from /etc/app1.cnf..
Wed Mar 31 10:58:43 2021 - [info] Reading server configuration from /etc/app1.cnf..
Wed Mar 31 10:58:43 2021 - [info] MHA::MasterMonitor version 0.56.
Wed Mar 31 10:58:44 2021 - [info] GTID failover mode = 0
Wed Mar 31 10:58:44 2021 - [info] Dead Servers:
Wed Mar 31 10:58:44 2021 - [info] Alive Servers:
Wed Mar 31 10:58:44 2021 - [info]   master(172.16.4.71:3306)
Wed Mar 31 10:58:44 2021 - [info]   candidate_master(172.16.4.72:3306)
Wed Mar 31 10:58:44 2021 - [info]   slave(172.16.4.73:3306)
Wed Mar 31 10:58:44 2021 - [info] Alive Slaves:
Wed Mar 31 10:58:44 2021 - [info]   candidate_master(172.16.4.72:3306)  Version=5.6.51-log (oldest major version between slaves) log-bin:enabled
Wed Mar 31 10:58:44 2021 - [info]     Replicating from 172.16.4.71(172.16.4.71:3306)
Wed Mar 31 10:58:44 2021 - [info]     Primary candidate for the new Master (candidate_master is set)
Wed Mar 31 10:58:44 2021 - [info]   slave(172.16.4.73:3306)  Version=5.6.51-log (oldest major version between slaves) log-bin:enabled
Wed Mar 31 10:58:44 2021 - [info]     Replicating from 172.16.4.71(172.16.4.71:3306)
Wed Mar 31 10:58:44 2021 - [info]     Not candidate for the new Master (no_master is set)
Wed Mar 31 10:58:44 2021 - [info] Current Alive Master: master(172.16.4.71:3306)
Wed Mar 31 10:58:44 2021 - [info] Checking slave configurations..
Wed Mar 31 10:58:44 2021 - [info]  read_only=1 is not set on slave candidate_master(172.16.4.72:3306).
Wed Mar 31 10:58:44 2021 - [info] Checking replication filtering settings..
Wed Mar 31 10:58:44 2021 - [info]  binlog_do_db= , binlog_ignore_db=
Wed Mar 31 10:58:44 2021 - [info]  Replication filtering check ok.
Wed Mar 31 10:58:44 2021 - [info] GTID (with auto-pos) is not supported
Wed Mar 31 10:58:44 2021 - [info] Starting SSH connection tests..
Wed Mar 31 10:58:47 2021 - [info] All SSH connection tests passed successfully.
Wed Mar 31 10:58:47 2021 - [info] Checking MHA Node version..
Wed Mar 31 10:58:48 2021 - [info]  Version check ok.
Wed Mar 31 10:58:48 2021 - [info] Checking SSH publickey authentication settings on the current master..
Wed Mar 31 10:58:48 2021 - [info] HealthCheck: SSH to master is reachable.
Wed Mar 31 10:58:48 2021 - [info] Master MHA Node version is 0.56.
Wed Mar 31 10:58:48 2021 - [info] Checking recovery script configurations on master(172.16.4.71:3306)..
Wed Mar 31 10:58:48 2021 - [info]   Executing command: save_binary_logs --command=test --start_pos=4 --binlog_dir=/usr/local/mysql/data --output_file=/var/log/masterha/app1/save_binary_logs_test --manager_version=0.56 --start_file=mysql-bin.000004
Wed Mar 31 10:58:48 2021 - [info]   Connecting to root@172.16.4.71(master:22)..
  Creating /var/log/masterha/app1 if not exists..    ok.
  Checking output directory is accessible or not..
   ok.
  Binlog found at /usr/local/mysql/data, up to mysql-bin.000004
Wed Mar 31 10:58:49 2021 - [info] Binlog setting check done.
Wed Mar 31 10:58:49 2021 - [info] Checking SSH publickey authentication and checking recovery script configurations on all alive slave servers..
Wed Mar 31 10:58:49 2021 - [info]   Executing command : apply_diff_relay_logs --command=test --slave_user='manager' --slave_host=candidate_master --slave_ip=172.16.4.72 --slave_port=3306 --workdir=/var/log/masterha/app1 --target_version=5.6.51-log --manager_version=0.56 --relay_log_info=/usr/local/mysql/data/relay-log.info  --relay_dir=/usr/local/mysql/data/  --slave_pass=xxx
Wed Mar 31 10:58:49 2021 - [info]   Connecting to root@172.16.4.72(candidate_master:22)..
  Checking slave recovery environment settings..
    Opening /usr/local/mysql/data/relay-log.info ... ok.
    Relay log found at /usr/local/mysql/data, up to relay-bin.000006
    Temporary relay log file is /usr/local/mysql/data/relay-bin.000006
    Testing mysql connection and privileges..Warning: Using a password on the command line interface can be insecure.
 done.
    Testing mysqlbinlog output.. done.
    Cleaning up test file(s).. done.
Wed Mar 31 10:58:49 2021 - [info]   Executing command : apply_diff_relay_logs --command=test --slave_user='manager' --slave_host=slave --slave_ip=172.16.4.73 --slave_port=3306 --workdir=/var/log/masterha/app1 --target_version=5.6.51-log --manager_version=0.56 --relay_log_info=/usr/local/mysql/data/relay-log.info  --relay_dir=/usr/local/mysql/data/  --slave_pass=xxx
Wed Mar 31 10:58:49 2021 - [info]   Connecting to root@172.16.4.73(slave:22)..
  Checking slave recovery environment settings..
    Opening /usr/local/mysql/data/relay-log.info ... ok.
    Relay log found at /usr/local/mysql/data, up to relay-bin.000005
    Temporary relay log file is /usr/local/mysql/data/relay-bin.000005
    Testing mysql connection and privileges..Warning: Using a password on the command line interface can be insecure.
 done.
    Testing mysqlbinlog output.. done.
    Cleaning up test file(s).. done.
Wed Mar 31 10:58:49 2021 - [info] Slaves settings check done.
Wed Mar 31 10:58:49 2021 - [info]
master(172.16.4.71:3306) (current master)
 +--candidate_master(172.16.4.72:3306)
 +--slave(172.16.4.73:3306)

Wed Mar 31 10:58:49 2021 - [info] Checking replication health on candidate_master..
Wed Mar 31 10:58:49 2021 - [info]  ok.
Wed Mar 31 10:58:49 2021 - [info] Checking replication health on slave..
Wed Mar 31 10:58:49 2021 - [info]  ok.
Wed Mar 31 10:58:49 2021 - [info] Checking master_ip_failover_script status:
Wed Mar 31 10:58:49 2021 - [info]   /usr/local/masterha/scripts/master_ip_failover --command=status --ssh_user=root --orig_master_host=master --orig_master_ip=172.16.4.71 --orig_master_port=3306
Wed Mar 31 10:58:49 2021 - [info]  OK.
Wed Mar 31 10:58:49 2021 - [warning] shutdown_script is not defined.
Wed Mar 31 10:58:49 2021 - [info] Got exit code 0 (Not master dead).

MySQL Replication Health is OK.
```

6. 启动MHA

master节点增加VIP

```shell
ip addr add 172.16.4.70/24 dev eth0
```
slave节点启动

```
nohup masterha_manager --conf=/etc/app1.cnf  \
  --remove_dead_master_conf  --ignore_last_failover < /dev/null >  \
  /var/log/masterha/app1/manager.log 2>&1 &
```
---
### 4. 故障测试

现在`master`节点故障，`mha-manager`自动检测不到原`master`节点，触发故障转移，现在将`candidate master`节点提升`CHANGE MASTER`,并将其他`SLAVE`节点指向该节点，并在目录`/usr/local/masterha/app1`生成文件`app1.failover.complete`，同时将`maser`节点的字段从`app1.conf`配置移除。

---
### 5. 故障恢复

1. 修复`172.16.4.71`节点，启动数据库。
2. 将`172.16.4.71`节点提升为`slave`节点。
3. 将`172.16.4.71`配置加回`app1.conf`中。

---
### 6. 手动故障

```shell
masterha_master_switch --master_state=dead --conf=/etc/app1.cnf \
--dead_master_host=172.16.4.71 --dead_master_port=3306  \
--new_master_host=172.16.4.72 --new_master_port=3306 --ignore_last_failover
```
---

### 7. 在线切换

```shell
masterha_master_switch --conf=/etc/app1.cnf \
--master_state=alive --new_master_host=172.16.4.72 \
--orig_master_is_new_slave \
--running_updates_limit=10000 --interactive=0
```
