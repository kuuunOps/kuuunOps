# Kubernetes存储

容器部署过程中一般有以下三种数据： 
- 启动时需要的初始数据，例如配置文件 
- 启动过程中产生的临时数据，该临时数据需要多个容器间共享
- 启动过程中产生的持久化数据，例如MySQL的data目录

# 数据卷概述

>Kubernetes中的Volume提供了在容器中挂载外部存储的能力 
>
>Pod需要设置卷来源（spec.volume）和挂载点（spec.containers.volumeMounts）两个信息后才可以使用相应的Volume 

## 分类

官方文献：https://kubernetes.io/zh/docs/concepts/storage/volumes/#volume-types

- 本地（hostPath，emptyDir等） 
- 网络（NFS，Ceph，GlusterFS等）
- 公有云（AWS EBS等） 
- K8S资源（configmap，secret等）

---

# 数据卷
## emptyDir

>Pod 启动时为空，存储空间来自本地的 kubelet 根目录（通常是根磁盘）或内存

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: my-web
  name: my-web
spec:
  restartPolicy: Always
  containers:
  - image: nginx:1.18
    name: my-web
    ports:
    - containerPort: 80
    volumeMounts:
    - name: wwwroot
      mountPath: /usr/share/nginx/html

  volumes:
  - name: wwwroot
    emptyDir: {}
```
---

## hostPath

>hostPath卷：挂载Node文件系统（Pod所在节点）上文件或者目 录到Pod中的容器。

应用场景：Pod中容器需要访问宿主机文件

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: my-web
  name: my-web
spec:
  restartPolicy: Always
  containers:
  - image: nginx:1.18
    name: my-web
    ports:
    - containerPort: 80
    volumeMounts:
    - name: localtime
      mountPath: /etc/localtime

  volumes:
  - name: localtime
    hostPath:
      path: /etc/localtime
      type: File
```

`type`的值可选为：

| 取值                | 行为                                                                                               |
| ------------------- | -------------------------------------------------------------------------------------------------- |
|                     | 空字符串（默认），在安装` hostPath `卷之前不会执行任何检查。                                       |
| `DirectoryOrCreate` | 如果目录不存在，那么将根据需要创建空目录，权限设置为 0755，具有与 kubelet 相同的组和属主信息。     |
| `Directory`         | 必须存在的目录                                                                                     |
| `FileOrCreate`      | 如果文件不存在，那么将在那里根据需要创建空文件，权限设置为 0644，具有与 kubelet 相同的组和所有权。 |
| `File`              | 必须存在的文件。                                                                                   |
| `Socket`            | 必须存在的 UNIX 套接字。                                                                           |
| `CharDevice`        | 必须存在的字符设备。                                                                               |
| `BlockDevice`       | 必须存在的块设备。                                                                                 |

---

## NFS

1. 准备

```shell
yum install -y nfs-utils
vi /etc/exports 
/data/project/nfs/kubernetes *(rw,no_root_squash) 
# mkdir -p /data/project/nfs/kubernetes 
# systemctl start nfs 
# systemctl enable nfs
```

2. 配置文件

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: my-web
  name: my-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-web
  template:
    metadata:
      labels:
        app: my-web
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: wwwroot
          mountPath: /usr/share/nginx/html

      volumes:
      - name: wwwroot
        nfs:
          server: 172.16.4.64
          path: /data/project/nfs/kubernetes/wwwroot
```

---

# 持久卷：静态PV

## 1. **创建PV（PersistentVolume）卷**

  创建PV卷用于等待响应资源进行挂载。

  **示例**
  ```yaml
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: wwwroot-pv
    labels:
      type: nfs
  spec:
    capacity:
      storage: 10Gi
    accessModes:
      - ReadWriteMany
    nfs:
      server: 172.16.4.64
      path: "/data/project/nfs/kubernetes/wwwroot"
  ```

## 2. **创建PVC**

  设置要请求创建卷的大小，当匹配到合适大小的PV卷，则PVC就与PV进行绑定

   **示例**
   ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: wwwroot-pvc
  spec:
    accessModes:
    - ReadWriteMany
    resources:
      requests:
        storage: 5Gi
   ```

## 3. **创建Pod**
   
   创建Pod挂载PV卷

  **示例**
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    labels:
      app: my-web
    name: my-web
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: my-web
    template:
      metadata:
        labels:
          app: my-web
      spec:
        volumes:
        - name: wwwroot
          persistentVolumeClaim:
            claimName: wwwroot-pvc
        containers:
        - image: nginx
          name: nginx
          ports:
          - containerPort: 80
          volumeMounts:
          - name: wwwroot
            mountPath: /usr/share/nginx/html
  ```

## 4. **卷状态**

```shell
NAME                                 CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
persistentvolume/wwwroot-pv-volume   10Gi       RWX            Retain           Bound    default/wwwroot-pvc                           14m

NAME                                STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/wwwroot-pvc   Bound    wwwroot-pv-volume   10Gi       RWX                           14m

```

---

# PV生命周期

## 访问模式（ACCESS MODES）

AccessModes 是用来对 PV 进行访问模式的设置，用于描述用户应用对存储资源的访问权限，访问权限包括下面几种方式：
- `ReadWriteOnce（RWO）`：读写权限，但是只能被单个节点挂载
- `ReadOnlyMany（ROX）`：只读权限，可以被多个节点挂载
- `ReadWriteMany（RWX）`：读写权限，可以被多个节点挂载

## 回收策略（RECLAIM POLICY）

- Retain（保留）： 保留数据，需要管理员手工清理数据 
- Recycle（回收）：清除 PV 中的数据，效果相当于执行` rm -rf /nfs/kuberneres/* `
- Delete（删除）：与 PV 相连的后端存储同时删除

## 状态（STATUS）

- `Available（可用）`：表示可用状态，还未被任何 PVC 绑定 
- `Bound（已绑定）`：表示 PV 已经被 PVC 绑定 
- `Released（已释放）`：PVC 被删除，但是资源还未被集群重新声明 
- `Failed（失败）`： 表示该 PV 的自动回收失败

---

# 持久卷：动态PV

# NFS

## 安装NFS-Client插件

```shell
git clone https://gitee.com/kuuun/external-storage.git
cd external-storage/nfs-client/deploy
# 授权访问apiserver
kubectl apply -f rbac.yaml
# 部署插件，需修改里面NFS服务器地址与共享目录
# kubectl apply -f deployment.yaml
# 创建存储类 
# kubectl apply -f class.yaml
# 查看存储类
# kubectl get sc
```