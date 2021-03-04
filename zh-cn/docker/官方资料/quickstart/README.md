# Docker快速入门

## 一、Docker概念

>Docker是提供给开发人员和系统管理员使用容器用于构建，运行和共享应用程序的平台。使用容器部署应用程序称为容器化。

- #### 镜像与容器

从根本上说，一个容器不过是一个正在运行的进程，并对其应用了一些附加的封装功能，以使其与主机和其他容器隔离。容器隔离的最重要方面之一是每个容器都与自己的专用文件系统进行交互。该文件系统由Docker镜像提供。镜像包括运行应用程序所需的一切的代码或二进制文件，运行时，依赖项以及所需的任何其他文件系统对象。

- #### 容器与虚拟机

容器是在Linux上本地运行的，并与其他容器共享主机的内核。它运行了一个分离的进程，不占用任何其他可执行文件更多的内存，从而使其轻便。

虚拟机（VM）运行具有“虚拟机管理程序”对主机资源的虚拟访问权的成熟“guest”操作系统。通常，VM会产生大量开销，超出了应用程序逻辑所消耗的开销。

<div style="display: flex;align-content:center ">
    <img src="../../../_media/Container@2x.png" alt="容器" style="zoom: 30%;flex: 4"/><span style="flex:2"></span><img src="../../../_media/VM@2x.png" alt="虚拟机" style="zoom: 30%;flex: 4"/>
</div>

## 二、Docker环境设置

### 1、Docker版本检测

成功安装Docker Desktop后，打开终端并运行 `docker --version` 来检查计算机上安装的Docker的版本

```bash
$ docker --version
Docker version 19.03.12, build 48a66213fe
```

### 2、Docker安装测试

1. 通过运行hello-world Docker镜像来测试安装是否正常

```bash
$ docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
ca4f61b1923c: Pull complete
Digest: sha256:ca0eeb6fb05351dfc8759c20733c91def84cb8007aa89a5bf606bc8b315b9fc7
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

2. 运行 `docker image ls` 列出您下载到计算机上的hello-world镜像。

3. 列出hello-world容器（由图像生成），在显示其消息后退出。如果它仍在运行，则不需要--all选项：

```bash
$ docker ps --all

CONTAINER ID     IMAGE           COMMAND      CREATED            STATUS
54f4984ed6a8     hello-world     "/hello"     20 seconds ago     Exited (0) 19 seconds ago
```

### 3、总结

​至此，您已经在开发机器上安装了Docker，并进行了快速测试，以确保您已设置为构建和运行第一个容器化应用程序。

## 三、构建和运行自己的镜像

​设置好开发环境之后，就可以开始开发容器化的应用程序了。通常，开发工作流程如下所示：

1. 首先创建Docker镜像，为应用程序的每个组件创建和测试单独的容器。
2. 将您的容器和支持基础结构组装成一个完整的应用程序。
3. 测试，共享和部署完整的容器化应用程序。

### 1、安装

让我们下载node-bulletin-board示例项目。这是一个用Node.js编写的简单公告板应用程序。

```bash
git clone https://gitee.com/kuuun/node-bulletin-board.git
cd node-bulletin-board/bulletin-board-app
```

### 2、用Dockerfile定义一个容器

下载项目后，在应用程序中查看名为Dockerfile的文件。 Dockerfile描述了如何为容器组装专用文件系统，并且还可以包含一些元数据，这些元数据描述了如何基于该镜像运行容器。

### 3、构建和测试镜像

现在您已经有了一些源代码和一个Dockerfile，现在该构建您的第一个镜像，并确保从其启动的容器能够按预期工作。
确保使用cd命令在终端或PowerShell中的目录`node-bulletin-board/bulletin-board-app中`。运行以下命令来构建公告板镜像：

```shell
docker build --tag bulletinboard:1.0 .
```
您会看到Docker逐步完成Dockerfile中的每条指令，并逐步构建镜像。如果成功，则构建过程应以一条消息结束：`Successfully tagged bulletinboard:1.0` 。

### 4、使用这个镜像运行一个容器

1. 运行以下命令以基于新镜像启动容器：

```shell
docker run --name bb --publish 8000:8080 --detach  bulletinboard:1.0
```

常见参数：

- `--name` ：指定一个名称，您可以在后续命令中使用该名称来引用您的容器，在本例中为bb。
- `--publish` ：要求Docker将主机端口8000上传入的流量转发到容器的端口8080。容器具有自己的专用端口集，因此，如果要从网络访问某个端口，则必须以这种方式将流量转发到该端口。否则，作为默认的安全状态，防火墙规则将阻止所有网络流量到达您的容器。
- `--detach` ：要求Docker在后台运行此容器。


2. 在浏览器中的`http://localhost:8000`上访问您的应用程序。您应该看到应用程序已启动并正在运行。在这一步，您通常会尽一切可能确保容器按预期方式工作。例如，现在是运行单元测试的时候了。

3. 对公告板容器正常工作感到满意后，可以将其删除：

```shell
docker rm --force bb
```

- `--force` 选项可以强制停止正在运行的容器，并将其删除。

如果首先停止使用docker stop bb运行的容器，则无需使用--force即可将其删除。

#### 5、总结

至此，您已经成功构建了镜像，对应用程序进行了简单的容器化，并确认您的应用程序已在其容器中成功运行。下一步将是在Docker Hub或私有仓库上共享您的镜像，以便可以轻松下载它们并在任何目标计算机上运行它们。

### Dockerfile示例

编写Dockerfile是将应用程序容器化的第一步。您可以将这些Dockerfile命令视为有关如何构建镜像的逐步指南。应用程序中的Dockerfile如下所示：

```dockerfile
# 使用官方镜像作为基础父镜像
FROM node:current-slim

# 设置工作目录
WORKDIR /usr/src/app

# 从你的主机复制文件到当前位置
COPY package.json .

# 在你的镜像文件系统中运行命令
RUN npm install

# 向镜像添加元数据，以描述容器在运行时监听的端口。
EXPOSE 8080

# 在容器内运行指定的命令。
CMD [ "npm", "start" ]

# 将应用程序的其余源代码从主机复制到镜像文件系统中。
COPY . .
```

这个示例中Dockerfile文件将执行以下动作：

- FROM：引用一个已存在的镜像 `node:current-slim` 。这是由Node.js供应商构建的官方镜像，并已由Docker验证为包含Node.js长期支持（LTS）解释器和基本依赖项的高质量镜像。
- WORKDIR：指定后续所有动作在镜像系统中的工作目录 `/usr/src/app` 。不是宿主机目录。
- COPY：将文件package.json从主机复制到镜像中的当前位置（即 `/usr/src/app/package.json` ）。
- RUN：在镜像文件中执行命令 `npm install` 。
- COPY：将程序源代码从主机复制到镜像文件系统中。
- CMD：作为容器运行时的指定的命令。
- EXPOSE：通知Docker该容器在运行时监听8080端口。

## 四、分享镜像文件到Docker Hub

### 1、设置Docker Hub账户

创建并注册Docker ID，通过认证，并登陆。也可以通过输入 `docker login` 从命令行登录Docker Hub。

### 2、创建Docker Hub仓库并推送镜像文件

1. 创建仓库。

2. 配置正确的镜像名称，命名格式为： `<Your Docker ID>/<Repository Name>:<tag>` 。

```bash
docker tag bulletinboard:1.0 <Your Docker ID>/bulletinboard:1.0
```

3. 推送镜像

```bash
docker push <Your Docker ID>/bulletinboard:1.0
```
### 3、总结

现在，镜像已在Docker Hub上可用，您将可以在任何地方运行它。如果您尝试在尚未安装的新机器上使用它，则Docker将自动尝试从Docker Hub下载它。通过以这种方式移动镜像，您不再需要在要运行软件的机器上安装除Docker以外的任何依赖项。容器化应用程序的依赖项已完全封装并隔离在镜像中，您可以如上所述使用Docker Hub进行分享。

需要记住的另一件事：目前，您仅将镜像推送到Docker Hub；那你的Dockerfile呢？一个关键的最佳实践是将它们保留在版本控制中，或者与应用程序的源代码一起保留。您可以在Docker Hub存储库描述中添加链接或注释，以指示可以在何处找到这些文件，不仅保留有关镜像构建方式以及作为完整应用程序运行的方式的记录。
