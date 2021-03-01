# Ubuntu


## 修改网卡名称

**1. 修改grub配置**
```bash
sudo vim /etc/default/grub
...
# GRUB_CMDLINE_LINUX="" 
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
...
```

**2. 生成grub文件**
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**3. 修改网卡配置**
```bash
sudo vim /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
    eth0:
      addresses:
      - 172.16.4.17/24
      gateway4: 172.16.4.254
      nameservers:
        addresses:
        - 172.16.1.2
        search:
        - 172.16.1.3
  version: 2
```

---

## NFS服务

### 服务端配置

**1. 安装软件**
```bash
sudo apt install nfs-kernel-server
```

**2. 创建共享目录**
```bash
sudo mkdir -p /data/project/nfs
```

**3. 编辑配置**
```bash
sudo vim /etc/exports
/data/project/nfs *(rw,sync,no_subtree_check,no_root_squash)
```

**4. 重启服务**
```bash
sudo systemctl restart nfs-kernel-server 
```

**5. 常用命令**
```bash
# 查看挂载信息
sudo showmount -e localhost

# 重载配置
sudo exportfs -rv

# 查看nfs的运行状态
sudo nfsstat

# 查看rpc运行情况
sudo rpcinfo

# 查看端口
sudo ss -lntp|grep 111
```

### 客户端

**1. 安装软件包**
```bash
sudo apt install nfs-common
```

**2. 查看服务端共享信息**
```bash
sudo showmount -e 172.16.4.18
```

**3. 挂载NFS**

- 创建本地挂载目录
```bash
sudo mkdir -p /data/project/nfs
```

- 挂载命令
```bash
sudo mount -t nfs 172.16.4.18:/data/project/nfs /data/project/nfs
```

---

## 时间同步

**1. 设置时区**
```bash
sudo timedatectl set-timezone "Asia/Shanghai"
```

**2. 配置时间服务器**

- 安装软件包
```bash
sudo apt install ntp
```

- 修改配置
```bash
sudo vim /etc/ntp.conf
driftfile  /var/lib/ntp/drift
pidfile   /var/run/ntpd.pid
logfile /var/log/ntp.log
restrict    default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
server 127.127.1.0
fudge  127.127.1.0 stratum 10
server ntp.aliyun.com iburst minpoll 4 maxpoll 10
restrict ntp.aliyun.com nomodify notrap nopeer noquery
```

---


## 文件描述符推荐设置
```bash
sudo vim /etc/security/limits.conf
* soft nofile 100001
* hard nofile 100002
root soft nofile 100001
root hard nofile 100002
```

---

## 安装中文字体

**1. 安装字体管理命令**
```bash
sudo apt install -y  fontconfig
```

**2. 创建字体目录**
```bash
sudo mkdir -p /usr/share/fonts/chinese
```

**3. 上传字体到目录中**

**4. 刷新字体缓存**
```bash
sudo fc-cache
sudo fc-list
```
---