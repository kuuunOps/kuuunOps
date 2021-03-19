## 工作负载
### 工作负载控制器是什么

工作负载控制器（Workload Controllers）是K8s的一个抽象概念，用于更高级层次对象，部署和管理Pod。

### 常用工作负载控制器

- ` Deployment `与` ReplicaSet `： `Deployment`用来部署无状态应用。
- ` StatefulSet `： 有状态应用部署 
- ` DaemonSet `： 确保所有Node运行同一个Pod 
- ` Job `： 一次性任务 
- ` Cronjob `： 定时任务

### 控制器的作用

- 管理Pod对象 
- 使用标签与Pod关联 
- 控制器实现了Pod的运维，例如滚动更新、伸缩、副本管理、维护Pod状态等。

---

# Deployment控制器

## 介绍与简单部署

### 介绍

**功能：**
- 管理Pod和ReplicaSet 
- 具有上线部署、副本设定、滚动升级、回滚等功能
- 提供声明式更新，例如只更新一个新的Image

**应用场景：**
网站、API、微服务

### 使用流程

**项目声明周期**

**` 应用程序-->部署-->升级-->回滚-->下线 `**

### 部署

**命令部署**
```shell
kubectl create deployment web --image=nginx:1.15 
```
**YAML部署**
```shell
kubectl apply -f example-deployment.yaml
```

**示例YAML**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - image: nginx:1.15
        name: nginx
```

可以使用service将服务暴露出去，我们就可以通过外部访问deployment部署的服务
```shell
kubectl expose deployment web --port=80 --target-port=80 --type=NodePort
```

## Deployment控制器：滚动升级

**更新镜像方式：**
- 更新配置文件，重新部署：` kubectl apply -f example-deployment.yaml `
- 使用命令更新部署：` kubectl set image deploment/web nginx=1.18`
- 使用编辑功能：` kubectl edit deployment/web `

可以增加就绪检查，让启动慢的程序，有一个准备时间。
```yaml
# 完整示例
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - image: nginx:1.18
        name: nginx
        # 就绪检查
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

### 逻辑原理
K8s对Pod升级的默认策略，通过使用新版本Pod逐步更新旧版本Pod，实现零停机 发布，用户无感知。

![deployment滚动升级](../../../_media/deployment.jpg)


### 更新策略

- ` revisionHistoryLimit `：历史版本保存数量，默认10
  ```shell
  # 查看历史版本
  kubectl get replicasets.apps -o wide
  ```
- ` maxSurge `：滚动更新过程中最大Pod副本数，确保在更新时启动的Pod数量比期望（replicas）Pod数量最大多出一部分（默认25%）。
- ` maxUnavailable `：滚动更新过程中最大不可用Pod副本数，确保在更新时最大Pod数量（默认25%）不可用，即确保一定Pod数量（默认75%）是可用状态。

**示例YAML:**
```yaml
...
spec:
  ...
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: web
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    ...
```

---

## Deployment控制器：发布失败回滚

为当前资源添加版本信息等说明信息

```shell
kubectl annotate deployments.apps web kubernetes.io/change-cause="deployment nginx image 1.16"
```

也可以通过`annotations`添加`kubernetes.io/change-cause`在YAML标识用于说明变更原因，用于记录版本信息，方便回滚查询。

**示例配置**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    kubernetes.io/change-cause: deployment nginx image 1.16
  labels:
    app: web
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - image: nginx:1.16
        name: nginx
        ports:
        - containerPort: 80
```

**查看历史版本**

```shell
# kubectl rollout history deployment web
deployment.apps/web
REVISION  CHANGE-CAUSE
1         deployment nginx image 1.16
2         update nginx image 1.17
3         kubectl set image deployment/web nginx=nginx:1.18 --record=true
```

**回滚到上一版本**
```shell
kubectl rollout undo deployment web
```
**回滚到指定版本**
```shell
kubectl rollout undo deployment web --to-revision=1
```

## Deployment控制器：水平扩容与ReplicaSet控制器

**修改方式**
- 修改yaml配置文件中的` replicas `字段
- 命令行执行
  ```shell
  kubectl scale deployment web --replicas=5
  ```
**项目下线**
```shell
kubectl delete deployments.apps web
kubectl delete services web
```

### Deployment：ReplicaSet

**ReplicaSet控制器用途：**

- Pod副本数量管理，不断对比当前Pod数量与期望Pod数量 
- Deployment每次发布都会创建一个RS作为记录，用于实现回滚

**操作**
```shell
# 查看RS记录
kubectl get rs
# 版本对应RS记录
kubectl rollout history deployment web 
```

### DaemonSet控制器：部署Node守护程序

**DaemonSet功能：**

- 在每一个Node上运行一个Pod 
- 新加入的Node也同样会自动运行一个Pod 

应用场景：网络插件（kube-proxy、calico）、其他Agent

**示例YAML**
```yaml
apiVersion: apps/v1 
kind: DaemonSet 
metadata: 
  name: filebeat 
  namespace: kube-system 
spec: 
  selector: 
    matchLabels: 
      name: filebeat 
  template: 
    metadata: 
      labels: 
        name: filebeat 
    spec: 
      containers: 
      - name: log 
        image: elastic/filebeat:7.3.2
      tolerations:
      - effect: NoSchedule
        operator: Exists
```

---
# Job控制器：一次性任务

Job控制器分为普通任务（Job）和定时任务（CronJob）
- Job一次性执行

应用场景：离线数据处理，视频解码等业务

**示例：**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  # 重试次数
  backoffLimit: 4
```

**查看**
```yaml
kubectl get job
```

---

# CronJob控制器：定时任务

定时任务：CronJob用于实现定时任务，像Linux的Crontab一样。
应用场景：通知，备份

**示例配置**
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

**查看**
```shell
 kubectl get cronjobs
NAME    SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   */1 * * * *   False     1        11s             44s
```