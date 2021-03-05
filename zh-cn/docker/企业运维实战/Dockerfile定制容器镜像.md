# Dockerfile定制容器镜像

**样式**
```dockerfile
FROM centos:latest
LABEL maintainer kuuun
RUN yum install gcc -y
COPY run.sh /usr/bin
EXPOSE 80
CMD ["run.sh"]
```
---

## Dockerfile常用指令

| 指令       | 描述                                                                                   |
| ---------- | -------------------------------------------------------------------------------------- |
| FORM       | 构建新镜像是基于哪个镜像                                                               |
| LABEL      | 标签                                                                                   |
| RUN        | 构建镜像时运行的Shell命令                                                              |
| COPY       | 拷贝文件或目录到镜像中                                                                 |
| ADD        | 解压压缩包并拷贝                                                                       |
| ENV        | 设置环境变量                                                                           |
| USER       | 为RUN、CMD和ENTRYPOINT执行命令指定运行用户                                             |
| EXPOSE     | 声明容器运行的服务端口                                                                 |
| WORKDIR    | 为RUN、CMD、ENTERYPOINT、COPY和ADD设置工作目录                                         |
| CMD        | 运行容器时默认执行，如果有多个CMD指令，最后一个生效                                    |
| ENTRYPOINT | 如果与CMD一起用，CMD将作为ENTRYPOINT的默认参数，如果有多个ENTRYPOINT指令，最后一个生效 |

**镜像分类**

1. 基础镜像，centos，ubuntu，alpine
2. 环境镜像，java，php，go
3. 项目镜像

### 构建镜像

**语法格式**：` docker build [OPTIONS] PATH | URL | - [flags] `

**选项**：

- -t：镜像名称
- -f：指定Dockerfile文件位置

**示例文件**
```dockerfile
FROM centos:7
LABEL maintainer kuuun
RUN yum install -y wget curl
COPY a.txt /opt
ENV NAME kuuun
WORKDIR /opt
CMD ["slepp","360000"]
```

**构建命令**
```shell
docker build -t my_centos .
```
---

## CMD与ENTRYPOINT区别

**CMD用法：**

- ` CMD ["executable","param1","param2"] `：exec形式（首选）
- ` CMD ["param1","param2"] `：作为ENTRYPOINT的默认参数 
- ` CMD command param1 param2 `：Shell形式 


**ENTRYPOINT用法：**

- ` ENTRYPOINT ["executable", "param1", "param2"] `
- ` ENTRYPOINT command param1 param2 `
