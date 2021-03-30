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