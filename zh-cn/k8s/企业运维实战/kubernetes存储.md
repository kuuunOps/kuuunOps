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
# 临时卷emptyDir

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
