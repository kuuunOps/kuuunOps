# Ansible

[官方文档](https://docs.ansible.com)
## Ansible安装与配置

### 一、安装

| 主机        | 操作系统     | 软件                         | 描述       |
| ----------- | ------------ | ---------------------------- | ---------- |
| 172.16.4.61 | CentOS 7.8   | ansible，openssh（系统自带） | 控制节点   |
| 172.16.4.62 | CentOS 7.8   | openssh（系统自带）          | 被管理节点 |
| 172.16.4.63 | Ubuntu 18.04 | openssh（系统自带）          | 被管理节点 |

1. CentOS
```shell
yum install ansible -y
```

2. Ubuntu
```shell
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

### 二、配置

ansible按以下顺序查找配置，优先级从高到低为：

1. ` ANSIBLE_CONFIG ` （如果有设置环境变量）
2. ` ansible.cfg ` （在当前目录查找）
3. ` ~/.ansible.cfg ` （在用户家目录）
4. ` ~/.ansible.cfg `

**注释**

可以使用` # `和` ; `进行注释标记，行内语句只能使用` ; `注释

示例：
```cfg
# 一些基础默认值
inventory = /etc/ansible/hosts  ; 这里列出主机清单
```

---

## Ansible概念

- **控制节点（Control node）**

任何安装了Ansible的主机。

- **被管理节点（Managed nodes）**

使用Ansible需要管理的网络设备或服务器。

- **资产清单（Inventory）**

被管理的主机列表

- **模块（Modules）**

执行Ansible命令的各种组件模块

- **任务（Tasks）**

在Ansible中的独立的工作任务

- **剧本（Playbooks）**

包含任务的有序列表，可以方便重复运行这些任务。

---
## Ansible入门

### 配置主机清单

创建或修改` /etc/ansible/hosts `，一般使用IP地址或域名解析
```shell
172.16.4.62
172.16.4.63
```
或者使用分组，别名的形式

**分组**

配置文件
   
```shell
[centos]
172.16.4.62

[ubuntu]
172.16.4.63
```

**默认组**

- all：包含所有主机
- ungrouped：没有在分组内的其他所有主机

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

**资源管理**

修改` /etc/ansible/hosts `
```shell
[centos]
172.16.4.62

[ubuntu]
172.16.4.63
```
## 第一个Ansible命令

- `-u`：在命令行中指定连接的用户名称

使用默认用户` root `连接
```shell
ansible all -m ping
172.16.4.63 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Permission denied (publickey,password).",
    "unreachable": true
}
172.16.4.62 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

主机` 172.16.4.62 `执行成功，` 172.16.4.63 `执行失败，因为` 172.16.4.63 `主机使用的是用户` ubuntu `。

1. 解决方案1:

```shell
ansible ubuntu -u ubuntu -m ping
172.16.4.63 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

2. 解决方案2：

在主机清单中配置
```shell
[ubuntu]
172.16.4.63 ansible_user=ubuntu
```
再执行
```shell
 ansible all -m ping
172.16.4.62 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
172.16.4.63 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

再执行一个命令

```shell
 ansible all -a "echo hello"
172.16.4.63 | CHANGED | rc=0 >>
hello
172.16.4.62 | CHANGED | rc=0 >>
hello
```

---

## Ansible命令行工具

- ` ansible `
  一般用于执行远程操作的简单工具。

- ` ansible-config `
  配置的命令行

- ` ansible-console `
  一个交互式工具

- ` ansible-doc `
  模块的帮助文档，显示插件列表及其描述

- ` ansible-inventory `
  用于显示Ansible已配置的主机清单

- ` ansible-playbook `
  运行`Ansible Playbook`的工具

- ` ansible-pull `
  从VCS仓库中提取剧本到本地主机上执行

---
## Playbooks

> 剧本是Ansible的配置，部署和编排语言。它们可以描述您希望远程系统执行的策略，或一般IT流程中的一组步骤。
### 示例

Playbooks使用YAML格式表示内容。每一个剧本有一个列表中的一个或多个剧本组成。

```yaml
---
- hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum:
      name: httpd
      state: latest
  - name: write the apache config file
    template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf
    notify:
    - restart apache
  - name: ensure apache is running
    service:
      name: httpd
      state: started
  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
```

### 剧本基础

#### 主机与用户
```yaml
---
- hosts: webservers
  remote_user: root
```
可以为每个任务，定义不同的远程用户
```yaml
---
- hosts: webservers
  remote_user: root
  tasks:
    - name: test connection
      ping:
      remote_user: yourname
```
用户SUDO提取操作
```yaml
---
- hosts: webservers
  remote_user: yourname
  become: yes
```
可以针对特定任务进行提取操作
```yaml
---
- hosts: webservers
  remote_user: yourname
  tasks:
    - service:
        name: nginx
        state: started
      become: yes
      become_method: sudo
```
以其他非root用户操作
```yaml
---
- hosts: webservers
  remote_user: yourname
  become: yes
  become_user: postgres
```
切换到其他用户
```yaml
---
- hosts: webservers
  remote_user: yourname
  become: yes
  become_method: su
```

#### 任务清单

每个剧本都包含任务列表。运行从上到下运行的剧本时，任务失败的主机将从整个剧本的轮换中删除。如果失败，只需更正剧本文件并重新运行即可。
每个任务都应该有一个` name `，该字符包含在运行剧本的输出中。

**示例**
```yaml
tasks:
  - name: make sure apache is running
    service:
      name: httpd
      state: started
```

#### 处理程序：在更改时运行操作

正如我们已经提到的，模块应该是幂等的，并且可以在远程系统上进行更改时进行中继。剧本认识到这一点，并具有可用于响应变化的基本事件系统。

这些“通知”动作是在播放中每个任务块的结尾处触发的，即使被多个不同的任务通知，也只会触发一次。

例如，多个资源可能指示apache需要重新启动，因为它们已经更改了配置文件，但是apache只会被退回一次以避免不必要的重新启动。

这是一个在文件内容更改时（但仅在文件更改时）重新启动两个服务的示例：

```yaml
- name: template configuration file
  template:
    src: template.j2
    dest: /etc/foo.conf
  notify:
     - restart memcached
     - restart apache
```
` notify `任务部分中列出的内容称为处理程序。

处理程序是任务列表，实际上与常规任务没有什么不同，它们由全局唯一名称引用，并由通知者通知。如果没有任何通知处理程序，它将不会运行。无论有多少个任务通知处理程序，在特定任务中完成所有任务后，该处理程序将仅运行一次。

```yaml
handlers:
    - name: restart memcached
      service:
        name: memcached
        state: restarted
    - name: restart apache
      service:
        name: apache
        state: restarted
```

