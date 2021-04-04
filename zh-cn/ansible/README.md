# Ansible

## Ansible安装方式

- PIP

```shell
pip install ansible
```

- CentOS

```shell
yum install epel -y
yum install ansible -y
```

- Ubuntu

```shell
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
```
---

## Ansible的ping模块小试

- `all`：资产选择器
- `-i`：指定资产
- `-m`：指定模块名称

```shell
[root@centos-vm-4-71 ~]# ansible all -i 172.16.4.72,172.16.4.73 -m ping
172.16.4.73 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
172.16.4.72 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

---

## Ansible的copy模块小试

- `-a`：模块参数

```shell
[root@centos-vm-4-71 ~]# ansible all -i 172.16.4.72,172.16.4.73 -m copy -a "src=/tmp/a.txt dest=/tmp/a.txt"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "dest": "/tmp/a.txt",
    "gid": 0,
    "group": "root",
    "md5sum": "d41d8cd98f00b204e9800998ecf8427e",
    "mode": "0644",
    "owner": "root",
    "size": 0,
    "src": "/root/.ansible/tmp/ansible-tmp-1617114919.34-42810-178936183927220/source",
    "state": "file",
    "uid": 0
}
172.16.4.73 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "dest": "/tmp/a.txt",
    "gid": 0,
    "group": "root",
    "md5sum": "d41d8cd98f00b204e9800998ecf8427e",
    "mode": "0644",
    "owner": "root",
    "size": 0,
    "src": "/root/.ansible/tmp/ansible-tmp-1617114919.36-42812-63404287625541/source",
    "state": "file",
    "uid": 0
}
```

---

## Ansible资产自定义

```shell
[root@centos-vm-4-71 ~]# cat inventory
172.16.4.71

[db_server]
172.16.4.72
172.16.4.73
[root@centos-vm-4-71 ~]# ansible all -i inventory --list-hosts
  hosts (3):
    172.16.4.71
    172.16.4.72
    172.16.4.73
[root@centos-vm-4-71 ~]# ansible db_server -i inventory --list-hosts
  hosts (2):
    172.16.4.72
    172.16.4.73
```

---

## Ansible模块

```shell
[root@centos-vm-4-71 ~]# ansible-doc -l|wc -l
3387
[root@centos-vm-4-71 ~]# ansible-doc copy
> COPY    (/usr/lib/python2.7/site-packages/ansible/modules/files/copy.py)

        The `copy' module copies a file from the local or remote machine to a location on the remote
        machine. Use the [fetch] module to copy files from remote locations to the local box. If you need
        variable interpolation in copied files, use the [template] module. Using a variable in the `content'
        field will result in unpredictable output. For Windows targets, use the [win_copy] module instead.

  * This module is maintained by The Ansible Core Team
  * note: This module has a corresponding action plugin.

OPTIONS (= is mandatory):

- attributes
        The attributes the resulting file or directory should have.
        To get supported flags look at the man page for `chattr' on the target system.
        This string should contain the attributes in the same order as the one displayed by `lsattr'.
        The `=' operator is assumed as default, otherwise `+' or `-' operators need to be included in the
        string.
        (Aliases: attr)[Default: (null)]
        type: str
        version_added: 2.3

- backup
        Create a backup file including the timestamp information so you can get the original file back if
        you somehow clobbered it incorrectly.
        [Default: False]
        type: bool
        version_added: 0.7
... ...
```

----

## Ansible模块-command

- `shell`：可以执行shell的内置命令和特性。
- `command`：无法执行shell的内置命令和特性。

>ansible命令如果未指定模块，将使用默认模块`command`。

```shell
[root@centos-vm-4-71 ~]# cat hosts
172.16.4.71

[web_server]
172.16.4.72

[db_server]
172.16.4.73
[root@centos-vm-4-71 ~]# ansible all -i hosts -a "echo 'hello'"
172.16.4.72 | CHANGED | rc=0 >>
hello
172.16.4.73 | CHANGED | rc=0 >>
hello
172.16.4.71 | CHANGED | rc=0 >>
hello

```
`command`与`shell`的差异

```shell
[root@centos-vm-4-71 ~]# ansible all -i hosts -m command -a "ls /tmp|grep 'a.txt'"
172.16.4.71 | FAILED | rc=2 >>
ls: cannot access /tmp|grep: No such file or directory
ls: cannot access a.txt: No such file or directorynon-zero return code
172.16.4.73 | FAILED | rc=2 >>
ls: cannot access /tmp|grep: No such file or directory
ls: cannot access a.txt: No such file or directorynon-zero return code
172.16.4.72 | FAILED | rc=2 >>
ls: cannot access /tmp|grep: No such file or directory
ls: cannot access a.txt: No such file or directorynon-zero return code
[root@centos-vm-4-71 ~]# ansible all -i hosts -m shell -a "ls /tmp|grep 'a.txt'"
172.16.4.71 | CHANGED | rc=0 >>
a.txt
172.16.4.72 | CHANGED | rc=0 >>
a.txt
172.16.4.73 | CHANGED | rc=0 >>
a.txt
```
---

## Ansible模块-script

>将脚本复制远程主机上执行。

```shell
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m script -a "/root/a.sh"
172.16.4.72 | CHANGED => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 172.16.4.72 closed.\r\n",
    "stderr_lines": [
        "Shared connection to 172.16.4.72 closed."
    ],
    "stdout": "hello world\r\n",
    "stdout_lines": [
        "hello world"
    ]
}
```
---

## Ansible模块-copy

- `src`：指定复制文件的源地址
- `dest`：指定复制文件的目标地址
- `backup`：复制文件到目标，如果存在是否备份
- `owner`：指定新复制文件的所有者
- `group`：指定新复制文件的所属组
- `mode`：指定新复制文件的权限

### 简单复制

```shell
[root@centos-vm-4-71 ~]# cat nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
 
[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m copy -a "src=./nginx.repo dest=/etc/yum.repos.d/nginx.repo"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "checksum": "c62d148a221da3d7de0451794fe32d5b7df8df9e",
    "dest": "/etc/yum.repos.d/nginx.repo",
    "gid": 0,
    "group": "root",
    "md5sum": "094165ee4178bb13167ff8980091fa12",
    "mode": "0644",
    "owner": "root",
    "size": 398,
    "src": "/root/.ansible/tmp/ansible-tmp-1617117645.26-58243-120484186350336/source",
    "state": "file",
    "uid": 0
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -a "ls /etc/yum.repos.d/"
172.16.4.72 | CHANGED | rc=0 >>
CentOS-Base.repo
CentOS-Base.repo.bak
CentOS-CR.repo
CentOS-Debuginfo.repo
CentOS-fasttrack.repo
CentOS-Media.repo
CentOS-Sources.repo
CentOS-Vault.repo
CentOS-x86_64-kernel.repo
epel.repo
nginx.repo
```

### 复制前备份

```
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m copy -a "src=./nginx.repo dest=/etc/yum.repos.d/nginx.repo backup=yes"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "backup_file": "/etc/yum.repos.d/nginx.repo.41438.2021-03-30@23:25:47~",
    "changed": true,
    "checksum": "c62d148a221da3d7de0451794fe32d5b7df8df9e",
    "dest": "/etc/yum.repos.d/nginx.repo",
    "gid": 0,
    "group": "root",
    "md5sum": "094165ee4178bb13167ff8980091fa12",
    "mode": "0644",
    "owner": "root",
    "size": 398,
    "src": "/root/.ansible/tmp/ansible-tmp-1617117945.62-60087-97328887775819/source",
    "state": "file",
    "uid": 0
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -a "ls /etc/yum.repos.d/"
172.16.4.72 | CHANGED | rc=0 >>
CentOS-Base.repo
CentOS-Base.repo.bak
CentOS-CR.repo
CentOS-Debuginfo.repo
CentOS-fasttrack.repo
CentOS-Media.repo
CentOS-Sources.repo
CentOS-Vault.repo
CentOS-x86_64-kernel.repo
epel.repo
nginx.repo
nginx.repo.41438.2021-03-30@23:25:47~
```

### 复制后授予指定用户/用户组

```
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m copy -a "src=./nginx.repo dest=/etc/yum.repos.d/nginx.repo owner=nobody group=nobody"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "checksum": "c62d148a221da3d7de0451794fe32d5b7df8df9e",
    "dest": "/etc/yum.repos.d/nginx.repo",
    "gid": 99,
    "group": "nobody",
    "mode": "0644",
    "owner": "nobody",
    "path": "/etc/yum.repos.d/nginx.repo",
    "size": 398,
    "state": "file",
    "uid": 99
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -a "ls -l  /etc/yum.repos.d/nginx.repo "
172.16.4.72 | CHANGED | rc=0 >>
-rw-r--r-- 1 nobody nobody 398 Mar 30 23:25 /etc/yum.repos.d/nginx.repo
```

### 复制后授予指定权限

```
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m copy -a "src=./nginx.repo dest=/etc/yum.repos.d/nginx.repo mode=0755"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "checksum": "c62d148a221da3d7de0451794fe32d5b7df8df9e",
    "dest": "/etc/yum.repos.d/nginx.repo",
    "gid": 99,
    "group": "nobody",
    "mode": "0755",
    "owner": "nobody",
    "path": "/etc/yum.repos.d/nginx.repo",
    "size": 398,
    "state": "file",
    "uid": 99
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -a "ls -l  /etc/yum.repos.d/nginx.repo "
172.16.4.72 | CHANGED | rc=0 >>
-rwxr-xr-x 1 nobody nobody 398 Mar 30 23:25 /etc/yum.repos.d/nginx.repo

```

---

## Ansible模块-yum_repository

- `name`：仓库名称，必须参数
- `description`：仓库描述信息，必须参数
- `baseurl`：yum仓库`repodata`目录所在的url,必须参数
- `file`：仓库文件保存到资源本地的文件名称。默认使用name的值。
- `state`：文件状态处理，preset确认添加，absent确认删除
- `gpgcheck`：是否进行检查GPG

### 添加仓库文件

```shell
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m yum_repository -a "name=test description=test baseurl=http://test.com/repo"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "repo": "test",
    "state": "present"
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -a "cat /etc/yum.repos.d/test.repo"
172.16.4.72 | CHANGED | rc=0 >>
[test]
baseurl = http://test.com/repo
name = test
```

### 删除

```shell
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m yum_repository -a "name=test state=absent"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "repo": "test",
    "state": "absent"
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -a "ls /etc/yum.repos.d/test.repo"
172.16.4.72 | FAILED | rc=2 >>
ls: cannot access /etc/yum.repos.d/test.repo: No such file or directorynon-zero return code
```

---

## Ansible模块-yum

- `name`: 安装的软件包名称，多个名称使用逗号（，）分隔
- `state`：对软件处理方式。
  - `present`：已安装，但不升级
  - `installed`：确认安装
  - `latest`：确认安装，且升级到最新
  - `absent/removed`：移除

### 安装

```shell
# 安装单一软件
ansible web_server -i hosts -m yum -a "name=nginx state=present"
# 安装软件包组
ansible web_server -i hosts -m yum -a "name='@Development tools' state=present"
```

---
### 移除

```shell
ansible web_server -i hosts -m yum -a "name=nginx state=absent"
```

----

## Ansible模块-systemd

- `daemon_reload`：重载systemd
- `enabled`：是否开机启动，`yes/no`
- `nmame`：必选项，服务名称
- `state`：对服务操作状态
  - `started`
  - `stopped`
  - `restarted`
  - `reloaded`

```shell
ansible web_server -i hosts -m systemd -a "daemon_reload=yes"
ansible web_server -i hosts -m systemd -a "name=nginx state=started"
ansible web_server -i hosts -m systemd -a "name=nginx state=stopped"
```

---

## Ansible模块-group

- `name`：组名称
- `system`：是否为系统组，`yes/no`
- `state`：处理状态
  - `present`：添加
  - `absent`：删除

```shell

```
---

## Ansible模块-user

- `name`:用户名，必须参数
- `password`：设置用户密码
- `update_password`：更新密码
- `home`：指定用户的家目录
- `shell`：指定用户的shell
- `comment`：用户的描述信息
- `create_home`：是否创建家目录
- `group`：设置用户的组
- `groups`：设置用户的组组
- `append`：添加组
- `system`：是否为系统用户
- `expires`:设置过期
- `generate_ssh_key`：设置为yes，生成用户秘钥
- `ssh_key_type`：指定秘钥类型，默认rsa
- `state`：用户状态处理
  - `present`：添加
  - `absent`：删除
- `remove`：是否级联删除邮箱等。

- 创建用户

```shell
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m user -a "name=foo password=$(echo "12345678"|openssl passwd -1 -stdin)"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "comment": "",
    "create_home": true,
    "group": 1001,
    "home": "/home/foo",
    "name": "foo",
    "password": "NOT_LOGGING_PASSWORD",
    "shell": "/bin/bash",
    "state": "present",
    "system": false,
    "uid": 1001
}
```

- 创建秘钥

```shell
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m user -a "name=foo generate_ssh_key=yes"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "append": false,
    "changed": true,
    "comment": "",
    "group": 1001,
    "home": "/home/foo",
    "move_home": false,
    "name": "foo",
    "shell": "/bin/bash",
    "ssh_fingerprint": "2048 SHA256:IkNnZJX6JU49i5IV9KJhmVck1pRBYfyVRfbQpKzHHaM ansible-generated on centos-vm-4-72 (RSA)",
    "ssh_key_file": "/home/foo/.ssh/id_rsa",
    "ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbn2lyCksgp2Uv7yAjQY5b5rM100JIDMdzvX20bvk5YQQPrfYUXEapRM5EIy00JrGJXDrmtFNjIcGTlM0Kr6cpQX3fq34ycth78eofw47tOAx/qzaQ+ICT7Ch5PIvoYv3KoguUpn2K3idHUQ1rdTQ088Pp9jg+B9jvyEA/WvUlm+D+FYWdoF/2ZjNzR+3eddQL48+fH+1+66+biKrkU8XABELeoMTm+ggE5vEw/yD8PE597Sx1eKmeIiEc+3ZtJErj4UOMhbXDaxY0XzEK+9GAkm12tSmyP45dnwhpupQzFtYyvg+Kn3HDUSAHLnfjx4JZOMMKGlihKnEmwZVr0gNb ansible-generated on centos-vm-4-72",
    "state": "present",
    "uid": 1001
}
```

**date**

```shell
[root@centos-vm-4-71 ~]# date +%s -d 20200515
1589472000
```

---

## Ansible模块-file

- `owner`：文件/目录所属主
- `group`：文件/目录所属组
- `mode`：文件/目录权限
- `path`：文件/目录的路径，必须参数
- `recurse`：递归设置
- `src`：当state=link时，链接文件的源文件路径
- `dest`：当state=link时，链接文件的目标文件路径
- `state`：文件/目录状态
  - `direcory`：如果目录不存在，则创建
  - `file`：如果文件不存在，则创建
  - `link`：软链接
  - `hard`：硬链接
  - `touch`：不存在文件，则创建文件，存在，则更新文件最后修改时间
  - `absent`：删除文件/目录/链接


```shell
ansible web_server -i hosts -m file -a "path=/tmp/foo.conf state=touch"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "dest": "/tmp/foo.conf",
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "owner": "root",
    "size": 0,
    "state": "file",
    "uid": 0
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m file -a "src=/tmp/foo.conf dest=/tmp/2.conf state=link"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "dest": "/tmp/2.conf",
    "gid": 0,
    "group": "root",
    "mode": "0777",
    "owner": "root",
    "size": 13,
    "src": "/tmp/foo.conf",
    "state": "link",
    "uid": 0
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m file -a "path=/tmp/testdir state=directory"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "gid": 0,
    "group": "root",
    "mode": "0755",
    "owner": "root",
    "path": "/tmp/testdir",
    "size": 6,
    "state": "directory",
    "uid": 0
}
```

---

## Ansible模块-cron

- `name`：cron的名字
- `minute`: 分钟
- `hour`：时
- `day`：天
- `month`：月
- `weekday`：星期
- `job`：要指向的内容，也可以是脚本
- `state`：job状态处理
  - `present`：新增
  - `absent`：删除

```shell
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m cron -a "name=test minute='*/2' job='echo "hello"'"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "envs": [],
    "jobs": [
        "test"
    ]
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m cron -a "name=test state=absent"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "envs": [],
    "jobs": []
}
```

---

## Ansible模块-debug

- `var`：变量值
- `msg`：格式化字符串

```shell
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m debug -a "var=role" -e "role=web"
172.16.4.72 | SUCCESS => {
    "role": "web"
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m debug -a "msg='role is {{role}}'" -e "role=web"
172.16.4.72 | SUCCESS => {
    "msg": "role is web"
}
```

---

## Ansible模块-template

- `src`：源文件路径
- `dest`：目标文件路径
- `owner`：文件所属主
- `group`：文件所属组
- `mode`：文件权限
- `backup`：备份文件

```shell
[root@centos-vm-4-71 ~]# cat helloworld.j2
hello {{var}}!
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m template -a "src=./helloworld.j2 dest=/tmp/helloworld" -e "var=world"
172.16.4.72 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "checksum": "f951b101989b2c3b7471710b4e78fc4dbdfa0ca6",
    "dest": "/tmp/helloworld",
    "gid": 0,
    "group": "root",
    "md5sum": "c897d1410af8f2c74fba11b1db511e9e",
    "mode": "0644",
    "owner": "root",
    "size": 13,
    "src": "/root/.ansible/tmp/ansible-tmp-1617182975.64-41247-31379629026147/source",
    "state": "file",
    "uid": 0
}
[root@centos-vm-4-71 ~]# ansible web_server -i hosts -m shell -a "cat /tmp/helloworld"
172.16.4.72 | CHANGED | rc=0 >>
hello world!
```
---

## Ansible模块-lineinfile

- `path`：目标文件路径
- `state`：文件状态
  - `present`：替换
  - `absent`：删除
- `regexp`：正则表达式
- `line`：文件要插入/替换的行
- `create`：文件不存在，是否要创建

---

## Ansible-playbook语法校验

```shell
ansible-playbook myplaybook.yml --syntax-check
```

---

## 单步调试playboook

```shell
ansible-playbook myplaybook.yml --step
```

---

## 模拟演练playbook

```shell
ansible-playbook -i hosts myplaybook.yml -C
```
---

## 变量分类

- 全局变量
- 剧本变量
- 资产变量

---

## 全局变量

> 通过`-e`传递参数

---

## 剧本变量

- `vars`

```yaml
---
- name: test vars
  hosts: all
  vars:
    user: lilei
    host: /home/lilei
...
```

- `vars_files`

```yaml
---
- name: test vars file
  hosts: all
  vars_files:
    - vars/users.yml
...
```
---

## 资产变量

- 主机变量

```shell
[webservers]
172.16.4.23 user=lilei port=3333
```

- 主机组变量

```shell
[webservers]
172.16.4.23 port=2222
172.16.4.24

[webservers:vars]
port=3333
```

>注：主机变量优先级大于主机组优先级

---

## 主机组变量继承

```shell
[web_servers]
172.16.4.23

[db_servers]
172.16.4.24

[all_servers]
[all_servers:children]
web_servers
db_servers

[all_servers:vars]
port=3333
```

---

## Inventory内置变量

- `ansible_ssh_host`

- `ansible_ssh_port`

- `ansible_ssh_user`

- `ansible_ssh_pass`

- `ansible_sudo_pass`

- `ansible_sudo_exe`

- `ansible_ssh_private_key_file`

- `ansible_python_interpreter`

---

## Facts变量

使用模块`setup`获取

参数`filter=""`可以进行过滤

---

## 关闭facts变量

```yaml
---
- name: test
  hosts: webservers
  gather_facts: no
...
```

---

## 变量优先级

全局变量-->剧本变量-->主机变量-->主机组变量

---

## 变量注册

>将执行命令的结果，注册为变量

```yaml
- name: check nginx syntax
  shell: /usr/sbin/nginx -t
  register: nginxsyntax
- name: print nginx syntax
  ebug: var=nginxsyntax
```
---
## Ansible条件判断

>根据执行语句结果，判断下一步动作

```yaml
---
- name: manager Web server
  hosts: web_servers
  gather_facts: no
  tasks:
    - name: install nginx package
      yum:
        name=nginx
        state=present

    - name: copy nginx conf to remote server
      copy:
        src=nginx.conf
        dest=/etc/nginx/nginx.conf

    - name: check nginx syntax
      shell: /usr/sbin/nginx -t
      register: nginxsyntax

    - name: print nginx syntax
      debug: var=nginxsyntax

    - name: start nginx server
      service:
        name: nginx
        enabled: true
        state: restarted
      when:
        nginxsyntax.rc == 0
...
```
---

## Ansible循环控制

>使用`with_items`进行循环迭代，并使用固定变量名`item`进行变量引用。

```yaml
---
- name: manager Web server
  hosts: web_servers
  gather_facts: no
  vars:
    users:
      - tomcat
      - www
      - mysql
  tasks:
    - name: Print loop var
      debug: msg="{{ item }}"
      with_items: "{{ users }}"
...
```
或者

```yaml
---
- name: manager Web server
  hosts: web_servers
  gather_facts: no
  vars:
    users:
      - tomcat
      - www
      - mysql
  tasks:
    - name: Print loop var
      debug: msg="{{ item }}"
      loop: "{{ users }}"
...
```
执行结果

```shell
[root@centos-vm-4-71 ~]# ansible-playbook -i hosts loop-site.yml

PLAY [manager Web server] **************************************************************************************************************

TASK [Print loop var] ******************************************************************************************************************
ok: [172.16.4.72] => (item=tomcat) => {
    "msg": "tomcat"
}
ok: [172.16.4.72] => (item=www) => {
    "msg": "www"
}
ok: [172.16.4.72] => (item=mysql) => {
    "msg": "mysql"
}

PLAY RECAP *****************************************************************************************************************************
172.16.4.72                : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
---

## Ansible的TAGS属性

>为某个任务定义tags，在执行的时候可以指定tags进行运行，可用于阶段性执行任务

```yaml
---
- name: manager Web server
  hosts: web_servers
  gather_facts: no
  tasks:
    - name: tags 1
      debug:
        msg: tags 1
      tags: first

    - name: tags 2
      debug:
        msg: tags 2
      tags: second
...
```
执行结果

```shell
[root@centos-vm-4-71 ~]# ansible-playbook -i hosts tags-site.yml

PLAY [manager Web server] **************************************************************************************************************

TASK [tags 1] **************************************************************************************************************************
ok: [172.16.4.72] => {
    "msg": "tags 1"
}

TASK [tags 2] **************************************************************************************************************************
ok: [172.16.4.72] => {
    "msg": "tags 2"
}

PLAY RECAP *****************************************************************************************************************************
172.16.4.72                : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[root@centos-vm-4-71 ~]# ansible-playbook -i hosts tags-site.yml -t first

PLAY [manager Web server] **************************************************************************************************************

TASK [tags 1] **************************************************************************************************************************
ok: [172.16.4.72] => {
    "msg": "tags 1"
}

PLAY RECAP *****************************************************************************************************************************
172.16.4.72                : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
---

## Ansible的Handlers属性

>根据执行任务的`changed`状态，来触发某个任务服务,一般用于配置发生变更，重启服务

```yaml
---
- name: manager Web server
  hosts: web_servers
  gather_facts: no
  tasks:
    - name: install nginx package
      yum:
        name=nginx
        state=present

    - name: copy nginx conf to remote server
      copy:
        src=nginx.conf
        dest=/etc/nginx/nginx.conf
      notify: reload nginx service


  handlers:
    - name: reload nginx service
      service:
        name: nginx
        state: reloaded
...
```
当配置文件未发生变化，没有重载服务

```shell
[root@centos-vm-4-71 ~]# ansible-playbook -v -i hosts handlers-site.yaml
Using /etc/ansible/ansible.cfg as config file

PLAY [manager Web server] **************************************************************************************************************

TASK [install nginx package] ***********************************************************************************************************
ok: [172.16.4.72]

TASK [copy nginx conf to remote server] ************************************************************************************************
ok: [172.16.4.72]

PLAY RECAP *****************************************************************************************************************************
172.16.4.72                : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
当配置文件发生变化，通知去执行重载服务

```shell
[root@centos-vm-4-71 ~]# ansible-playbook -v -i hosts handlers-site.yaml
Using /etc/ansible/ansible.cfg as config file

PLAY [manager Web server] **************************************************************************************************************

TASK [install nginx package] ***********************************************************************************************************
ok: [172.16.4.72]

TASK [copy nginx conf to remote server] ************************************************************************************************
changed: [172.16.4.72]

RUNNING HANDLER [reload nginx service] *************************************************************************************************
changed: [172.16.4.72] 
PLAY RECAP *****************************************************************************************************************************
172.16.4.72                : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
---

## 启用SSH长连接

```shell
# /etc/ansible/ansible.cfg
[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=86400s
```

---

## 启用pipline

```shell
# /etc/ansible/ansible.cfg
[ssh_connection]
pipelining = True
```

---

## gather facts本地文件缓存

```shell
# /etc/ansible/ansible.cfg
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection=/dev/shm/ansible_facts_cache/
fact_caching_timeout = 86400s
```

---

## gather facts启用redis缓存

```shell
# /etc/ansible/ansible.cfg
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection=localhost:6379:0
fact_caching_timeout = 86400s
```
---

## Ansible执行策略

>并发执行

```shell
# /etc/ansible/ansible.cfg
[defaults]
strategy = free
```
---

## Ansible禁用SSH主机秘钥检测

```shell
# /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
```
---

## Anaible异步

