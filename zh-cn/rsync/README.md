# Rsync

## Rsync守护进程方式启动，配置方式

### 1. Rsync服务端配置
```bash
vim /etc/rsyncd.conf
#指定守护进程UID
uid = root（或者rsync）
#指定守护进程GID
gid = root（或者rsync）

user chroot = no
#最大客户端连接数
max connections = 500
#连接超时的时间
timeout = 300
#指定PID文件
pid file = /var/run/rsync.pid
#指定lock文件
lock file = /var/run/rsync.lock
#指定日志文件
log file = /var/run/rsync.log

#定义模块名字
[www]
#指定目录路径
path = /data/www/
#是否忽略错误
ignore errors
#是否只读
read only = false
#是否列出文件列表
list = false
#允许主机列表
hosts allow = 10.0.0.0/24
#禁止主机列表
hosts deny = 0.0.0.0/24
#指定认证用户名字
auth users = www
#指定认证用户密码保存文件
secrets file = /etc/rsync.password
```
### 2. 创建虚拟用户
```bash
useradd -s /sbin/nolgoin rsync -M
```
### 3. 授权文件权限
```bash
chown -R rsync.rsync /data/www/
```

### 4. 创建密码文件
```bash
echo "www:password">/etc/rsync.password
```

### 5. 密码文件权限更改
```bash
chmod 600 /etc/rsync.password
```

## 二、rsync客户端设置

### 1. 创建密码文件，这里只要密码
```bash
echo "password">/etc/rsync.password
```

### 2. 密码文件权限更改
```bash
chmod 600 /etc/rsync.password
```

## 三、使用方法

### 1. 方法一：

- 从服务端拉取文件到本地
```bash
rsync -avz www@192.168.10.55::www /data/bakup/ --password-file=/etc/rsync.password
```

- 从本地向服务端推送文件
```bash
rsync -avz  /data/bakup/ www@192.168.10.55::www --password-file=/etc/rsync.password
```

### 2. 方法二：

- 以协议方式拉取
```bash
rsync -avz rsync://www@192.168.10.55/www /data/bakup/ --password-file=/etc/rsync.password
```

- 以协议方式拉取
```bash
sync -avz /data/bakup/ rsync://www@192.168.10.55/www --password-file=/etc/rsync.password
```