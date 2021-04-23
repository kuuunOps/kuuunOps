# Jenkins

## Jenkins安装

>准备jdk环境

```shell
curl https://mirrors.tuna.tsinghua.edu.cn/jenkins/redhat-stable/jenkins-2.277.3-1.1.noarch.rpm
rpm -ivh jenkins-2.277.3-1.1.noarch.rpm
```
修改启动用户

```shell
# vim /etc/sysconfig/jenkins
JENKINS_USER="root"
```
启动

```shell
systemctl start jenkins
systemctl enable jenkins
```

## Jenkins基本配置

- 默认访问端口
  
  `8080`

- `JENKINS_HOME`
  
  默认：`/var/lib/jenkins`

- 默认启动用户:
  
  `Jenkins`

- 插件源：
  
  默认官方源
  
  修改为清华源：`https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json`

## Pipeline定义-agent/options

```groovy
agent {
    node {
        label "master" // 指定运行节点的标签或者名称
        customWorkspace "${workspace}" //指定运行工作目录
    }
}
options {
    timestamps() //日志会有时间
    skipDefaultCheckout() //删除隐式checkout scm语句
    disableConcurrentBuilds() //禁止并行
    timeout(time: 1, unit: 'HOURS') //流水线超时设置1h
}
```

## Pipeline定义-stages

>指定阶段

```groovy
stages {
    stage("GetCode"){
        steps {
            timeout(time:5, unit:"MINUTES"){
                script{
                    println('获取代码')
                }
            }
        }
    }
    stage("Build"){
        steps {
            timeout(time:20, unit:"MINUTES"){
                script{
                    println('应用打包')
                }
            }
        }
    }
    stage("CodeScan"){
        steps {
            timeout(time:30, unit:"MINUTES"){
                script{
                    println('代码扫描')
                }
            }
        }
    }
}
```

## Pipeline定义-post

>构建后的操作

- `always`：总是执行的脚本片段
- `success`：成功后执行
- `failure`：失败后执行
- `aborted`：取消后执行

```groovy
post {
    always {
        script{
            println("always")
        }
    }
    success {
        script{
            currentBuild.description += "\n 构建成功"
        }
    }
    failure {
        script{
            currentBuild.description += "\n 构建失败"
        }
    }
    aborted {
        script{
            currentBuild.description += "\n 构建取消"
        }
    }
}
```

## 示例代码

```groovy
#!groovy

String workspace = "/opt/jenkins/workspace"

pipeline{
    //指定运行此流水线的节点
    agent { 
        node { 
            label "master"
            customWorkspace "${workspace}"
        }
        
    }
    
    options {
        timestamps() //日志会有时间
        skipDefaultCheckout() //删除隐式checkout scm语句
        disableConcurrentBuilds() //禁止并行
        timeout(time: 1, unit: 'HOURS') //流水线超时设置1h
    }
    stages {
        stage("GetCode"){
            steps {
                timeout(time:5, unit:"MINUTES"){
                    script{
                        println('获取代码')
                    }
                }
            }
        }
        stage("Build"){
            steps {
                timeout(time:20, unit:"MINUTES"){
                    script{
                        println('应用打包')
                    }
                }
            }
        }
        stage("CodeScan"){
            steps {
                timeout(time:30, unit:"MINUTES"){
                    script{
                        println('代码扫描')
                    }
                }
            }
        }
    }
    post {
        always {
            script{
                println("always")
            }
        }
        success {
            script{
                currentBuild.description += "\n 构建成功"
            }
        }
        failure {
            script{
                currentBuild.description += "\n 构建失败"
            }
        }
        aborted {
            script{
                currentBuild.description += "\n 构建取消"
            }
        }
    }
}
```

## Pipeline语法-agent

>agent指定流水线的执行节点

参数：

- `any`：在任何可用的节点上执行`pipeline`
- `none`：没有指定agent的时候默认
- `lable`：指定标签上的节点上运行`pipeline`
- `node`：运行额外选项

```groovy
agent { node { label 'label name'}}
// 等效于 agent { label 'label name' }
```

## Pipeline语法-post

>定义一个或多个steps，这些阶段根据流水线或阶段的完成情况而运行（取决于流水线中post部分的位置）。post支持以下post-condition块中的其中之一。

| 状态       | 描述                                       |
| ---------- | ------------------------------------------ |
| `always`   | 无论流水线或者阶段的完成状态               |
| `changed`  | 只有当流水线或者阶段完成状态与之前不同时。 |
| `failure`  | 只有当流水线或者阶段状态为`failure`运行。  |
| `success`  | 只有当流水线或者阶段状态为`success`运行。  |
| `unstable` | 只有当流水线或者阶段状态为`unstable`运行   |
| `aborted`  | 只有当流水线或者阶段状态为`aborted`运行    |

## Pipeline语法-stages

>包含一系列一个或者多个stage指令，建议stages至少包含一个stage指令用于连续交付过程的每个离散部分。

```groovy
pipeline {
    agent any
    stages {
        stage('Example'){
            steps {
                echo "Hello World"
            }
        }
    }
}
```

## Pipeline语法-steps

>step是每个阶段中要执行的每个步骤

```groovy
pipeline {
    agent any
    stages {
        stage('Example'){
            steps {
                echo "Hello World"
            }
        }
    }
}
```

## Pipeline语法-environment

>