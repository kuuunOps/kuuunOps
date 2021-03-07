# 企业级镜像仓库Harbor

## Harbor概述

Harbor是由VMWare公司开源的容器镜像仓库。事实上，Harbor是在Docker Registry上进行了相应的企业级扩展， 从而获得了更加广泛的应用，这些新的企业级特性包括：管理用户界面，基于角色的访问控制 ，AD/LDAP集成以及 审计日志等，足以满足基本企业需求。

- 官方网站：[https://goharbor.io](https://goharbor.io)
- Github：[https://github.com/goharbor/harbor](https://github.com/goharbor/harbor)

## 准备条件要求

**硬件**

- 最低要求：CPU2核/内存4G/硬盘40GB
- 推荐：CPU4核/内存8G/硬盘160GB

**软件**

- Docker CE 17.06版本+ 
- Docker Compose 1.18版本+

**Harbor安装方式：** 

- 在线安装：从Docker Hub下载Harbor相关镜像，因此安装软件包非常小
- 离线安装：安装包包含部署的相关镜像，因此安装包比较大

## Harbor安装


**安装Docker和docker-compose**

- docker-compose：[https://github.com/docker/compose/releases](https://github.com/docker/compose/releases)

准备二进制文件：` docker-compose-Linux-x86_64 `

```shell
mv docker-compose-Linux-x86_64 /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
```

### HTTP部署

**安装Harbor**

准备离线安装包：` harbor-offline-installer-v2.2.0.tgz `

```shell
tar -xvf harbor-offline-installer-v2.2.0.tgz
cd harbor
cp harbor.yml.tmpl harbor.yml
# 配置hostname
hostname: 172.16.4.13
# 编辑 harbor.yml，注释https相关配置
# https:
# port: 443
# certificate: /your/certificate/path
# private_key: /your/private/key/path
# 填充配置
./prepare
 ./install.sh
```

## Harbor基本使用

1. 配置http镜像仓库可信任 
` vi /etc/docker/daemon.json `
```json
{
    ...
    "insecure-registries":["172.16.4.13"]
} 
```
重启docker服务
```shell
systemctl restart docker
```
2. 打标签 
```shell
docker tag centos:7 172.16.4.13/library/centos:7
```
3. 登录
```shell
docker login 172.16.4.13
```

4. 推送
```shelll
docker push 172.16.4.13/library/centos:7
```

5. 拉取
```shell
docker pull 172.16.4.13/library/centos:7
```

### HTTPS

1. 生成SSL证书 
2. Harbor启用HTTPS
```shell
# 生成SSL证书
# Harbor启用HTTPS
# vi harbor.yml 
https: 
port: 443 
certificate: /root/harbor/ssl/www.kuuun.com.pem 
private_key: /root/harbor/ssl/www.kuuun.com-key.pem 
```
3. 重新配置并部署Harbor
```shell
./prepare 
docker-compose down 
docker-compose up –d
```
4. 将数字证书复制到Docker主机 
```shell
mkdir /etc/docker/certs.d/www.kuuun.com
cp www.kuuun.com.pem /etc/docker/certs.d/www.kuuun.com/www.kuuun.com.crt 
```
5. 验证