
## 基础环境准备

>所有k8s节点安装ceph软件包

```shell
cat << EOF |sudo tee /etc/yum.repos.d/ceph.repo
[norch]
name=norch
baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/noarch
enabled=1
gpgcheck=0

[x86_64]
name=x86_64
baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/x86_64/
enabled=1
gpgcheck=0
EOF

sudo yum makecache fast
sudo yum install ceph-common -y
```
>创建k8s的pool

```shell
ceph osd pool create kube 16 16
```
>创建k8s用户

```shell
ceph auth get-or-create client.kube mon 'profile rbd' osd 'profile rbd pool=kube'
# 获取k8s用户信息
#[client.kube]
#        key = AQBjSbRgBkzuJxAAOmnSEy42swYA4KEPQnxAcg==
```



## volume

### 1、ceph准备
>创建rbd块

```shell
rbd create -p kube --image-feature layering k8s-nginx --size 10G
rbd info kube/k8s-nginx
```

### 1、k8s准备

>创建secret资源对象

```shell
# 将ceph用户的key进行base64编码
echo 'AQBjSbRgBkzuJxAAOmnSEy42swYA4KEPQnxAcg=='|base64
# QVFCalNiUmdCa3p1SnhBQU9tblNFeTQyc3dZQTRLRVBRbnhBY2c9PQo=
KEY_BASE64="QVFCalNiUmdCa3p1SnhBQU9tblNFeTQyc3dZQTRLRVBRbnhBY2c9PQo="
cat << EOF | sudo tee ceph-secret.yml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
type: "kubernetes.io/rbd"
data:
  key: ${KEY_BASE64}
EOF

kubectl apply -f ceph-secret.yml
```

### 2、k8s使用

```shell
cat << EOF |sudo tee ceph-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: rbd-nginx
spec:
  containers:
    - image: nginx
      name: rbd-nginx
      ports:
      - name: www
        containerPort: 80
        protocol: TCP
      volumeMounts:
      - name: wwwroot
        mountPath: /data
  volumes:
    - name: wwwroot
      rbd:
        monitors:
        - '172.16.4.41:6789'
        - '172.16.4.42:6789'
        - '172.16.4.43:6789'
        pool: kube
        image: k8s-nginx
        fsType: ext4
        user: kube
        secretRef:
          name: ceph-secret
EOF

kubectl apply -f ceph-pod.yml
kubectl get pods
```
---

## PV/PVC

### 1、ceph准备
>创建rbd块

```shell
rbd create -p kube --image-feature layering k8s-nginx-1 --size 10G
rbd info kube/k8s-nginx-1
```

### 2、k8s准备

>pv

```shell
# 定义pv
cat << EOF |sudo tee ceph-pv-00001.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ceph-pv-00001
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: rbd
  persistentVolumeReclaimPolicy: Retain
  rbd:
    monitors:
    - '172.16.4.41:6789'
    - '172.16.4.42:6789'
    - '172.16.4.43:6789'
    pool: kube
    image: k8s-nginx-1
    fsType: ext4
    user: kube
    secretRef:
        name: ceph-secret
EOF

kubectl apply -f ceph-pv-00001.yml
kubectl get pv
```

>pvc

```
# 定义pvc
cat << EOF |sudo tee ceph-pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-demo
spec:
  accessModes:
    - ReadWriteOnce
  volumeName: ceph-pv-00001
  resources:
    requests:
      storage: 10Gi
  storageClassName: rbd
EOF

kubectl apply -f ceph-pvc.yml
kubectl get pvc
```

### 3、k8s使用

```shell
cat << EOF |sudo tee pod-ceph-pvc.yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-ceph-pvc
spec:
  containers:
    - image: nginx
      name: nginx
      ports:
      - name: www
        containerPort: 80
        protocol: TCP
      volumeMounts:
      - name: wwwroot
        mountPath: /data
  volumes:
    - name: wwwroot
      persistentVolumeClaim:
        claimName: pvc-demo
EOF

kubectl apply -f pod-ceph-pvc.yml
kubectl get pods
```
---

## storageclass


### 1、配置ceph

>创建kubernetes的pool

```shell
ceph osd pool create kubernetes 16 16
rbd pool init kubernetes
```
>配置认证

```shell
ceph auth get-or-create client.kubernetes mon 'profile rbd' osd 'profile rbd pool=kubernetes' mgr 'profile rbd pool=kubernetes'
#[client.kubernetes]
#        key = AQAdZLRg/UqcGhAApBb97KPqHJYFxmYYJsrcaw==
ceph mon dump
#dumped monmap epoch 3
#epoch 3
#fsid 6e6d71a9-d2b7-4229-9faa-d1f7541249a7
#last_changed 2021-05-24 09:42:33.623948
#created 2021-05-24 09:25:48.896197
#min_mon_release 14 (nautilus)
#0: [v2:172.16.4.41:3300/0,v1:172.16.4.41:6789/0] mon.node1
#1: [v2:172.16.4.42:3300/0,v1:172.16.4.42:6789/0] mon.node2
#2: [v2:172.16.4.43:3300/0,v1:172.16.4.43:6789/0] mon.node3

```

### 2、配置k8s

>配置configmap资源对象

```shell
 cat <<EOF | sudo tee csi-config-map.yaml
---
apiVersion: v1
kind: ConfigMap
data:
  config.json: |-
    [
      {
        "clusterID": "6e6d71a9-d2b7-4229-9faa-d1f7541249a7",
        "monitors": [
          "172.16.4.41:6789",
          "172.16.4.42:6789",
          "172.16.4.43:6789"
        ]
      }
    ]
metadata:
  name: ceph-csi-config
EOF

kubectl apply -f csi-config-map.yaml
kubectl get cm
```

```shell
cat <<EOF |sudo tee csi-kms-config-map.yaml
---
apiVersion: v1
kind: ConfigMap
data:
  config.json: |-
    {}
metadata:
  name: ceph-csi-encryption-kms-config
EOF

kubectl apply -f csi-kms-config-map.yaml
kubectl get pvc
```


>配置secret资源对象

```shell
cat <<EOF |sudo tee csi-rbd-secret.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: csi-rbd-secret
  namespace: default
stringData:
  userID: kubernetes
  userKey: AQAdZLRg/UqcGhAApBb97KPqHJYFxmYYJsrcaw==
EOF

kubectl apply -f csi-rbd-secret.yaml
kubectl get secret
```

>配置插件

```shell
# 配置rbac
wget -O csi-provisioner-rbac.yaml https://raw.githubusercontent.com/ceph/ceph-csi/master/deploy/rbd/kubernetes/csi-provisioner-rbac.yaml
kubectl apply -f csi-provisioner-rbac.yaml
wget -O csi-nodeplugin-rbac.yaml https://raw.githubusercontent.com/ceph/ceph-csi/master/deploy/rbd/kubernetes/csi-nodeplugin-rbac.yaml
kubectl apply -f csi-nodeplugin-rbac.yaml
```
>创建storageclass

```shell
cat <<EOF |sudo tee csi-rbd-sc.yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: csi-rbd-sc
provisioner: rbd.csi.ceph.com
parameters:
   clusterID: 6e6d71a9-d2b7-4229-9faa-d1f7541249a7
   pool: kubernetes
   imageFeatures: layering
   csi.storage.k8s.io/provisioner-secret-name: csi-rbd-secret
   csi.storage.k8s.io/provisioner-secret-namespace: default
   csi.storage.k8s.io/controller-expand-secret-name: csi-rbd-secret
   csi.storage.k8s.io/controller-expand-secret-namespace: default
   csi.storage.k8s.io/node-stage-secret-name: csi-rbd-secret
   csi.storage.k8s.io/node-stage-secret-namespace: default
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
   - discard
EOF

kubectl apply -f csi-rbd-sc.yaml
```

>部署插件

```shell
wget -O csi-rbdplugin-provisioner.yaml https://raw.githubusercontent.com/ceph/ceph-csi/master/deploy/rbd/kubernetes/csi-rbdplugin-provisioner.yaml
sed -i 's#k8s.gcr.io/sig-storage#quay.io/k8scsi#g' csi-rbdplugin-provisioner.yaml
kubectl apply -f csi-rbdplugin-provisioner.yaml
wget -O csi-rbdplugin.yaml https://raw.githubusercontent.com/ceph/ceph-csi/master/deploy/rbd/kubernetes/csi-rbdplugin.yaml
sed -i 's#k8s.gcr.io/sig-storage#quay.io/k8scsi#g' csi-rbdplugin.yaml
kubectl apply -f csi-rbdplugin.yaml
```

### 3、使用

>定义pvc-块设备

```shell
cat <<EOF |sudo tee raw-block-pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: raw-block-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Block
  resources:
    requests:
      storage: 1Gi
  storageClassName: csi-rbd-sc
EOF
kubectl apply -f raw-block-pvc.yaml
```

>定义pod-作为块设备

```shell
cat <<EOF |sudo tee raw-block-pod.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-raw-block-volume
spec:
  containers:
    - name: fc-container
      image: fedora:26
      command: ["/bin/sh", "-c"]
      args: ["tail -f /dev/null"]
      volumeDevices:
        - name: data
          devicePath: /dev/xvda
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: raw-block-pvc
EOF
kubectl apply -f raw-block-pod.yaml
```

>定义pvc-文件系统

```shell
cat <<EOF |sudo tee pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rbd-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
  storageClassName: csi-rbd-sc
EOF
kubectl apply -f pvc.yaml
```

>定义pod-文件系统

```shell
cat <<EOF |sudo tee pod.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: csi-rbd-demo-pod
spec:
  containers:
    - name: web-server
      image: nginx
      volumeMounts:
        - name: mypvc
          mountPath: /var/lib/www/html
  volumes:
    - name: mypvc
      persistentVolumeClaim:
        claimName: rbd-pvc
        readOnly: false
EOF
kubectl apply -f pod.yaml
```
>statefulset测试

```shell
cat << EOF |sudo tee statefulset-ceph.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"
  replicas: 3 # by default is 1
  template:
    metadata:
      labels:
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "csi-rbd-sc"
      resources:
        requests:
          storage: 1Gi
EOF

kubectl apply -f statefulset-ceph.yaml
```