# Linux


### iptables快速使用

1. 开放一个端口
```bash
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
```

2. 开放多个端口

- 多个不连续
```bash
iptables -I INPUT -p tcp -m multiport --dport 80,443 -j ACCEPT
```

- 多个连续
```bash
iptables -I INPUT -p tcp -m multiport --dport 10000:10020 -j ACCEPT
```

3. 限制请求来源地址进行开放
```bash
iptables -I INPUT -s 172.16.0.0/16 -p tcp --dport 22 -j ACCEPT
```


### 设置时区

- 查看当前所有的时区清单列表
```
timedatectl list-timezones
```

- 设置时区
```bash
timedatectl set-timezone Asia/Shanghai
```

### XFS文件系统磁盘，扩容方案

1. 卸载磁盘挂载点
```bash
umount   /data
```

2. 使用fdisk或parted重新建立新分区
```bash
# 删除原有分区
rm 1
# 创建新的分区
mkpart primary 0 4398GB
```

3. 将磁盘分区挂载回去
```bash
mount -a
```

4. 开始扩容
```bash
xfs_growfs /dev/sdb1
```




### 配置JDK

#### 1. 配置全局

- 解压
```bash
tar xf jdk-7u79-linux-x64.gz
mv jdk1.7.0_79/ /usr/local/
ln -s /usr/local/jdk1.7.0_79/  /usr/local/jdk
```

- 配置
```bash
vim /etc/profile
export JAVA_HOME=/usr/local/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
```

- 重载
```bash
source /etc/profile
```

#### 2. 配置项目级

- 解压
```bash
tar xf jdk-7u79-linux-x64.gz
mv jdk1.7.0_79/ /project/path/
ln -s /project/path/jdk1.7.0_79/  /project/path/jdk
```

- 创建项目级管理用户
```
useradd -d  /project/path/ ProjectName
```

- 配置
```bash
vi .bash_profile
export JAVA_HOME=$HOME/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
```

- 重载
```bash
source .bash_profile
```