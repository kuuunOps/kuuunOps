# Linux

## OpenSSH关闭CBC加密模块

1. 编辑`/etc/ssh/sshd_config`
```bash
# 添加如下内容
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com
```

2. 重启服务
```bash
systemctl restart sshd
```

---


## OpenSSH

### 版本升级

#### 1. 安装软件包
```bash
yum install gcc pam-devel zlib-devel
```

#### 2. 启用Telnet

- 安装telnet软件包
```bash
yum -y install telnet-server* telnet
```

- 修改配置
```bash
vim /etc/xinetd.d/telnet
# disable = yes 修改为： disable = no
```
- 启动服务
```bash
/etc/init.d/xinetd  start
chkconfig xinetd on
```

- 防火墙开通23端口
```bash
# 测试端口是否开通
telnet xxx.xxx.xxx.xxx 23
```
#### 3. 安装OpenSSL

1. 编译
```bash
./config enable-shared zlib
make && make install
```

2. 配置
```bash
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
ldconfig -v
ln -s /usr/lib64/libssl.so.1.0.0  libssl.so.10
ln -s /usr/lib64/libcrypto.so.1.0.0  libcrypto.so.10
```

3. 版本确认
```bash
openssl version -a
```

#### 4. 安装OpenSSH

1. 查看当前环境已经安装的OpenSSH包

```bash
rpm -qa | grep openssh
openssh-server-5.3p1-117.el6.x86_64
openssh-clients-5.3p1-117.el6.x86_64
openssh-5.3p1-117.el6.x86_64
```

2. 卸载

```bash
rpm -e --nodeps openssh-server-5.3p1-117.el6.x86_64
rpm -e --nodeps openssh-clients-5.3p1-117.el6.x86_64
rpm -e --nodeps openssh-5.3p1-117.el6.x86_64
```

3. 编译

```bash
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-pam --with-zlib --with-ssl-dir=/usr/local/ssl --with-openssl-includes=/usr/include/openssl --with-privsep-path=/var/lib/sshd
make && make install
```

4. 配置

```bash
install -v -m755    contrib/ssh-copy-id /usr/bin
install -v -m644    contrib/ssh-copy-id.1 /usr/share/man/man1
install -v -m755 -d /usr/share/doc/openssh-7.6p1
install -v -m644    INSTALL LICENCE OVERVIEW README* /usr/share/doc/openssh-7.6p1
```

5. 版本确认

```bash
ssh -V
```

6. 配置新的OpenSSH服务

```bash
vim /etc/ssh/sshd.conf
X11Forwarding no  修改为 X11Forwarding yes
UseDNS no        修改为 UseDNS yes
PermitRootLogin prohibit-password        修改为    PermitRootLogin yes
cp -p contrib/redHat/sshd.init /etc/init.d/sshd
chmod +x /etc/init.d/sshd
chkconfig  --add  sshd
chkconfig  sshd  on
chkconfig  --list  sshd
service sshd restart
```

7. 配置PAM

```bash
vi /etc/pam.d/sshd
#%PAM-1.0
auth       required     pam_sepermit.so
auth       include      password-auth
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
```

---

## Memcahced.sh启动脚本参考

```bash
#!/bin/bash
# author:zhanghk
# date:2017-05-30
# description: Starts and stops the Memcached services.
# pidfile: /tmp/memcached1.pid
# config:  /usr/local/memcached
# chkconfig: - 55 45
# source function library
. /etc/rc.d/init.d/functions
memcached="/usr/local/memcached/bin/memcached"
[ -e $memcached ] || exit 1

start(){
echo "Starting memcached:"daemon $memcached -d -m 1000 -u root -l 0.0.0.0 -p 11211 -c 1500 -P /tmp/memcached.pid
}
stop(){
echo "Shutting down memcached"killproc memcached
}
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 3
        start
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac
exit $?
```

---

## java内存溢出分析

1. 常见内存溢出相关的错误

>年老代堆空间被占满 

异常： `java.lang.OutOfMemoryError: Java heap space`

>持久代被占满

异常：`java.lang.OutOfMemoryError: PermGen space`

>堆栈溢出

异常：`java.lang.StackOverflowError`

>线程堆栈满

异常：`Fatal: Stack size too small`

>系统内存被占满

异常：`java.lang.OutOfMemoryError: unable to create new native thread`

2. 导出命令

```bash
jmap -dump:format=b,file=jetty_$(date +%Y%m%d).hprof 23151
```


---

## java占用CPU过高

1. 查看线程

```bash
ps -mp 22338 -o THREAD,tid,time
```

2. 导出线程文件

```bash
jstack 28259 > /tmp/28259.log
```

3. 转换成16进制

```bash
echo "obase=16;29940"|bc
```

---

## iptables快速使用

1. 开放一个端口

```bash
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
```

2. 开放多个端口

>多个不连续

```bash
iptables -I INPUT -p tcp -m multiport --dport 80,443 -j ACCEPT
```

>多个连续

```bash
iptables -I INPUT -p tcp -m multiport --dport 10000:10020 -j ACCEPT
```

3. 限制请求来源地址进行开放

```bash
iptables -I INPUT -s 172.16.0.0/16 -p tcp --dport 22 -j ACCEPT
```
----
## 设置时区

- 查看当前所有的时区清单列表
```
timedatectl list-timezones
```

- 设置时区
```bash
timedatectl set-timezone Asia/Shanghai
```
---
## XFS文件系统磁盘，扩容方案

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




## 配置JDK

1. 配置全局

>解压

```bash
tar xf jdk-7u79-linux-x64.gz
mv jdk1.7.0_79/ /usr/local/
ln -s /usr/local/jdk1.7.0_79/  /usr/local/jdk
```

>配置

```bash
cat > /etc/profile.d/jdk.sh << EOF
#!/bin/bash
export JAVA_HOME=/usr/local/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
EOF
ln -sf /usr/local/jdk/bin/* /usr/bin/
ln -sf /usr/local/jdk/jre/bin/* /usr/bin/
```
>重载

```bash
source /etc/profile
```

1. 配置项目级

>创建项目级管理用户

```
useradd -d  /home/path/ ProjectName
```

>解压

```bash
tar xf jdk-7u79-linux-x64.gz
mv jdk1.7.0_79/ /home/path/
ln -s /home/path/jdk1.7.0_79/  /home/path/jdk
```

>配置

```bash
cat >>.bash_profile <<EOF
export JAVA_HOME=$HOME/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
EOF
```

>重载

```bash
source .bash_profile
```
---

## CentOS 7 网卡名称设置

1. 查看当前网卡名称

```shell
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens32: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:05:38:f0 brd ff:ff:ff:ff:ff:ff
    inet 172.20.1.12/24 brd 172.20.1.255 scope global noprefixroute dynamic ens32
       valid_lft 1642sec preferred_lft 1642sec
    inet6 fe80::7bc7:a6a6:e335:d648/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

2. 修改网卡配置文件

>编辑网卡配置文件`/etc/sysconfig/network-scripts/ifcfg-ens32`。`DEVICE=ens32`更改为`DEVICE=eth0`,`NAME=ens32`更改为`NAME=eth0`。

```shell
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens32
UUID=45f3941e-9b19-4137-903f-215d354e296b
DEVICE=ens32
ONBOOT=yes
```

3. 网卡配置文件重命名

```shell
[root@localhost ~]# cd /etc/sysconfig/network-scripts/
[root@localhost network-scripts]# mv ifcfg-ens32 ifcfg-eth0
```

4. 编辑grub配置文件

>在`GRUB_CMDLINE_LINUX`中增加参数`net.ifnames=0 biosdevname=0`

```shell
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 spectre_v2=retpoline rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
```
5. 重新生成GRUB配置文件更新内核

```shell
[root@localhost network-scripts]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-1062.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-1062.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-31ca872114104abd9f8dd69164b5e0dc
Found initrd image: /boot/initramfs-0-rescue-31ca872114104abd9f8dd69164b5e0dc.img
done
```

6. 重启服务器

>验证网卡信息

```shell
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:05:38:f0 brd ff:ff:ff:ff:ff:ff
    inet 172.20.1.12/24 brd 172.20.1.255 scope global noprefixroute dynamic eth0
       valid_lft 1788sec preferred_lft 1788sec
    inet6 fe80::7264:bb88:a9ed:9155/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

