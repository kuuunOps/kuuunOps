# Mongodb

## 安装

### 1. 下载
```bash
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.6.2.tgz
```

### 2. 解压
```bash
tar xf mongodb-linux-x86_64-3.6.2.tgz
mv mongodb-linux-x86_64-3.6.2 mongodb
```

### 3. 环境配置
```bash
export MONGODB=/usr/local/mongodb/
export PATH=$PATH:$MONGODB/bin
```

### 4. 创建相关目录
```bash
mkdir conf
mkdir -p data/db
mkdir logs
```

### 5. 参考配置
```bash
vi mongodb.conf

#数据文件存放目录  
dbpath = /usr/local/mongodb/data/db 
#日志文件存放目录  
logpath = /usr/local/mongodb/logs/mongodb.log
logappend = true

# 绑定的ip 默认localhost
bind_ip = 127.0.0.1,192.168.1.14
#端口 
port = 27017  
#以守护程序的方式启用，即在后台运行  
fork = true
```

### 6. 启动
```bash
mongod -f conf/mongodb.conf
```