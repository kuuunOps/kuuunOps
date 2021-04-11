# Ansible

>Ansible是一种IT自动化工具。它可以配置系统，部署软件，并编排更高级的IT任务，例如连续部署或零停机滚动更新。

## Ansible安装

> Ansible是您安装在控制节点上的无代理自动化工具。Ansible从控制节点远程管理计算机和其他设备（默认情况下，通过SSH协议）。
> 要在命令行上安装Ansible，只需将Ansible软件包安装在一台计算机上即可（很容易是一台笔记本电脑）。您不需要安装数据库或运行任何守护程序。Ansible可以从一个控制节点管理整个远程机器。

### 安装

- `pip`

```shell
$ python -m pip install --user ansible
```
虚拟环境安装pip

```shell
$ python -m virtualenv ansible  # Create a virtualenv if one does not already exist
$ source ansible/bin/activate   # Activate the virtual environment
$ python -m pip install ansible
```

- `RHEL/CentOS`

```shell
$ sudo yum install ansible
```

- `Ubuntu`

```shell
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
```


>在较旧的Ubuntu发行版中，“ software-properties-common”被称为“ python-software-properties”。您可能要使用apt-get而不是apt在旧版本中使用。另外，请注意，只有较新的发行版（换句话说，18.04、18.10等）才带有-u或--update标志，因此请相应地调整脚本。


### 测试，确认安装

```shell
$ echo "127.0.0.1" > ~/ansible_hosts
$ export ANSIBLE_INVENTORY=~/ansible_hosts
$ ansible all -m ping --ask-pass
SSH password:
127.0.0.1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

### 配置命令自动补全

- `RHEL/CentOS`

```shell
$ sudo yum install epel-release
$ sudo yum install python-argcomplete
```

- `pip`

```shell
python -m pip install argcomplete
```

- `Ubuntu`

```shell
$ sudo apt install python-argcomplete
```

全局配置(`bash >= 4.2`)

```shell
$ sudo activate-global-python-argcomplete
```

每个命令单独配置(`bash < 4.2`)

```shell
$ eval $(register-python-argcomplete ansible)
$ eval $(register-python-argcomplete ansible-config)
$ eval $(register-python-argcomplete ansible-console)
$ eval $(register-python-argcomplete ansible-doc)
$ eval $(register-python-argcomplete ansible-galaxy)
$ eval $(register-python-argcomplete ansible-inventory)
$ eval $(register-python-argcomplete ansible-playbook)
$ eval $(register-python-argcomplete ansible-pull)
$ eval $(register-python-argcomplete ansible-vault)
```
---

## Ansible配置

>Ansible默认配置存放在`/etc/ansible/ansible.cfg`，

常见配置项

```shell
[defaults]
# 指定要读取主机清单文件
inventory = /etc/ansible/hosts
# 远程主机临时目录
remote_tmp  = ~/.ansible/tmp
# 本地主机临时目录
local_tmp = ~/.ansible/tmp
# 并发任务数
forks = 5
# 默认提权用户
sudo_user = root
# 启用提权密码
ask_sudo_pass = True
# 启用远程密码
ask_pass = True
# 远程SSH端口
remote_port = 22
# 开启远程主机信息收集
gather_facts: True
# 是否启用远程主机指纹检查
host_key_checking = False
# SSH连接超时时间
timeout = 10
# 远程连接用户
remote_user = root
# 日志存放目录
log_path = /var/log/ansible.log
# 私钥存放路径
private_key_file = /root/.ssh/id_rsa
# 默认模块名称
module_name = command

[privilege_escalation]
# 启用提权
become=True
# 提权的默认方法
become_method=sudo
# 提权的用户
become_user=root
# 提权密码
become_ask_pass=False

[ssh_connection]
# ssh长连接配置
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s
```

## Ansible概念

### `Control node`：控制节点

> 任何安装了Ansible的机器。
> 可以通过从任何控制节点调用`ansible`或`ansible-playbook`命令来运行`ansible`命令和`playbook`。
> 可以使用任何安装了Python的计算机作为控制节点—笔记本电脑、共享桌面和服务器都可以运行Ansible。
> 不能使用Windows机器作为控制节点。
> 可以有多个控制节点。

### `Managed node`：被管理节点

>使用Ansible管理的网络设备（或服务器）
>被管节点有时也称为“主机”。
>被管节点上不需要安装Ansible。

### `Inventory`：清单

>被管节点的列表。
>清单文件有时也称为“主机文件”。
>清单可以为每个被管节点指定诸如IP地址之类的信息。
>清单还可以组织被管节点，创建和嵌套组以便于扩展。

### `Collections`：集合器

>集合器是Ansible内容的分发格式，可以包括`playbook`，`role`，`module`和`plugin`。
>可以通过`ansible-galaxy`安装和使用集合器。

### `Modules`：模块

>Ansible执行代码的单元。
>每个模块都有特定的用途。
>可以通过`task`调用单个模块，也可以在剧本中调用多个不同的模块。

### `Tasks`：任务

>ansible中的动作单位。
>可以使用临时命令一次执行一个任务。

### `Playbook`：剧本

>保存任务的有序列表，以便可以按该顺序重复运行这些任务。
>剧本可以包含变量以及任务。
>剧本采用YAML编写，易于阅读，编写，分享和理解。

---

## Ansible入门

### 配置`Inventory`

>ansible默认读取`/etc/ansible/hosts`中的主机清单

主机清单可以使用IP或FQDN

```shell
172.16.4.61
db.ansible.org
web.ansible.org
```

定义组名，进行分类管理

```shell
[webservers]
172.16.4.61
172.16.4.62

[dbservers]
172.16.4.63
172.16.4.64
```
定义主机变量

```shell
172.16.4.61 ansible_port=2222 ansible_user=root ansible_password=123456
172.16.4.62 ansible_port=3333
```
定义主机组变量

```shell
[webservers]
172.16.4.61
172.16.4.62

[webservers:vars]
ansible_port=2222
```

检查SSH连接

>确认可以使用SSH连接到清单中的所有节点。

- 基于用户名和密码
- 基于SSH公钥

指定远程用户名的方式

- 在命令行使用`-u`指定
- 在主机清单中指定
- 在配置文件中指定
- 设置环境变量

### 第一个ansible命令

```shell
[root@ansible ~]# cat /etc/ansible/hosts
172.16.4.61 ansible_port=22 ansible_user=root ansible_password=123456
[root@ansible ~]# ansible all -m ping
172.16.4.61 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
[root@ansible ~]# ansible all -a "/bin/echo hello"
172.16.4.61 | CHANGED | rc=0 >>
hello
```
使用用户`foo`连接，并提权为`root`，`foo`用户需要在远程主机配置`sudoers`。

```shell
[root@ansible ~]# cat /etc/ansible/hosts
172.16.4.61 ansible_port=22
[root@ansible ~]# ansible all -m ping -u foo -k
172.16.4.61 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
[root@ansible ~]# ansible all -a "ls /root/" -u foo -k
SSH password:
172.16.4.61 | FAILED | rc=2 >>
ls: cannot open directory /root/: Permission deniednon-zero return code
[root@ansible ~]# ansible all -a "ls /root/" -u foo -k --become --become-user root -K
SSH password:
BECOME password[defaults to SSH password]:
172.16.4.61 | CHANGED | rc=0 >>
anaconda-ks.cfg
```
---

## ad-hoc临时命令

>ansible命令行工具来自动化一个或多个被管节点上的单个任务。临时命令非常适合您很少重复执行的任务。

语法结构：

`ansible [匹配清单规则] -m [模块名称] -a [模块选项参数]`


### 命令行常见选项

- `--become-method`：使用权限升级方法(默认为sudo)。
```shell
  [root@ansible ~]# ansible-doc -t become -l
ksu        Kerberos substitute user
pbrun      PowerBroker run
enable     Switch to elevated permissions on a network device
sesu       CA Privileged Access Manager
pmrun      Privilege Manager run
runas      Run As user
sudo       Substitute User DO
su         Substitute User
doas       Do As user
pfexec     profile based execution
machinectl Systemd's machinectl privilege escalation
dzdo       Centrify's Direct Authorize
```

- `--become-user`：指定提权至哪个用户（默认root）

- `--list-hosts`：输出匹配主机的列表;不执行其他任何东西

- `-K, --ask-become-pass`：请求提权密码

- `-a <MODULE_ARGS>, --args <MODULE_ARGS>`：模块参数

- `-b, --become`：启用提权操作

- `-e, --extra-vars`：设置额外的变量

- `-i, --inventory, --inventory-file`：指定目录主机路径或逗号分隔的主机列表。-inventory-file是弃用

- `-k, --ask-pass`：请求连接密码

- `-m <MODULE_NAME>, --module-name <MODULE_NAME>`：要执行的模块名称（默认：command）

- `-u <REMOTE_USER>, --user <REMOTE_USER>`：远程连接用户(默认为None)
  
- `-v, --verbose`：详细模式（`-vvv`更多详情，`-vvvv`启用debug调试）

### 常用模块

#### `command/shell`

```shell
[root@ansible ~]# ansible all -a "free -h"
172.16.4.61 | CHANGED | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           7.8G        372M        7.3G         11M        134M        7.2G
Swap:            0B          0B          0B
```

>`command`不支持管道和重定向扩展`shell`语法，需要使用`shell`模块

```shell
[root@ansible ~]# ansible all -a "free -h |grep 'Mem'"
172.16.4.61 | CHANGED | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           7.8G        371M        7.3G         11M        134M        7.2G
Swap:            0B          0B          0B
[root@ansible ~]# ansible all -m shell -a "free -h |grep 'Mem'"
172.16.4.61 | CHANGED | rc=0 >>
Mem:           7.8G        372M        7.3G         11M        134M        7.2G
```

#### `copy`

- `src`：指定复制文件的来源
- `dest`：指定复制文件的远程目标位置
- `owner`：指定文件属主
- `group`：指定文件属组
- `mode`：指定文件读写权限
- `backup`：是否备份已存在的文件

```shell
[root@ansible ~]# ansible all -m copy -a "src=/etc/passwd dest=/tmp/passwd.tmp"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "checksum": "6ea86f9567b05236d8a4bf4bcc089adc4fa3e99b",
    "dest": "/tmp/passwd.tmp",
    "gid": 0,
    "group": "root",
    "md5sum": "52fe07e830545db4dd66835aae434ffe",
    "mode": "0644",
    "owner": "root",
    "size": 982,
    "src": "/root/.ansible/tmp/ansible-tmp-1618136353.91-54393-50075926695915/source",
    "state": "file",
    "uid": 0
}
[root@ansible ~]# ansible all -a "ls -l /tmp/passwd.tmp"
172.16.4.61 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 982 Apr 11 18:19 /tmp/passwd.tmp
```
---

#### `file`

1. 创建一个空文件

```shell
[root@ansible ~]# ansible all -m file -a "path=/tmp/a.txt state=touch"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "dest": "/tmp/a.txt",
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "owner": "root",
    "size": 0,
    "state": "file",
    "uid": 0
}
```

2. 对已有的文件调整权限

```shell
[root@ansible ~]# ansible all -m file -a "path=/tmp/a.txt owner=foo group=foo state=file"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "gid": 1000,
    "group": "foo",
    "mode": "0644",
    "owner": "foo",
    "path": "/tmp/a.txt",
    "size": 0,
    "state": "file",
    "uid": 1000
}
```

3. 创建一个目录文件

```shell
[root@ansible ~]# ansible all -m file -a "path=/tmp/test owner=foo group=foo state=directory"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "gid": 1000,
    "group": "foo",
    "mode": "0755",
    "owner": "foo",
    "path": "/tmp/test",
    "size": 6,
    "state": "directory",
    "uid": 1000
}
```
4. 创建链接文件

```shell
[root@ansible ~]# ansible all -m file -a "src=/tmp/a.txt dest=/tmp/test/a.txt state=link"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "dest": "/tmp/test/a.txt",
    "gid": 0,
    "group": "root",
    "mode": "0777",
    "owner": "root",
    "size": 10,
    "src": "/tmp/a.txt",
    "state": "link",
    "uid": 0
}
```

5. 删除文件

```shell
[root@ansible ~]# ansible all -m file -a "path=/tmp/test state=absent"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "path": "/tmp/test",
    "state": "absent"
}
```
---

#### `yum`

1. 安装软件包

```shell
ansible all -m yum -a "name=nginx state=present"
```

2. 删除软件包

```shell
ansible all -m yum -a "name=nginx state=absent"
```

---

#### `user`

1. 创建用户

```shell
[root@ansible ~]# ansible all -m user -a "name=john password={{'123456'|password_hash('sha512')}}"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "append": false,
    "changed": true,
    "comment": "",
    "group": 1001,
    "home": "/home/john",
    "move_home": false,
    "name": "john",
    "password": "NOT_LOGGING_PASSWORD",
    "shell": "/bin/bash",
    "state": "present",
    "uid": 1001
}
```

2. 删除用户

```shell
[root@ansible ~]# ansible all -m user -a "name=john state=absent"
172.16.4.61 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": true,
    "force": false,
    "name": "john",
    "remove": false,
    "state": "absent"
}
```

---

#### `service`

1. 启动服务

```shell
[root@ansible ~]# ansible all -m service -a "name=nginx state=started"
```

2. 重启服务

```shell
[root@ansible ~]# ansible all -m service -a "name=nginx state=restarted"
```

3. 停止服务

```shell
[root@ansible ~]# ansible all -m service -a "name=nginx state=stopped"
```

---

#### `setup`

1. 收集所有主机信息

```shell
ansible all -m setup
```

2. 信息过滤

```shell
[root@ansible ~]# ansible all -m setup -a "filter=ansible_fqdn"
172.16.4.61 | SUCCESS => {
    "ansible_facts": {
        "ansible_fqdn": "centos-vm-4-61.ibumobile.local",
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
```
---

#### `git`

```shell
[root@ansible ~]# ansible all -m git -a "repo=https://gitee.com/kuuun/hello-world.git dest=/tmp/hello-world"
172.16.4.61 | CHANGED => {
    "after": "a6fdcbffb08c09e63c48cda1878e15fefcb6460a",
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "before": null,
    "changed": true
}
[root@ansible ~]# ansible all -a "ls -l /tmp/hello-world/"
172.16.4.61 | CHANGED | rc=0 >>
total 40
drwxr-xr-x 3 root root   25 Apr 11 19:35 amd64
drwxr-xr-x 3 root root   25 Apr 11 19:35 arm32v5
drwxr-xr-x 3 root root   25 Apr 11 19:35 arm32v7
drwxr-xr-x 3 root root   25 Apr 11 19:35 arm64v8
-rw-r--r-- 1 root root 2310 Apr 11 19:35 Dockerfile.build
-rw-r--r-- 1 root root   41 Apr 11 19:35 Dockerfile-linux.template
-rw-r--r-- 1 root root  104 Apr 11 19:35 Dockerfile-windows.template
-rwxr-xr-x 1 root root 1981 Apr 11 19:35 generate-stackbrew-library.sh
drwxr-xr-x 2 root root   29 Apr 11 19:35 greetings
-rw-r--r-- 1 root root 1377 Apr 11 19:35 hello.c
drwxr-xr-x 3 root root   25 Apr 11 19:35 i386
-rw-r--r-- 1 root root 1056 Apr 11 19:35 LICENSE
-rw-r--r-- 1 root root 1556 Apr 11 19:35 Makefile
drwxr-xr-x 3 root root   25 Apr 11 19:35 mips64le
drwxr-xr-x 3 root root   25 Apr 11 19:35 ppc64le
-rw-r--r-- 1 root root 4629 Apr 11 19:35 README.md
drwxr-xr-x 3 root root   25 Apr 11 19:35 s390x
-rwxr-xr-x 1 root root  991 Apr 11 19:35 update.sh
```

---

## playbook

>`ansible-playbook`提供了可重复，可重用，简单的配置管理和多机部署系统，非常适合部署复杂的应用程序。如果需要多次使用Ansible执行任务，请编写一本剧本并将其置于源代码控制之下。然后，可以使用剧本推出新的配置或确认远程系统的配置。

### 语法

>剧本以YAML格式表达，且语法最少。

以`---`代表一个文件的开始，以`...`表示一个文件的结束

```yaml
---
- user
- ip
- port
...
```

以`key:value`表示一个字典

```yaml
---
person:
  name: John
  age: 18
...
```

列表

```yaml
---
skills:
  - python
  - perl
  - pascal
...
```

字典和列表的缩写样式

```yaml
---
martin: {name: Martin D'vloper, job: Developer, skill: Elite}
['Apple', 'Orange', 'Strawberry', 'Mango']
...
```

布尔值

```yaml
create_key: yes
needs_agent: no
knows_oop: True
likes_emacs: TRUE
uses_cvs: false
```

跨多行表示

```yaml
---
include_newlines: |
            exactly as you see
            will appear these three
            lines of poetry

fold_newlines: >
            this is really a
            single line of text
            despite appearances
```

### 执行

>剧本按从上到下的顺序运行。

剧本结构

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

运行

```shell
ansible-playbook playbook.yml
```

语法检查

```shell
ansible-playbook playbook.yml --syntax-check
```

### handlers

>处理程序是仅在收到通知时运行的任务。每个处理程序应具有全局唯一的名称。

```shell
- name: Template configuration file
  ansible.builtin.template:
    src: template.j2
    dest: /etc/foo.conf
  notify:
    - Restart memcached
    - Restart apache

  handlers:
    - name: Restart memcached
      ansible.builtin.service:
        name: memcached
        state: restarted

    - name: Restart apache
      ansible.builtin.service:
        name: apache
        state: restarted
```

### tags

>使用标签执行或跳过所选任务的过程

```yaml
---
- hosts: webservers
  tasks:
    - name: Include the bar role
      include_role:
        name: bar
      tags:
        - bar
        - baz
```
执行指定标签的任务

```shell
ansible-playbook example.yml --tags "bar"
```
跳过指定标签的任务

```shell
ansible-playbook example.yml --skip-tags "bar"
```

### 调试

```yaml
---
- hosts: webservers
  vars:
    hello: 123.com

  tasks:
    - name: Show debug
      debug:
        msg: {{ hello }}
```

### 模块

- **get_url**

```shell
- name: Download foo.conf
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    mode: '0440'
```

- **unarchive**

```shell
- name: Extract foo.tgz into /var/lib/foo
  unarchive:
    src: foo.tgz
    dest: /var/lib/foo

- name: Unarchive a file that is already on the remote machine
  unarchive:
    src: /tmp/foo.zip
    dest: /usr/local/bin
    remote_src: yes

- name: Unarchive a file that needs to be downloaded (added in 2.0)
  unarchive:
    src: https://example.com/example.zip
    dest: /usr/local/bin
    remote_src: yes

- name: Unarchive a file with extra options
  unarchive:
    src: /tmp/foo.zip
    dest: /usr/local/bin
    extra_opts:
    - --transform
    - s/^xxx/yyy/
```

### 案例：安装tomcat

```yaml
---
- hosts: tomcatserver
  vars:
    tomcat_version: 8.5.65
    tomcat_install_dir: /usr/local
  tasks:
    - name: Install jdk
      yum:
        name: java-1.8.0-openjdk
        state: present

    - name: Download tomcat
      get_url: 
        url: https://mirrors.bfsu.edu.cn/apache/tomcat/tomcat-8/v{{ tomcat_version }}/bin/apache-tomcat-{{ tomcat_version }}.tar.gz
        dest: /tmp/apache-tomcat-{{ tomcat_version }}.tar.gz

    - name: Unarchive tomcat-{{ tomcat_version }}
      unarchive:
        src: /tmp/apache-tomcat-{{ tomcat_version }}.tar.gz
        dest: "{{ tomcat_install_dir }}"
        remote_src: yes

    - name: Start tomcat
      shell: cd {{ tomcat_install_dir }} && mv apache-tomcat-{{ tomcat_version }} tomcat && cd tomcat && nohup ./bin/startup.sh &
```

---

### `playbook`中的变量

#### 命令行变量

```yaml
---
- hosts: all
  gather_facts: no


  tasks:
    - name: Debug
      debug:
        msg: "{{work_dir}}"
```

```shell
[root@ansible ~]# ansible-playbook test-demo.yml -e "work_dir=/usr/local/tomcat"

PLAY [all] *******************************************************************************************************************

TASK [Debug] *****************************************************************************************************************
ok: [172.16.4.61] => {
    "msg": "/usr/local/tomcat"
}

PLAY RECAP *******************************************************************************************************************
172.16.4.61                : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### playbook中定义

```yaml
---
- hosts: all
  gather_facts: no
  vars:
    nginx_version: 1.14
    nginx_home: /usr/local/nginx

  tasks:
    - name: Debug
      debug:
        msg: "nginx version: {{nginx_version}}，nginx home: {{nginx_home}}"
```
```shell
[root@ansible ~]# ansible-playbook nginx-demo.yml

PLAY [all] *******************************************************************************************************************

TASK [Debug] *****************************************************************************************************************
ok: [172.16.4.61] => {
    "msg": "nginx version: 1.14，nginx home: /usr/local/nginx"
}

PLAY RECAP *******************************************************************************************************************
172.16.4.61                : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 注册变量

```yaml
---
- hosts: all

  tasks:
    - name: Exe command
      command: date +%Y%m%d
      register: date_result

    - name: debug
      debug:
        msg: "{{date_result}}"

    - name: Use register var
      shell: echo hello
      when: date_result.rc == 0
```

```shell
[root@ansible ~]# ansible-playbook register-demo.yml

PLAY [all] *******************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [172.16.4.61]

TASK [Exe command] ***********************************************************************************************************
changed: [172.16.4.61]

TASK [debug] *****************************************************************************************************************
ok: [172.16.4.61] => {
    "msg": {
        "changed": true,
        "cmd": [
            "date",
            "+%Y%m%d"
        ],
        "delta": "0:00:00.128264",
        "end": "2021-04-11 23:11:50.926698",
        "failed": false,
        "rc": 0,
        "start": "2021-04-11 23:11:50.798434",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "20210411",
        "stdout_lines": [
            "20210411"
        ]
    }
}

TASK [Use register var] ******************************************************************************************************
changed: [172.16.4.61]

PLAY RECAP *******************************************************************************************************************
172.16.4.61                : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### facts

```yaml
---
- hosts: all

  tasks:
    - name: debug
      debug:
        msg: "{{ansible_all_ipv4_addresses[0]}}"
```

```shell
[root@ansible ~]# cat facts-demo.yml
---
- hosts: all

  tasks:
    - name: debug
      debug:
        msg: "{{ansible_all_ipv4_addresses[0]}}"
```

### playbook复用


