# 单机编排利器Docker Compose

## Compose概述与安装

> Compose是用于定义和运行多容器的工具。通过Compose可以使用YAML文件来配置容器。然后，使用一个命令就 可以从配置中创建并启动所有服务。

官方文档：[https://docs.docker.com/compose](https://docs.docker.com/compose)

**使用Compose大致为三步**：

- 定义` Dockerfile `，以便可以在任意环境运行 
- 定义应用程序启动配置文件` docker-compose.yml `
- ` docker-compose `启动并管理整个应用程序生命周期

**安装**

1. 下载
```shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
2. 授权
```shell
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
3. 查看版本
```shell
docker-compose --version
docker-compose version 1.28.5, build c4eb3a1f
```
---

## 编排

**示例文件**
```yaml

```