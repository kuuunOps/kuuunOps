# 深入理解Pod对象：基本管理

## Pod基本概念

>Pod 是Kubernetes中创建和管理的、最小的、可部署的计算单元。一个Pod（就像一个豌豆荚）有一个容器或多个容器组成，这些容器共享存储、网络。

**特点**
- 一个Pod可以理解为是一个应用实例，提供服务
- Pod中容器始终部署在一个Node上
- Pod中容器共享网络、存储资源
- Kubernetes直接管理Pod，而不是容器

## Pod存在的意义

**主要用法**
- 运行单个容器：最常见用法，可以将Pod看做是单个容器的抽象封装
- 运行多个容器：封装多个紧密耦合且需要共享资源的应用程序

**运行多个容器的应用场景**
- 两个应用直接发生文件交互
- 两个应用需要通过`127.0.0.1`或者`socket`通信
- 两个应用需要发生频繁的调用

## Pod资源共享实现机制

- 共享网络：将业务容器网络加入到“负责网络的容器”实现网络共享。
- 共享存储：容器通过数据卷共享数据。

## Pod常用管理命令


**网络共享验证**
example-net-pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: test
  name: pod-net-test
  namespace: default
spec:
  containers:
  - image: busybox
    name: test
    command: ["/bin/sh","-c","sleep 360000"]
  - image: nginx
    name: web
```

**数据卷共享验证**
example-volume-pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: test
  name: pod-volume-test
  namespace: default
spec:
  containers:
  - image: busybox
    name: test
    command: ["/bin/sh","-c","sleep 360000"]
    volumeMounts:
    - name: data
      mountPath: /data
  - image: nginx
    name: web
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: data
    emptyDir: {}
```

- 创建Pod
```shell
kubectl apply -f example-pod.yaml
```
或者命令
```shell
kubectl run nginx --image=nginx
```

- 实时观察Pod状态
```shell
kubectl get pod -w
NAME                   READY   STATUS    RESTARTS   AGE
pod-net-test           2/2     Running   0          59s
```

- 观察pod发生的事件
```shell
kubectl describe pods pod-volume-test
```

- 进入容器
```shell
kubectl exec -it pod-net-test -- sh
```

- 查看日志
```shell
kubectl logs pod-net-test -c web -f 
```

- 进入指定的容器中
```shell
kubectl exec -it pod-net-test -c test -- sh
```

- 删除pod
```shell
kubectl delete -f example-volume-pod.yaml
# 或者
kubectl delete pod-volume-test
```

## k8s对pod状态的管理

```shell
kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE     IP               NODE        NOMINATED NODE   READINESS GATES
web-6c57bdf5f4-6x8ct   1/1     Running   0          4h24m   10.244.169.140   k8s-node2   <none>           <none>
```

### Pod的阶段
- Pending：Pod未调度，或者Pod已调度正在拉去镜像中
- Running：Pod已经运行
- Failed：Pod内容器停止运行
- Success：Pod内容器正常结束
- Unkown：Master与Node失联

## 应用自修复（重启策略+健康检查）

### 重启策略（restartPolicy）
- Always：当容器终止退出后，总是重启容器，默认策略
- OnFailure：当容器异常退出（退出状态码非0），才重启容器。
- Never：当容器终止退出，从不重启容器

### 健康检查类型
- livenessProbe（存活检查）：如果检查失败，将杀死容器，根据Pod的`restartPolicy`来操作
- readinessProbe（就绪检查）：如果检查失败，Kubernetes会把Pod从`service endpoints`中剔除
- startupProbe（启动检查）：

### 检查方法
- httpGet：发送HTTP请求，返回200-400范围状态码为成功
- exec：执行shell命令返回状态码是0为成功
- tcpSocket：发起`TCP Socket`建立成功

[参考文献](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

**示例yaml**
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      # 启动容器后多少秒健康检查
      initialDelaySeconds: 5
      # 以后间隔多少秒检查一次
      periodSeconds: 5
```
这个容器生命的前 30 秒， `/tmp/healthy`文件是存在的。 所以在这最开始的 30 秒内，执行命令`cat /tmp/healthy`会返回成功代码。 30 秒之后，执行命令` cat /tmp/healthy `就会返回失败代码。

- ` initialDelaySeconds `：容器启动后要等待多少秒后存活和就绪探测器才被初始化，默认是 0 秒，最小值是 0。
- ` periodSeconds `：执行探测的时间间隔（单位是秒）。默认是 10 秒。最小值是 1。
- ` timeoutSeconds `：探测的超时后等待多少秒。默认值是 1 秒。最小值是 1。
- ` successThreshold `：探测器在失败后，被视为成功的最小连续成功数。默认值是 1。 存活和启动探测的这个值必须是 1。最小值是 1。
- ` failureThreshold `：当探测失败时，Kubernetes 的重试次数。 存活探测情况下的放弃就意味着重新启动容器。 就绪探测情况下的放弃 Pod 会被打上未就绪的标签。默认值是 3。最小值是 1。


## Pod注入环境变量

### 变量值定义方式

- 自定义变量值
- 变量值从Pod属性获取
- 变量值从Secret、ConfigMap获取

**示例**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-envars
spec:
  containers:
  - name: test
    image: busybox
    command: [ "sh", "-c", "sleep 36000"]
    env:
    - name: MY_NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    - name: MY_POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: MY_POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: MY_POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: NUMBER
      value: "123456"
    - name: NAME
      value: "hello"
```

## Init初始化容器应用

>Init Container：顾名思义，用于初始化工作，执行完就结束，可以理解为一次性任务。

- 支持大部分应用容器配置，但不支持健康检查 
- 优先应用容器执行

**应用场景:**
- 环境检查：例如确保应用容器依赖的服务启动后再启动应用容器
- 初始化配置：例如给应用容器准备配置文件

**示例：部署一个web网站，网站程序没有打包到镜像中，而是希望从代码 仓库中动态拉取放到应用容器中。**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  initContainers:
  - name: download
    image: busybox
    command:
    - wget
    - "-O"
    - "/opt/index.html"
    - http://www.ctnrs.com
    volumeMounts:
    - name: wwwroot
      mountPath: "/opt"
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: wwwroot
      mountPath: /usr/share/nginx/html
  volumes:
  - name: wwwroot
    emptyDir: {}
```

因此，Pod中会有这几种类型的容器：
- Infrastructure Container：基础容器
  - 维护整个Pod网络空间
- InitContainers：初始化容器
  - 先于业务容器开始执行
- Containers：业务容器
  - 并行启动
