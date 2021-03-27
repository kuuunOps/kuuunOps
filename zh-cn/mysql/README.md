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
数据库初始化，创建系统自带的数据库和表
```shell
cd /usr/local/mysql
./scripts/mysql_install_db \
--basedir=/usr/local/mysql \
--datadir=/usr/local/mysql/data \
--user=mysql
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
-- grant 权限 on 数据库.表 to 用户名@主机IP identified by '密码';
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

- 修改`vm.swappiness`参数，降低swap使用率。RHEL7/centos7以上则慎重设置为0，可能发生OOM
- 调整`vm.dirty_background_ratio`、`vm.dirty_ratio`内核参数，以确保能持续将脏数据刷新到磁盘，避免瞬间I/O写。产生等待。
- 调整`net.ipv4.tcp_tw_recycle`、`net.ipv4.tcp_tw_reuse`都设置为1，减少TIME_WAIT，提高TCP效率。

5. MySQL调优

| 参数                                                                                                         | 说明                                                                           |
| ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| default-storage-engine                                                                                       | 设置为InnoDB，强烈建议不要再使用MyISAM引擎                                     |
| innodb_buffer_pool_size                                                                                      | 如果是单实例且绝大多数是InnoDB引擎表的话，可考虑设置为物理内存的50% -70%左右。 |
| innodb_file_per_tabl                                                                                         | 设置为 1 ，使用独立表空间。                                                    |
| innodb_data_file_path = ibdata1:1G:autoextend                                                                | 不要用默认的10M,在高并发场景下，性能会有很大提升。                             |
| innodb_log_file_size=256M，innodb_log_files_in_group=2                                                       | 基本可以满足大多数应用场景。                                                   |
| open_files_limit、innodb_open_files、table_open_cache、table_definition_cache                                | 设置大约为max_connection的10倍左右大小。                                       |
| key_buffer_size                                                                                              | 32M左右即可                                                                    |
| query cache                                                                                                  | 建议关闭                                                                       |
| mp_table_size,max_heap_table_size,sort_buffer_size、join_buffer_size、read_buffer_size、read_rnd_buffer_size | 设置不要过大                                                                   |














