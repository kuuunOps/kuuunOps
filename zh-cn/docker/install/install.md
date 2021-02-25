# Docker的安装

## 一、支持的平台

Docker可以使用二进制文件安装在各种Linux平台，或使用`Docker Desktop`的二进制文件安装在macOS以及windows10平台。

Linux支持的主流平台：CentOS，Debian，Fedora，Raspbian，Ubuntu

## 二、在CenOS系统上安装Docker

#### 1、基础要求

- **系统要求**

安装Docker引擎需要系统主版本为CentOS 7

- **卸载旧版本**

较旧的Docker版本称为docker或docker-engine。如果已安装这些程序，请卸载它们以及相关的依赖项。

```bash
$ sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

- 文件目录 `/var/lib/docker` 的内容（包括映像，容器，卷和网络）被保留。 
- Docker Engine软件包现在称为 `docker-ce` 。

#### 2、安装操作

可以根据自身需要以不同的方式安装Docker Engine：

- 大多数用户会设置Docker的yum存储库并从中进行安装，以简化安装和升级任务。（推荐）
- 一些用户下载并手动安装RPM软件包，并完全手动管理升级。这在诸如在无法访问互联网的空白系统上安装Docker的情况下很有用。
- 在测试和开发环境中，一些用户选择使用自动便利[脚本](./get-docker.sh)来安装Docker。

#### 3、使用yum存储库安装

在新主机上首次安装Docker Engine之前，需要设置Docker存储库地址。之后，您可以从存储库安装和更新Docker。

官方地址：`https://download.docker.com/linux/centos/docker-ce.repo` （国内不推荐，网速较慢）

阿里云地址：`https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo` 

清华大学：`https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo`

- **设置存储仓库地址**

```bash
$ sudo yum install -y yum-utils
$ sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

- **安装Docker**

1、安装最新版本

```bash
$ sudo yum install docker-ce docker-ce-cli containerd.io
```

2、安装特定版本

```bash
$ sudo yum list docker-ce --showduplicates | sort -r
Loaded plugins: fastestmirror
Installed Packages
docker-ce.x86_64          3:19.03.9-3.el7                  ibu-docker-ce-stable
docker-ce.x86_64          3:19.03.8-3.el7                  ibu-docker-ce-stable
docker-ce.x86_64          3:19.03.7-3.el7                  ibu-docker-ce-stable
docker-ce.x86_64          3:19.03.6-3.el7                  ibu-docker-ce-stable
docker-ce.x86_64          3:19.03.5-3.el7                  ibu-docker-ce-stable
docker-ce.x86_64          3:19.03.4-3.el7                  ibu-docker-ce-stable
docker-ce.x86_64          3:19.03.3-3.el7                  ibu-docker-ce-stable
...


$ sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
# 例如： docker-ce-19.03.3
```

Docker被安装后不会启动，Docker会创建一个名 `docker` 的组，默认没有用户在这个组里。

3、启动Docker

```bash
$ sudo systemctl start docker
```



4、通过测试镜像 `hello-world` 来验证Docker服务运行是否正常

```bash
$ sudo docker run hello-world
```

- **升级Docker引擎**

```bash
yum -y upgrade
```

## 三、卸载Docker引擎

1、卸载Docker引擎，客户端以及containerd软件包

```bash
$ sudo yum remove docker-ce docker-ce-cli containerd.io
```

2、主机上的镜像，容器，卷或自定义配置文件不会自动删除。需要手动删除所有镜像，容器和卷：

```bash
$ sudo rm -rf /var/lib/docker
```

## 四、安装后可选步骤

#### 1、以非root用户管理Docker

​Docker守护程序绑定到Unix套接字而不是TCP端口。默认情况下，Unix套接字是由root用户拥有的，其他用户只能使用sudo访问它。 Docker守护程序始终以root用户身份运行。如果不想使用sudo作为docker命令的开头，请创建一个名为docker的Unix组并将用户添加到其中。 Docker守护程序启动时，它将创建一个可由Docker组成员访问的Unix套接字。

1. 创建docker组

```bash
$ sudo groupadd docker
```

2. 添加用户到docker组中

```bash
$ sudo usermod -aG docker $USER
```

3. 刷新组状态

```bash
$ newgrp docker
```

4. 执行测试镜像验证

```bash
$ docker run hello-world
```

#### 2、配置Docker开机启动

```bash
$ sudo systemctl enable docker
$ sudo systemctl disable docker
```

#### 3、配置Docker守护程序监听链接

​默认情况下，Docker守护程序在UNIX套接字上侦听连接以接受来自本地客户端的请求。通过将Docker配置为侦听IP地址和端口以及UNIX套接字，可以允许Docker接受来自远程主机的请求。

**使用 `systemd` 文件配置远程访问**

1. 使用命令 `sudo systemctl edit docker.service`在文本编辑器中打开 `docker.service` 的覆盖配置文件。

2. 添加或修改以下行，以替换您自己的值。

```bash
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375
```
3. 保存文件

4. 重载配置

```bash
$ sudo systemctl daemon-reload
```

5. 重启Docker

```bash
$ sudo systemctl restart docker.service
```

6. 通过查看netstat的输出以确认dockerd在配置的端口上进行侦听，以查看是否更改。

```bash
$ sudo netstat -lntp | grep dockerd
tcp        0      0 127.0.0.1:2375          0.0.0.0:* 
```

**使用 `daemon.json` 文件配置远程访问**

1. 在 `/etc/docker/daemon.json` 中设置hosts数组，以连接到UNIX套接字和IP地址

```bash
{
"hosts": ["unix:///var/run/docker.sock", "tcp://127.0.0.1:2375"]
}
```

2. 重启Docker

3. 通过查看netstat的输出以确认dockerd在配置的端口上进行侦听，以查看是否更改。

```bash
$ sudo netstat -lntp | grep dockerd
tcp        0      0 127.0.0.1:2375          0.0.0.0:*               LISTEN      3758/dockerd
```

## 五、故障排查

- **内核兼容性检测**

​如果您的内核早于3.10版本或缺少某些模块，则Docker无法正确运行。要检查内核兼容性，可以下载并运行[check-config.sh](./check-confi.sh)脚本。

```shell
$ bash ./check-config.sh
```

该脚本仅适用于Linux，不适用于macOS。

- **无法连接到Docker守护程序**

要查看您的客户端配置为连接到哪个主机，请检查您环境中DOCKER_HOST变量的值。

```shell
$ env | grep DOCKER_HOST
```

如果此命令返回值，则将Docker客户端设置为连接到在该主机上运行的Docker守护程序。如果未设置，则将Docker客户端设置为连接到在本地主机上运行的Docker守护程序。如果设置错误，请使用以下命令将其取消设置：

```shell
$ unset DOCKER_HOST
```


​您可能需要在` ~/.bashrc` 或 `~/.bash_profile`等文件中编辑环境变量，以防止错误地设置DOCKER_HOST变量。

​如果按预期设置了DOCKER_HOST，请确认Docker守护进程正在远程主机上运行，并且防火墙或网络中断没有阻止您进行连接。

- **IP转发问题**


- **在resolv.conf中配置了DNS服务器，并且容器无法使用它**

**方法1**：

1. 创建或编辑Docker守护程序配置文件，该文件默认为 `/etc/docker/daemon.json`文件，该文件控制Docker守护程序的配置。

```bash
$ sudo vim /etc/docker/daemon.json
```

2. 添加具有一个或多个IP地址作为值的dns数值。如果文件具有现有内容，则只需添加或编辑dns行。

```bash
{
"dns": ["8.8.8.8", "8.8.4.4"]
}
```

​如果您的内部DNS服务器无法解析公共IP地址，请至少包括一台可以解析的IP服务器，以便您可以连接到Docker Hub，以便您的容器可以解析Internet域名。保存并关闭文件。

3. 重启Docker

```bash
$ sudo service docker restart
```

4. 通过尝试拉镜像来验证Docker是否可以解析外部IP地址：

```bash
$ docker pull hello-world
```

5. 如有必要，请通过ping验证Docker容器可以解析内部主机名。

```bash
$ docker run --rm -it alpine ping -c4 <my_internal_host>

PING google.com (192.168.1.2): 56 data bytes
64 bytes from 192.168.1.2: seq=0 ttl=41 time=7.597 ms
64 bytes from 192.168.1.2: seq=1 ttl=41 time=7.635 ms
64 bytes from 192.168.1.2: seq=2 ttl=41 time=7.660 ms
64 bytes from 192.168.1.2: seq=3 ttl=41 time=7.677 ms
```

**方法2：**

关闭`DNSMASQ` 

```shell
$ sudo service dnsmasq stop

$ sudo systemctl disable dnsmasq
```