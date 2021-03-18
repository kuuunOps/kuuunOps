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
version: '3'
services:
  web:
    image: nginx:v1
    ports:
      - "80:80"
    networks:
      - lnmp
  db:
    image: mysql:5.7
    command: --charactor-set-server=utf8
    environment:
      - MYSQL_ROOT_PASSWORD=123456
    networks:
      - lnmp
    volumes:
      - "mysqldata:/var/lib/mysql"
networks:
  lnmp: {}

volumes:
  mysqldata: {}
```

| 字段           | 描述                                                                |
| -------------- | ------------------------------------------------------------------- |
| build          | 构建选项                                                            |
| dockerfile     | 指定Dockerfile文件名                                                |
| context        | 指定镜像                                                            |
| command        | 容器中执行命令，覆盖默认命令                                        |
| container_name | 指定容器名称，由于容器名称是唯一的，如果指定自定义名称，则无法scale |
| enviroment     | 添加环境变量                                                        |
| networks       | 加入网络，引用顶级networs下条目                                     |
| ports          | 暴露端口，与-p相同，但端口不能低于60                                |
| extra_hosts    | 添加主机名映射，与--add-host相同                                    |
| volumes        | 挂载宿主机路径或数据卷。如果是命名卷在顶级volumes定义卷名称         |
| restart        | 重启策略，默认no，always，on-failure，unless-stopped                |
| hostname       | 容器主机名                                                          |


---

## 案例1：一键部署LNMP网站平台

**示例配置**
```yaml
version: '3'
services:
  nginx:
    hostname: nginx
    build:
      context: ./nginx
      dockerfile: Dockerfile
    ports:
      - 80:80
    networks:
      - lnmp
    volumes:
      - ./nginx/php.conf:/usr/local/nginx/conf/vhost/php.conf
      - ./wwwroot:/usr/local/nginx/html

  php:
    hostname: php
    build:
      context: ./php
      dockerfile: Dockerfile
    networks:
      - lnmp
    volumes:
      - ./wwwroot:/usr/local/nginx/html

  mysql:
    hostname: mysql
    image: mysql:5.7
    ports:
      - 3306:3306
    networks:
      - lnmp
    volumes:
      - ./mysql/conf:/etc/mysql/conf.d
      - ./mysql/data:/var/lib/mysql
    command: --character-set-server=utf8
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: test
      MYSQL_USER: user
      MYSQL_PASSWORD: user123456

networks:
  lnmp: {}
```


## 案例2：一键部署  Nginx 反向代理  Tomcat 集群

**示例配置**
```yaml
version: '3'
services:
  nginx:
    hostname: nginx
    build:
      context: ./nginx
      dockerfile: Dockerfile
    ports:
      - 80:80
    networks:
      - lnmt
    volumes:
      - ./nginx/tomcat.conf:/usr/local/nginx/conf/vhost/tomcat.conf
      - ./webapps:/usr/local/tomcat/webapps

  tomcat01:
    hostname: tomcat01
    build: ./tomcat
    networks:
      - lnmt
    volumes:
      - ./webapps:/usr/local/tomcat/webapps

  tomcat02:
    hostname: tomcat02
    build: ./tomcat
    networks:
      - lnmt
    volumes:
      - ./webapps:/usr/local/tomcat/webapps

  mysql:
    hostname: mysql
    image: mysql:5.7
    ports:
      - 3306:3306
    networks:
      - lnmt
    volumes:
      - ./mysql/conf:/etc/mysql/conf.d
      - ./mysql/data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: test
      MYSQL_USER: user
      MYSQL_PASSWORD: user123456

networks:
  lnmt:
```