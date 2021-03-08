# Ansible

## Ansible概述及安装

### 概述

### 安装

| 主机        | 操作系统     | 软件                         | 描述     |
| ----------- | ------------ | ---------------------------- | -------- |
| 172.16.4.61 | CentOS 7.8   | ansible，openssh（系统自带） | 管理节点 |
| 172.16.4.62 | CentOS 7.8   | openssh（系统自带）          | 工作节点 |
| 172.16.4.63 | Ubuntu 18.04 | openssh（系统自带）          | 工作节点 |

#### CentOS
```shell
yum install ansible -y
```

#### Ubuntu
```shell
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```


---

## Ansible入门

### SSH连接

**生成RSA秘钥**
```shell
ssh-keygen -t rsa
```

**分发秘钥**

1. 172.16.4.62
```shell
cd ~
ssh-copy-id -i .ssh/id_rsa root@172.16.4.62
```

2. 172.16.4.63
```shell
cd ~
ssh-copy-id -i .ssh/id_rsa ubuntu@172.16.4.63
```

### Ansible配置

**ansible配置文件查找顺序**

1. ` ANSIBLE_CONFIG ` （如果有设置环境变量）
2. ` ansible.cfg ` （在当前目录查找）
3. ` ~/.ansible.cfg ` （在用户家目录）
4. ` ~/.ansible.cfg `

**资源管理**

修改` /etc/ansible/hosts `
```shell
[centos]
172.16.4.62

[ubuntu]
172.16.4.63
```

