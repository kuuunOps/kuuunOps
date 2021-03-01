# 使用Docker开发

> ​如果您刚刚开始在Docker上开发全新的应用程序，请查看这些资源以了解一些最常见的模式，以从Docker中获得最大收益。
>
> - 使用多阶段构建来保持图像最小化
> - 使用`volumes`和`bind mounts`管理应用程序数据
> - 使用Kubernetes扩展应用程序
> - 使用Swarm服务扩展应用程序

## 一、Docker开发最佳实践

### 1、如何减小镜像体积

小镜像在启动容器或服务时更快地通过网络传输，更快地加载到内存中。有一些经验法则可以使镜像尺寸减小：

- 从合适的基础镜像开始。例如，如果您需要JDK，请考虑将镜像基于正式的openjdk镜像，而不是从通用的ubuntu镜像开始并将openjdk作为Dockerfile的一部分进行安装。

- 使用多阶段构建。例如，您可以使用Maven镜像来构建Java应用程序，然后重置为tomcat映像并将Java构件复制到正确的位置以部署您的应用程序，所有这些操作都在同一Dockerfile中。这意味着您的最终镜像不包括构建所引入的所有库和依赖项，而仅包括运行它们所需的组件和环境。

- 如果您需要使用不包含多阶段构建的Docker版本，请尝试通过最小化Dockerfile中单独的RUN命令的数量来减少映像中的层数。为此，您可以将多个命令合并到一条RUN行中，并使用Shell的机制将它们组合在一起。

    考虑以下两个代码片段：第一个片段在镜像中创建两层数据，而第二个镜像仅创建一层数据。

```dockerfile
RUN apt-get -y update
RUN apt-get install -y python
```

```dockerfile
RUN apt-get -y update && apt-get install -y python
```

- 如果您有多个具有很多共同点的镜像，请考虑使用共享的组件创建自己的基础镜像，并在此基础上构建独特的镜像。 Docker只需要加载一次公共层，就可以对其进行缓存。这意味着您的派生镜像将更有效地使用Docker主机上的内存，并更快地加载。

- 为了使生产镜像保持精简但允许进行调试，请考虑将生产镜像用作调试镜像的基础镜像。可以在生产镜像的顶部添加其他测试或调试工具。

- 在构建镜像时，请始终使用有用的标签对其进行标记，这些标签可将版本信息，预期的目标（例如，产品或测试），稳定性或其他在不同环境中部署应用程序时有用的信息进行整理。不要依赖自动创建的 `latest` 标签。

### 2、在何处以及如何持久化数据

- 避免使用镜像存储驱动程序将应用程序数据存储在容器的可写层中。这会增加容器的大小，并且从I / O角度来看，效率不如使用`volumes` 或 `bind mounts`。
- 使用 `volumes` 存储数据。
- 一种适合使用 `bind mounts` 的情况是在开发过程中，这时您可能想挂载源目录或刚建在容器中的二进制文件。对于生产，请改用`volumes` ，将其安装到与开发期间 `bind mounts` 安装相同的位置。
- 对于生产，请使用 ` secrets` 存储服务使用的敏感应用程序数据，并对非敏感数据（例如配置文件）使用 `configs` 。如果当前使用独立容器，请考虑迁移以使用单副本服务，以便可以利用这些仅服务功能。


### 3、使用CI/CD进行测试和部署

- 当您签入对源代码管理的更改或创建拉取请求时，请使用Docker Hub或其他CI/CD管道自动构建并标记Docker镜像并对其进行测试。
- 通过要求您的开发，测试和安全团队在将镜像部署到生产中之前对镜像进行签名，可以进一步扩大此范围。这样，在将镜像部署到生产中之前，它已由开发，质量和安全团队进行了测试和签名。

## 二、构建镜像

### 1. 编写Dockerfile的最佳实践

​Docker通过读取Dockerfile中的指令来自动构建映像-Dockerfile是一个文本文件，依次包含构建给定映像所需的所有命令。

​Docker镜像由只读层组成，每个只读层代表一个Dockerfile指令。各个层堆叠在一起，每个层都是上一层的变化的增量。考虑以下Dockerfile：

```dockerfile
FROM ubuntu:18.04
COPY . /app
RUN make /app
CMD python /app/app.py
```
每条指令创建一层：

- FROM：基于ubuntu：18.04 Docker镜像创建一个层。
- COPY：从Docker客户端的当前目录添加文件。
- RUN：使用make命令构建应用程序。
- CMD：指定在容器运行时运行什么命令。

运行镜像并生成容器时，在基础层之上添加一个新的可写层（“容器层”）。对运行中的容器所做的所有更改（例如写入新文件，修改现有文件和删除文件）都将写入此可写容器层。

### 2. 建议和准则

1. 创建临时容器

Dockerfile定义的镜像应生成尽可能短暂的容器。 “短暂”是指可以停止并销毁容器，然后对其进行重建和替换，并使用绝对的最低限度的设置和配置。

2. 了解构建环境

发出`docker build`命令时，当前工作目录称为构建上下文。默认情况下，假定Dockerfile位于此处，但是您可以使用文件标志（-f）指定其他位置。无论Dockerfile实际位于何处，当前目录中文件和目录的所有递归内容都将作为构建上下文发送到Docker守护程序。

**示例：**
创建一个用于构建上下文的目录，并进入。将“ hello”写入名为hello的文本文件，并创建一个在其上运行cat的Dockerfile。从构建上下文（.）中构建图像：

```bash
mkdir myproject && cd myproject
echo "hello" > hello
echo -e "FROM busybox\nCOPY /hello /\nRUN cat /hello" > Dockerfile
docker build -t helloapp:v1 .
```

将Dockerfile和hello移到单独的目录中，并构建镜像的第二个版本（而不依赖上次构建中的缓存）。使用-f指向Dockerfile并指定构建上下文的目录：

```bash
mkdir -p dockerfiles context
mv Dockerfile dockerfiles && mv hello context
docker build --no-cache -t helloapp:v2 -f dockerfiles/Dockerfile context
```

### 3. 通过stdin管道编写Dockerfile

Docker可以通过使用本地或远程构建上下文的stdin传递Dockerfile来构建镜像。通过stdin插入Dockerfile可以在不将Dockerfile写入磁盘的情况下执行一次性构建，或者在生成Dockerfile且此后不应持久的情况下使用。


**示例：**

```bash
echo -e 'FROM busybox\nRUN echo "hello world"' | docker build -
```

```bash
docker build -<<EOF
FROM busybox
RUN echo "hello world"
EOF
```

1. 使用来自STDIN的DOCKERFILE建立图像，而不发送建立上下文

​使用此语法可以使用来自stdin的Dockerfile构建映像，而无需发送其他文件作为构建上下文。连字符（-）占据PATH的位置，并指示Docker从stdin而不是目录中读取构建上下文（仅包含Dockerfile）：

```shell
docker build [OPTIONS] -
```
以下示例使用通过stdin传递的Dockerfile构建映像。没有文件作为构建上下文发送到守护程序。

```shell
docker build -t myimage:latest -<<EOF
FROM busybox
RUN echo "hello world"
EOF
```

​在您的Dockerfile不需要将文件复制到镜像中的情况下，省略构建上下文会很有用，并且由于没有文件发送到守护程序，因此可以提高构建速度。

​如果要通过从构建上下文中排除某些文件来提高构建速度，请使用  `.dockerignore` 进行排除。


2. 使用STDIN的DOCKERFILE从本地构建上下文构建

使用此语法使用本地文件系统上的文件，但使用stdin中的Dockerfile来构建镜像。该语法使用-f（或--file）选项指定要使用的Dockerfile，并使用连字符（-）作为文件名来指示Docker从stdin中读取Dockerfile：

```shell
docker build [OPTIONS] -f- PATH
```

示例：

```shell
# create a directory to work in
mkdir example
cd example

# create an example file
touch somefile.txt

# build an image using the current directory as context, and a Dockerfile passed through stdin
docker build -t myimage:latest -f- . <<EOF
FROM busybox
COPY somefile.txt .
RUN cat /somefile.txt
EOF
```
3. 使用STDIN的DOCKERFILE从远程构建上下文构建

使用此语法使用来自stdin的Dockerfile，使用来自远程git存储库中的文件来构建镜像。该语法使用-f（或--file）选项指定要使用的Dockerfile，并使用连字符（-）作为文件名来指示Docker从stdin中读取Dockerfile：


```shell
docker build [OPTIONS] -f- PATH
```
如果您要从不包含Dockerfile的存储库中构建映像，或者想要使用自定义Dockerfile进行构建而又不维护自己的存储库派生，则此语法很有用。

**示例：**

```shell
docker build -t myimage:latest -f- https://gitee.com/kuuun/hello-world.git <<EOF
FROM busybox
COPY hello.c .
EOF
```

### 4. 使用.dockerignore排除

要排除与构建无关的文件（无需重构源存储库），请使用`.dockerignore`文件。该文件支持类似于`.gitignore`文件的排除模式。

### 5. 使用多阶段构建

多阶段构建使您可以大幅度减小最终镜像的大小，而不必努力减少中间层和文件的数量。

​由于镜像是在生成过程的最后阶段生成的，因此可以利用生成缓存来最小化镜像层。

​例如，如果您的构建包含多个层，则可以将它们从更改频率较低（以确保生成缓存可重用）到更改频率较高的顺序排序：

- 安装构建应用程序所需的工具
- 安装或更新库依赖项
- 生产应用

Go应用程序的Dockerfile可能类似于：

```dockerfile
FROM golang:1.11-alpine AS build

# Install tools required for project
# Run `docker build --no-cache .` to update dependencies
RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

# List project dependencies with Gopkg.toml and Gopkg.lock
# These layers are only re-built when Gopkg files are updated
COPY Gopkg.lock Gopkg.toml /go/src/project/
WORKDIR /go/src/project/
# Install library dependencies
RUN dep ensure -vendor-only

# Copy the entire project and build it
# This layer is rebuilt when a file changes in the project directory
COPY . /go/src/project/
RUN go build -o /bin/project

# This results in a single layer image
FROM scratch
COPY --from=build /bin/project /bin/project
ENTRYPOINT ["/bin/project"]
CMD ["--help"]
```

### 6. 不要安装不必要的软件包

为了降低复杂性，依赖性，文件大小和构建时间，请避免仅仅因为它们“很容易安装”而安装多余或不必要的软件包。例如，您不需要在数据库镜像中包含文本编辑器。

### 7.解耦应用

每个容器应该只有一个关注点。应将应用程序解耦到多个容器中，可以更轻松地水平缩放和重复使用容器。例如，一个Web应用程序堆栈可能由三个单独的容器组成，每个容器都有自己的唯一映像，以分离的方式管理Web应用程序，数据库和内存中的缓存。

将每个容器限制为一个进程是一个很好的经验法则，但这并不是一成不变的规则。例如，不仅可以使用初始化进程来生成容器，而且某些程序还可以自行生成其他进程。例如，Celery可以产生多个工作进程，而Apache可以为每个请求创建一个进程。

根据您的最佳判断，使容器保持清洁和模块化。如果容器相互依赖，则可以使用Docker容器网络来确保这些容器可以通信。

### 8. 减少层数

在较旧的Docker版本中，重要的是最小化镜像中的层数以确保其性能。添加了以下功能来减少此限制：

- 只有指令RUN，COPY，ADD会创建图层。其他说明创建临时的中间映像，并且不会增加构建的大小。
- 尽可能使用多阶段构建，并且仅将所需的工件复制到最终映像中。这使您可以在中间构建阶段中包含工具和调试信息，而无需增加最终映像的大小。

### 9.排序多行参数

尽可能通过字母数字排序多行参数来简化以后的更改。这有助于避免软件包重复，并使列表更易于更新。这也使人们易于阅读和查看。在反斜杠（\）之前添加空格也有帮助。

**示例：**

```dockerfile
RUN apt-get update && apt-get install -y \
  bzr \
  cvs \
  git \
  mercurial \
  subversion
```

### 10. 利用缓存构建

构建镜像时，Docker会逐步执行Dockerfile中的指令，并以指定的顺序执行每个指令。在检查每条指令时，Docker会在其缓存中查找可重用的现有镜像，而不是创建新的（重复的）镜像。

如果根本不想使用缓存，则可以在docker build命令上使用--no-cache = true选项。但是，如果您确实让Docker使用其缓存，那么了解何时可以找到匹配的镜像非常重要。 Docker遵循的基本规则概述如下：

- 从已在缓存中的父镜像开始，将下一条指令与从该基本镜像派生的所有子镜像进行比较，以查看是否其中一个是使用完全相同的指令构建的。如果不是，则高速缓存无效。
- 在大多数情况下，仅将Dockerfile中的指令与子镜像之一进行比较就足够了。但是，某些说明需要更多的检查和解释。
- 对于ADD和COPY指令，将检查镜像中文件的内容，并为每个文件计算一个校验和。在这些校验和中不考虑文件的最后修改时间和最后访问时间。在高速缓存查找期间，将校验和与现有镜像中的校验和进行比较。如果文件中的任何内容（例如内容和元数据）发生了更改，则缓存将无效。
- 除了ADD和COPY命令外，缓存检查不会查看容器中的文件来确定缓存是否匹配。例如，在处理RUN apt-get -y update命令时，不会检查容器中更新的文件以确定是否存在缓存命中。在这种情况下，仅使用命令字符串本身来查找匹配项。

缓存无效后，所有后续Dockerfile命令都会生成新镜像，并且不使用缓存。


### 11. Dockerfile说明

**FROM**

​		尽可能使用当前的官方镜像作为镜像的基础。我们建议使用Alpine镜像，因为它受到严格控制且尺寸较小（当前小于5 MB），同时仍是完整的Linux发行版。

****

**LABEL**

​		可以在镜像上添加标签，以帮助按项目组织镜像，记录许可信息，帮助自动化或其他原因。对于每个标签，添加一行以LABEL开头并带有一个或多个键值对的行。以下示例显示了不同的可接受格式。内嵌包含解释性注释。

```dockerfile
# Set one or more individual labels
LABEL com.example.version="0.0.1-beta"
LABEL vendor1="ACME Incorporated"
LABEL vendor2=ZENITH\ Incorporated
LABEL com.example.release-date="2015-02-12"
LABEL com.example.version.is-production=""
```

​		一个镜像可以有多个标签。在Docker 1.10之前，建议将所有标签合并到一个LABEL指令中，以防止创建额外的层。这不再是必需的，但仍支持组合标签。

```dockerfile
# Set multiple labels on one line
LABEL com.example.version="0.0.1-beta" com.example.release-date="2015-02-12"
```

或

```dockerfile
# Set multiple labels at once, using line-continuation characters to break long lines
LABEL vendor=ACME\ Incorporated \
com.example.is-beta= \
com.example.is-production="" \
com.example.version="0.0.1-beta" \
com.example.release-date="2015-02-12"
```

****

**RUN**

​		将多行长或复杂的RUN语句分割成多行，并用反斜杠分隔，以使Dockerfile更具可读性，可理解性和可维护性。

1. APT-GET

​		RUN的最常见用例可能是apt-get的应用程序。因为它安装了软件包，所以RUN apt-get命令需要注意一些陷阱。

​		避免`RUN apt-get upgrade`和`dist-upgrade`，因为来自父镜像的许多“基本”程序包无法在无特权的容器中升级。如果父镜像中包含的软件包已过期，请联系其维护者。如果您知道有特定的软件包foo需要更新，请使用`apt-get install -y foo`自动更新。

​		始终在同一RUN语句中将`RUN apt-ge update`与`apt-get install`结合在一起。

```dockerfile
RUN apt-get update && apt-get install -y \
package-bar \
package-baz \
package-foo
```

​		在RUN语句中单独使用`apt-get update`会导致缓存问题，并且随后的apt-get安装说明将失败。

```dockerfile
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y curl
```

​		构建映像后，所有层都在Docker缓存中。假设您稍后通过添加额外的软件包来修改`apt-get install`：

```dockerfile
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y curl nginx
```

​		Docker将初始指令和修改后的指令视为相同，并重复使用先前步骤中的缓存。结果，由于构建使用了缓存版本，因此不执行`apt-get update`。由于未运行apt-get更新，因此您的构建可能会获得curl和nginx软件包的过时版本。

​		使用`RUN apt-get update && apt-get install -y`可确保您的Dockerfile安装最新的软件包版本，而无需进一步的编码或手动干预。这种技术称为“缓存清除”。您还可以通过指定软件包版本来实现缓存清除。这称为版本固定。

```dockerfile
RUN apt-get update && apt-get install -y \
package-bar \
package-baz \
package-foo=1.3.*
```

​		版本固定会强制构建物检索特定版本，而不管缓存中的内容是什么。该技术还可以减少由于所需包装中的意外更改而导致的故障。

下面是格式正确的RUN指令，演示了所有的apt-get建议：

```dockerfile
RUN apt-get update && apt-get install -y \
aufs-tools \
automake \
build-essential \
curl \
dpkg-sig \
libcap-dev \
libsqlite3-dev \
mercurial \
reprepro \
ruby1.9.1 \
ruby1.9.1-dev \
s3cmd=1.1.* \
&& rm -rf /var/lib/apt/lists/*
```

​		s3cmd参数指定版本1.1。*。如果映像先前使用的是旧版本，则指定新版本会导致apt-get更新的缓存崩溃，并确保安装新版本。在每行上列出软件包还可以防止软件包重复中的错误。

​		另外，当通过删除`/var/lib/apt/lists/`清理apt缓存时，由于apt缓存未存储在图层中，因此会减小映像大小。由于RUN语句以apt-get更新开始，因此始终在apt-get安装之前刷新程序包缓存。官方的Debian和Ubuntu映像会自动运行apt-get clean，因此不需要显式调用。

2. 使用管道

​		某些RUN命令取决于使用管道字符（|）将一个命令的输出管道传输到另一个命令的能力。

```dockerfile
RUN wget -O - https://some.site | wc -l > /number
```

​		Docker使用`/bin/sh -c`解释器执行这些命令，该解释器仅评估管道中最后一个操作的退出代码以确定成功。在上面的示例中，即使wget命令失败，只要wc -l命令成功，此构建步骤也会成功并生成一个新映像。

​		如果希望由于管道中的任何阶段的错误而导致命令失败，请在set -o pipefail &&之前添加前缀，以确保意外的错误可防止构建意外进行。

```dockerfile
RUN set -o pipefail && wget -O - https://some.site | wc -l > /number
```

​		在诸如基于Debian的映像上的破折号外壳之类的n种情况下，请考虑使用RUN的exec形式来显式选择一个不支持pipefail选项的外壳。

```dockerfile
RUN ["/bin/bash", "-c", "set -o pipefail && wget -O - https://some.site | wc -l > /number"]
```

****

**CMD**

​		应使用CMD指令来运行镜像中包含的软件以及所有参数。 CMD几乎应始终以CMD [“ executable”，“ param1”，“ param2”…]的形式使用。因此，如果镜像用于服务（例如Apache和Rails），则将运行诸如CMD [“ apache2”，“-DFOREGROUND”]之类的内容。实际上，建议将这种形式的指令用于任何基于服务的映像。

​		在大多数其他情况下，应为CMD提供交互式外壳，例如bash，python和perl。例如，CMD [“ perl”，“-de0”]，CMD [“ python”]或CMD [“ php”，“-a”]。使用此表单意味着执行docker run -it python之类的操作时，您将进入可用的shell中，随时可以使用。除非您和您的预期用户已经非常熟悉ENTRYPOINT的工作原理，否则CMD很少以CMD [“ param”，“ param”]的形式与ENTRYPOINT结合使用。

****

**EXPOSE**

​		EXPOSE指令指示容器在其上侦听连接的端口。因此，您应该为应用程序使用通用的传统端口。例如，包含Apache Web服务器的镜像将使用EXPOSE 80，而包含MongoDB的镜像将使用EXPOSE 27017，依此类推。

​		对于外部访问，您的用户可以执行带有标志的docker run，该标志指示如何将指定端口映射到他们选择的端口。对于容器链接，Docker为从收件人容器到源容器的路径（即，MYSQL_PORT_3306_TCP）提供了环境变量。

****

**ENV**

​		为了使新软件更易于运行，可以使用ENV为容器安装的软件更新PATH环境变量。例如，`ENV PATH /usr/local/nginx/ bin：$PATH`确保CMD [“ nginx”]正常工作。

​		ENV指令还可用于提供特定于您希望容器化的服务的必需环境变量，例如Postgres的PGDATA。

​		最后，ENV还可以用于设置常用的版本号，以便更容易维护版本凹凸，如以下示例所示：

```dockerfile
ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3.4
RUN curl -SL http://example.com/postgres-$PG_VERSION.tar.xz | tar -xJC /usr/src/postgress && …
ENV PATH /usr/local/postgres-$PG_MAJOR/bin:$PATH
```

​		类似于在程序中具有常量变量（与硬编码值相反），此方法使您可以更改单个ENV指令以自动神奇地修改容器中软件的版本。

​		每条ENV线都会创建一个新的中间层，就像RUN命令一样。这意味着，即使您在以后的层中取消设置环境变量，它也仍然保留在该层中，并且其值也无法转储。您可以通过创建如下所示的Dockerfile，然后对其进行构建来进行测试。

```dockerfile
FROM alpine
ENV ADMIN_USER="mark"
RUN echo $ADMIN_USER > ./mark
RUN unset ADMIN_USER
```

```shell
$ docker run --rm test sh -c 'echo $ADMIN_USER'
mark
```

​		为避免这种情况，并真正取消设置环境变量，请在外壳层中使用RUN命令和shell命令来设置，使用和取消设置该变量。您可以使用;分隔命令；要么 ＆＆。如果您使用第二种方法，并且其中一个命令失败，则docker build也将失败。这通常是个好主意。使用\作为Linux Dockerfiles的行继续符可以提高可读性。您还可以将所有命令放入一个Shell脚本中，并让RUN命令运行该Shell脚本。

```dockerfile
FROM alpine
RUN export ADMIN_USER="mark" \
&& echo $ADMIN_USER > ./mark \
&& unset ADMIN_USER
CMD sh
```

```shell
$ docker run --rm test sh -c 'echo $ADMIN_USER'
```

****

**ADD or COPY**

​		尽管ADD和COPY在功能上相似，但通常来说COPY是首选。那是因为它比ADD更透明。 COPY仅支持将本地文件基本复制到容器中，而ADD的某些功能（如仅本地tar提取和远程URL支持）并不立即显而易见。因此，与ADD rootfs.tar.xz /中一样，ADD的最佳用途是将本地tar文件自动提取到镜像中。

​		如果您有多个使用不同上下文的文件的Dockerfile步骤，请单独复制而不是一次全部复制。这样可以确保仅在特别需要的文件发生更改时，才使每个步骤的构建缓存无效（强制重新运行该步骤）。

```dockerfile
COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt
COPY . /tmp/
```

​		由于图像大小很重要，因此强烈建议不要使用ADD从远程URL提取程序包；您应该使用curl或wget代替。这样，您可以在提取文件后删除不再需要的文件，而不必在图像中添加其他图层。

错误操作：

```dockerfile
ADD http://example.com/big.tar.xz /usr/src/things/
RUN tar -xJf /usr/src/things/big.tar.xz -C /usr/src/things
RUN make -C /usr/src/things all
```

正确操作：

```dockerfile
RUN mkdir -p /usr/src/things \
&& curl -SL http://example.com/big.tar.xz \
| tar -xJC /usr/src/things \
&& make -C /usr/src/things all
```

对于不需要ADD的tar自动提取功能的其他项目（文件，目录），应始终使用COPY。

****

**ENTRYPOINT**

​		ENTRYPOINT的最佳用途是设置镜像的主命令，使该镜像像该命令一样运行（然后使用CMD作为默认标志）。

示例：

```dockerfile
ENTRYPOINT ["s3cmd"]
CMD ["--help"]
```

现在可以像这样运行图像以显示命令的帮助：

```shell
$ docker run s3cmd
```

或

```shell
$ docker run s3cmd ls s3://mybucket
```

这很有用，因为镜像名称可以用作对二进制文件的引用，如上面的命令所示。

ENTRYPOINT指令也可以与辅助脚本结合使用，即使启动该工具可能需要一个以上的步骤，也可以使它以与上述命令类似的方式起作用。

例如，Postgres Official Image使用以下脚本作为其ENTRYPOINT：

```shell
#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
chown -R postgres "$PGDATA"

if [ -z "$(ls -A "$PGDATA")" ]; then
gosu postgres initdb
fi

exec gosu postgres "$@"
fi

exec "$@"
```

将帮助程序脚本复制到容器中，并在容器启动时通过ENTRYPOINT运行：

```dockerfile
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
```

该脚本允许用户以多种方式与Postgres进行交互。

它可以简单地启动Postgres：

```shell
$ docker run postgres
```

或者，它可以用于运行Postgres并将参数传递给服务器：

```shell
$ docker run postgres postgres --help
```

最后，它也可以用于启动一个完全不同的工具，例如Bash：

```shell
$ docker run --rm -it postgres bash
```

****

**VOLUME**

​		VOLUME指令应用于公开由docker容器创建的任何数据库存储区，配置存储或文件/文件夹。强烈建议您将VOLUME用于图像的任何可变和/或用户可维修的部分。

****

**USER**

​		如果服务可以在没有特权的情况下运行，请使用USER更改为非root用户。首先在Dockerfile中使用`RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres`等创建用户和组。

​		避免安装或使用sudo，因为它具有不可预测的TTY和信号转发行为，可能会导致问题。如果您绝对需要类似于sudo的功能，例如将守护程序初始化为root却以非root身份运行，请考虑使用“ gosu”。

最后，为减少层次和复杂性，请避免频繁来回切换USER。

****

**WORKDIR**

​		为了清楚和可靠，您应该始终为WORKDIR使用绝对路径。另外，您应该使用WORKDIR而不是增加诸如RUN cd…&& do-something之类的指令，这些指令难以阅读，排除故障和维护。

****

**ONBUILD**

​		当前Dockerfile构建完成后，将执行ONBUILD命令。 ONBUILD在从当前镜像派生的任何子镜像中执行。将ONBUILD命令视为父Dockerfile给子Dockerfile的指令。

​		Docker构建在子Dockerfile中的任何命令之前执行ONBUILD命令。

​		对于要从给定图像构建的图像，ONBUILD非常有用。例如，您可以将ONBUILD用于语言堆栈映像，以在Dockerfile中构建用该语言编写的任意用户软件，如Ruby的ONBUILD变体所示。

​		使用ONBUILD构建的图像应获得单独的标签，例如：`ruby：1.9-onbuild`或`ruby：2.0-onbuild`。

​		将ADD或COPY放入ONBUILD时要小心。如果新构建的上下文缺少要添加的资源，则“ onbuild”映像将灾难性地失败。如上所述，添加一个单独的标签可以允许Dockerfile作者做出选择，从而减少这种情况。

## 三、使用多阶段构建

​		多阶段构建是一项新功能，需要守护程序和客户端上使用Docker 17.05或更高版本。多级构建对于在优化Dockerfile的同时使其易于阅读和维护的任何人都非常有用。

### 1. 在多阶段构建之前

​		关于构建镜像，最具挑战性的事情之一是保持镜像尺寸变小。 Dockerfile中的每条指令都会在镜像上添加一层，您需要记住在移至下一层之前清除不需要的任何工件。为了编写一个真正有效的Dockerfile，传统上，您需要使用Shell技巧和其他逻辑来使各层尽可能小，并确保每一层都具有上一层所需的工件，而没有其他任何东西。

​		实际上，通常只有一个Dockerfile用于开发（包含构建应用程序所需的一切），而精简的Dockerfile用于生产时，它仅包含您的应用程序以及运行它所需的内容。这被称为“构建器模式”。维护两个Dockerfile是不理想的。

**`Dockerfile.build`**:

```dockerfile
FROM golang:1.7.3
WORKDIR /go/src/github.com/alexellis/href-counter/
COPY app.go .
RUN go get -d -v golang.org/x/net/html \
  && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
```

​		请注意，此示例还使用Bash &&运算符将两个RUN命令人工压缩在一起，以避免在图像中创建额外的图层。这是容易失败的并且难以维护。例如，插入另一个命令很容易，而忘记使用\字符继续该行。

**`Dockerfile`**:

```dockerfile
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY app .
CMD ["./app"]
```

**`build.sh`**:

```shell
#!/bin/sh
echo Building alexellis2/href-counter:build

docker build --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy \  
    -t alexellis2/href-counter:build . -f Dockerfile.build

docker container create --name extract alexellis2/href-counter:build  
docker container cp extract:/go/src/github.com/alexellis/href-counter/app ./app  
docker container rm -f extract

echo Building alexellis2/href-counter:latest

docker build --no-cache -t alexellis2/href-counter:latest .
rm ./app
```

​		运行build.sh脚本时，它需要构建第一个镜像，从中创建一个容器以复制工件，然后构建第二个图像。这两个镜像都占用了系统空间，并且本地磁盘上仍然有应用程序组件。

### 2. 使用多阶段构建

​		通过多阶段构建，您可以在Dockerfile中使用多个FROM语句。每个FROM指令可以使用不同的基础，并且每个都开始构建的新阶段。您可以有选择地将工件从一个阶段复制到另一个阶段，从而在最终图像中保留不需要的所有内容。

```dockerfile
FROM golang:1.7.3
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]  
```

​		您只需要单个Dockerfile。您也不需要单独的构建脚本。只需运行docker build。

```shell
$ docker build -t alexellis2/href-counter:latest .
```

​		最终结果是与以前相同的微小生产镜像，并大大降低了复杂性。您无需创建任何中间镜像，也无需将任何组件提取到本地系统。

​		它是如何工作的？第二条FROM指令以`alpine：latest`镜像为基础开始新的构建阶段。` COPY --from = 0`行仅将之前阶段的构建工件复制到此新阶段。 Go SDK和任何中间组件都被保留了下来，没有保存在最终镜像中。

### 3. 命名您的构建阶段

​		默认情况下，这些阶段未命名，您可以通过它们的整数来引用它们，对于第一个FROM指令，它们以0开头。但是，可以通过在FROM指令中添加AS <名称>来命名阶段。本示例通过命名阶段并使用COPY指令中的名称来改进前一个示例。这意味着，即使稍后对Dockerfile中的指令进行了重新排序，COPY也不会中断。

```dockerfile
FROM golang:1.7.3 AS builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go    .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]  
```

### 4. 在特定的构建阶段停止

​		构建映像时，不一定需要构建整个Dockerfile，包括每个阶段。您可以指定目标构建阶段。

```dockerfile
$ docker build --target builder -t alexellis2/href-counter:latest .
```

一些可能非常有用的方案是：

- 调试特定的构建阶段
- 使用启用了所有调试符号或工具的调试阶段以及精益生产阶段
- 使用测试阶段，在该阶段中，您的应用将填充测试数据，但使用另一个使用真实数据的阶段进行生产构建

### 5. 使用外部镜像作为一个阶段

​		使用多阶段构建时，您不仅限于从之前在Dockerfile中创建的阶段进行复制。您可以使用COPY --from指令通过本地镜像名称，本地或Docker注册仓库上可用的标签或标签ID从单独的镜像进行复制。 Docker客户端在必要时提取映像并从那里复制组件。

```dockerfile
COPY --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
```

### 6. 将上一个阶段用作新阶段

您可以在使用FROM指令时通过引用上一个阶段结束的地方继续工作。

```dockerfile
FROM alpine:latest as builder
RUN apk --no-cache add build-base

FROM builder as build1
COPY source1.cpp source.cpp
RUN g++ -o /binary source.cpp

FROM builder as build2
COPY source2.cpp source.cpp
RUN g++ -o /binary source.cpp
```



## 四、管理镜像

使镜像可供组织内部或外部的其他人使用的最简单方法是使用Docker注册中心（例如Docker Hub）或运行自己的私有注册中心。

### 1. Docker Hub

​		Docker Hub是由Docker，Inc.管理的公共注册中心。它集中了有关组织，用户帐户和镜像的信息。它包括一个Web UI，使用组织的身份验证和授权，使用诸如 `docker login` ，`docker pull` 和 `docker push` ，注释，星号，搜索等命令的CLI和API访问。

### 2. Docker Registry

​		Docker Registry是Docker生态系统的组成部分。注册中心是一个存储和内容交付系统，其中包含命名的Docker映像，这些映像具有不同的标记版本。例如，具有标签2.0和最新版本的图像分发/注册。用户通过使用`docker push`和`pull`命令（例如`docker pull myregistry.com/stevvooe/batman:voice`）与注册中心进行交互。

Docker Hub是Docker Registry的一个实例。

### 3. 内容信任

​		在网络系统之间传输数据时，信任是一个主要问题。尤其是，当通过不受信任的媒体（例如Internet）进行通信时，确保系统运行的所有数据的完整性和发布者至关重要。您使用Docker将镜像（数据）推入和拉入注册中心。内容信任使您能够验证通过任何渠道从注册中心接收的所有数据的完整性和发布者。