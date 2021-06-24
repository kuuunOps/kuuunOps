# Apache Maven

## 介绍

- Maven 是Apache基金会下的开源项目
- 用于Java项目的构建，依赖管理，包发布和分发

## 优点

- 不需要将依赖放入libs目录，大大减少项目大小
- 相对于Ant打包，Maven通过Pom文件声明依赖，从中央Maven仓库下载依赖，保证依赖一致性

## 命令

| 命令          | 描述         |
| ------------- | ------------ |
| `mvn clean`   | 清理缓存     |
| `mvn compile` | 编译         |
| `mvn package` | 打包         |
| `mvn test`    | 执行测试     |
| `mvn install` | 上传到私服   |
| `mvn deploy`  | 部署到服务器 |

## Pom.xml

- Project
  - Group ID
  - Artifact ID
  - Modules
  - Dependencies

## 制品

- Snapshot

>版本号默认带日志作为唯一标识，对同一版本号的包可以重复部署到Maven私服

- Release

>如果Maven私服已经存在某个Release版本，那么尝试部署相同版本号的包会报错，需要升级版本号。
>依赖第三方jar包时尽量使用对方的Release版本

## Maven私服-artifactory

- Docker

>默认用户名/密码：admin/password

```shell

mkdir -p $JFROG_HOME/artifactory/var/etc/
cd $JFROG_HOME/artifactory/var/etc/
touch ./system.yaml
chown -R $UID:$GID $JFROG_HOME/artifactory/var
chmod -R 777 $JFROG_HOME/artifactory/var

docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:latest
```



