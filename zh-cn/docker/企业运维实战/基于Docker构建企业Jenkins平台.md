# 基于Docker构建企业Jenkins CI平台

## CI&CD 概述与设计流程

- 持续集成（Continuous Integration，CI）：代码合并、构建、部署、测试都在一起，不断地执行这个过程，并对结果反馈。
- 持续部署（Continuous Deployment，CD）：部署到测试环境、预生产环境、生产环境。
- 持续交付（Continuous Delivery，CD）：将最终产品发布到生产环境，给用户使用。

![ci](../../../_media/jenkinsci.jpg)

## 搭建Gitlab与提交项目代码

```shell
mkdir gitlab-docker-server
cd gitlab-docker-server
docker run -d \
  --hostname 172.16.4.14 \
  --name gitlab \
  -p 443:443 \
  -p 80:80 \
  -p 3322:22 \
  -v $PWD/config:/etc/gitlab \
  -v $PWD/logs:/var/log/gitlab \
  -v $PWD/data:/var/opt/gitlab \
  -v /etc/localtime:/etc/localtime \
  --restart=always \
  gitlab/gitlab-ce:latest
```
**提交代码**

推送现有文件夹
```shell
git init
git remote add origin http://172.16.4.14/root/java-demo.git
git add .
git commit -m "Initial commit"
git push -u origin master
```

## 搭建Jenkins

1. 准备jdk和maven安装包

2. 部署jenkins
```shell
docker run -d \
   -p 80:8080 \
   -p 50000:50000 \
   -u root  \
   -v jenkins-data:/var/jenkins_home \
   -v /var/run/docker.sock:/var/run/docker.sock   \
   -v /usr/bin/docker:/usr/bin/docker \
   -v $PWD/maven:/usr/local/maven \
   -v $PWD/jdk:/usr/local/jdk \
   -v /etc/localtime:/etc/localtime \
   --restart=always \
   --name jenkins \
   jenkinsci/blueocean
```

## Jenkins的Pipeline概述

- Jenkins Pipeline是一套插件，支持在Jenkins中实现集成和持续交付管道； 
- Pipeline通过特定语法对简单到复杂的传输管道进行建模； 
- 声明式：遵循与Groovy相同语法。pipeline { } 
- 脚本式：支持Groovy大部分功能，也是非常表达和灵活的工具。node { } 
- Jenkins Pipeline的定义被写入一个文本文件，称为Jenkinsfile。

**示例模板**
```jenkinsfile
pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }

    stages {
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/jglick/simple-maven-project-with-tests.git'

                // Run Maven on a Unix agent.
                sh "mvn -Dmaven.test.failure.ignore=true clean package"

                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }

            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.jar'
                }
            }
        }
    }
}
```

**修改Jenkins插件源**

```shell
sed -i 's/http:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.aliyun.com\/jenkins/g' default.json && \
sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' default.json
# 重启Jenkins
docker restart jenkins
```

