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

## MySQL双主配置

- 1. 配置主从模式
- 2. 在从节点开启bin_log等其他相关参数，重启从库。
- 3. 开始正常配置主从。

---

## MySQL实现双主高可用

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
