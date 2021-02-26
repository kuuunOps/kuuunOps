# RabbitMQ

> 基于CentOS 7
## 安装RabbitMQ

### 1. 添加erlang语言镜像地址
```bash
vi /etc/yum.repos.d/erlang-solutions.repo
[erlang-solutions]
name=CentOS $releasever - $basearch - Erlang Solutions
baseurl=http://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch
gpgcheck=1
gpgkey=http://packages.erlang-solutions.com/rpm/erlang_solutions.asc
enabled=1
```

### 2. 刷新镜像地址
```bash
yum clean all
yum makecache
```

### 3. 安装erlang
```bash
yum install erlang
```

### 4. 添加rabbitmq镜像地址
```bash
vi /etc/yum.repos.d/rabbitmq.repo
[bintray-rabbitmq-server]
name=bintray-rabbitmq-rpm
baseurl=http://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/v3.7.x/el/7/
gpgcheck=0
repo_gpgcheck=0
enabled=1
```

### 5. 安装Rabbitmq
```bash
yum install rabbitmq-server
```

### 6. 启动RabbitMQ
```
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
```

### 7. 其他设置
```bash
# 启用插件
rabbitmq-plugins enable rabbitmq_management

# 重启服务
systemctl restart rabbitmq-server restart

# 添加帐号:admin 密码:admin
rabbitmqctl add_user admin admin

# 赋予其administrator角色
rabbitmqctl set_user_tags admin administrator

# 设置权限 
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
```