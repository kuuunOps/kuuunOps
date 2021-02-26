# PostgresSQL

### 一、登录
```bash
$ psql (连接数据库，默认用户和数据库都是postgres)
$ psql -U <user> -d <dbname> 
```

### 二、数据库常见操作
```sql
-- 列举数据库，相当于show databases
$ \l

-- 切换数据库，相当与use dbname
$ \c <dbname>

-- 列举表，相当与show tables
$ \dt

-- 查看表结构，相当于desc
$ \d tblname

-- 创建数据库
$ create database <dbname>

-- 删除数据库
$ drop database <dbname>

-- 创建表
$ create table ([字段名1] [类型1] ;,[字段名2] [类型2],......<,primary key (字段名m,字段名n,...)>;); 

-- 在表中插入数据
$ insert into 表名 ([字段名m],[字段名n],......) values ([列m的值],[列n的值],......);

-- 备份数据库
$ pg_dump -U postgres -f /tmp/postgres.sql postgres (导出postgres数据库保存为postgres.sql)
$ pg_dump -U postgres -f /tmp/postgres.sql -t test01 postgres (导出postgres数据库中表test01的数据)
$ pg_dump -U postgres -F t -f /tmp/postgres.tar postgres (导出postgres数据库以tar形式压缩保存为postgres.tar)

-- 恢复数据库
$ psql -U postgres -f /tmp/postgres.sql bk01 (恢复postgres.sql数据到bk01数据库)
$ pg_restore -U postgres -d bk01 /tmp/postgres.tar  (恢复postgres.tar数据到bk01数据库)
```

#### 三、用户操作
```sql
-- 切换用户
$ \c - <username>

-- 创建用户并设置密码
$ CREATE USER 'username' WITH PASSWORD 'password';
$ CREATE ROLE 'username' CREATEDB PASSWORD 'password' LOGIN; (创建角色并授予创建数据库及密码登录的属性)

-- 修改用户密码
$ ALTER USER 'username' WITH PASSWORD 'password';

-- 数据库授权
$ GRANT ALL PRIVILEGES ON DATABASE 'dbname' TO 'username';

-- 修改用户权限
$ ALTER ROLE 'username' createdb ; (授予创建数据库权限)
$ ALTER ROLE 'username' superuser ;(授予超级管理员权限)
```


### 四、角色属性

| 属性        | 说明                                                                                  |
| ----------- | :------------------------------------------------------------------------------------ |
| login       | 只有具有 LOGIN 属性的角色可以用做数据库连接的初始角色名。                             |
| superuser   | 数据库超级用户                                                                        |
| createdb    | 创建数据库权限                                                                        |
| createrole  | 允许其创建或删除其他普通的用户角色(超级用户除外)                                      |
| replication | 做流复制的时候用到的一个用户属性，一般单独设定。                                      |
| password    | 在登录时要求指定密码时才会起作用，比如md5或者password模式，跟客户端的连接认证方式有关 |
| inherit     | 用户组对组员的一个继承标志，成员可以继承用户组的权限特性                              |