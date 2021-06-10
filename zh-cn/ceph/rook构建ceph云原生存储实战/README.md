# Rook构建Ceph云原生存储实战

## 一、准备好k8s集群

## 二、部署

>下载yaml

```shell
git clone --single-branch --branch v1.5.11 https://gitee.com/kuuun/rook.git
```
>部署Operator

```shell
cd cluster/examples/kubernetes/ceph
# 如果需要配置镜像源，需要修改operator.yaml
# 例如：
#   ROOK_CSI_CEPH_IMAGE: "quay.io/cephcsi/cephcsi:v3.3.1"
#   ROOK_CSI_REGISTRAR_IMAGE: "quay.io/k8scsi/csi-node-driver-registrar:v2.0.1"
#   ROOK_CSI_RESIZER_IMAGE: "quay.io/k8scsi/csi-resizer:v1.0.1"
#   ROOK_CSI_PROVISIONER_IMAGE: "quay.io/k8scsi/csi-provisioner:v2.0.4"
#   ROOK_CSI_SNAPSHOTTER_IMAGE: "quay.io/k8scsi/csi-snapshotter:v4.0.0"
#   ROOK_CSI_ATTACHER_IMAGE: "quay.io/k8scsi/csi-attacher:v3.0.2"

kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl -n rook-ceph get pod
```
>创建集群

```shell
kubectl create -f cluster.yaml
kubectl -n rook-ceph get pod
```

## 三、toolbox

```shell
cd cluster/examples/kubernetes/ceph
kubectl apply -f toolbox.yaml
kubectl -n rook-ceph exec -it rook-ceph-tools-fc5f9586c-2smzz -- bash
ceph status
```

>原生客户端访问

```shell
# 安装ceph
sudo curl -fsSL https://mirrors.aliyun.com/ceph/keys/release.asc | sudo apt-key add -
sudo apt-add-repository "deb https://mirrors.aliyun.com/ceph/debian-octopus/  $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install ceph-common -y
ceph -v

# 复制配置文件和秘钥
sudo kubectl cp rook-ceph/rook-ceph-tools-fc5f9586c-2smzz:/etc/ceph/ceph.conf /etc/ceph/ceph.conf
sudo kubectl cp rook-ceph/rook-ceph-tools-fc5f9586c-2smzz:/etc/ceph/keyring /etc/ceph/keyring
ceph -s
```

## 四、操作

### 1、创建

```shell
ceph osd pool create rbd 16 16
ceph osd pool application enable rbd rbd
ceph osd lspools
```

### 2、rbd

>创建

```shell
rbd create -p rbd --image rook --size 1G
rbd ls rbd
rbd info rbd/rook
```
>使用

```shell
# 映射设备
sudo rbd map rbd/rook
rbd device list
lsblk | grep rbd

# 挂载
sudo mkfs.xfs /dev/rbd0
sudo mount /dev/rbd0 /media/
```

## 五、定制

- `nodeAffinity`：节点亲和
- `podAffinity`：pod亲和
- `podAntiAffinity`：pod反亲和
- `topologySpreadConstraints`：拓扑
- `tolerations`：污点容忍

>集群清理

```shell
kubectl delete -f operator.yaml
kubectl delete -f cluster.yaml
kubectl delete -f common.yaml
kubectl delete -f crds.yaml
```
>本地数据清理

```shell
# 文件数据
sudo rm -rf /var/lib/rook/
```
>格式化磁盘

```shell

cat << EOF |tee clean.sh
#!/usr/bin/env bash
DISK="/dev/sdb"

# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)

# You will have to run this step for all disks.
sgdisk --zap-all \$DISK

# Clean hdds with dd
dd if=/dev/zero of="\$DISK" bs=1M count=100 oflag=direct,dsync

# Clean disks such as ssd with blkdiscard instead of dd
blkdiscard \$DISK

# These steps only have to be run once on each node
# If rook sets up osds using ceph-volume, teardown leaves some devices mapped that lock the disks.
ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %

# ceph-volume setup can leave ceph-<UUID> directories in /dev and /dev/mapper (unnecessary clutter)
rm -rf /dev/ceph-*
rm -rf /dev/mapper/ceph--*

# Inform the OS of partition table changes
partprobe \$DISK
EOF
sudo sh clean.sh
```

### 1、定制mon

```yaml
...
  placement:
    mon:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: ceph-mon
              operator: In
              values:
              - enabled

...

  storage: # cluster level storage configuration and selection
    useAllNodes: false
    useAllDevices: false
...
```
>创建集群

```shell
kubectl apply -f crds.yaml -f common.yaml -f operator.yaml
kubectl apply -f cluster.yaml

kubectl get pods -n rook-ceph
kubectl label nodes ubuntu-vm-4-41 ceph-mon=enabled
kubectl label nodes ubuntu-vm-4-42 ceph-mon=enabled
kubectl label nodes ubuntu-vm-4-43 ceph-mon=enabled
```

### 2、定制mgr

```shell
    mgr:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: ceph-mgr
              operator: In
              values:
              - enabled
```
>重新应用

```shell
kubectl apply -f cluster.yaml
kubectl get pods -n rook-ceph
kubectl label nodes ubuntu-vm-4-41 ceph-mgr=enabled
kubectl label nodes ubuntu-vm-4-44 ceph-mgr=enabled
```

### 3、定制osd

```shell
    nodes:
    - name: "ubuntu-vm-4-41"
      devices: # specific devices to use for storage can be specified for each node
      - name: "sdb"
    - name: "ubuntu-vm-4-42"
      devices: # specific devices to use for storage can be specified for each node
      - name: "sdb"
    - name: "ubuntu-vm-4-43"
      devices: # specific devices to use for storage can be specified for each node
      - name: "sdb"
    - name: "ubuntu-vm-4-44"
      devices: # specific devices to use for storage can be specified for each node
      - name: "sdb"
```

### 4、资源使用限制

```shell
  resources:
# The requests and limits set here, allow the mgr pod to use half of one CPU core and 1 gigabyte of memory
    mgr:
      limits:
        cpu: "2000m"
        memory: "2048Mi"
      requests:
        cpu: "2000m"
        memory: "2048Mi"
    # 每1TB，消耗4GB
    osd:
      limits:
        cpu: "2000m"
        memory: "2048Mi"
      requests:
        cpu: "2000m"
        memory: "2048Mi"
```

### 5、健康探测

```shell
  healthCheck:
    daemonHealth:
      mon:
        disabled: false
        interval: 45s
      osd:
        disabled: false
        interval: 60s
      status:
        disabled: false
        interval: 60s
    # Change pod liveness probe, it works for all mon,mgr,osd daemons
    livenessProbe:
      mon:
        disabled: false
      mgr:
        disabled: false
      osd:
        disabled: false
```

## 六、RBD

>创建storageclass

```shell
kubectl apply -f rook/cluster/examples/kubernetes/ceph/csi/rbd/storageclass.yaml
kubectl get sc
```

>验证

```shell
cat <<EOF |sudo tee raw-block-pod-demo.yaml
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
  storageClassName: rook-ceph-block
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

kubectl apply -f raw-block-pod-demo.yaml
kubectl get pv,pvc
kubectl get pod
```
>演示Demo

```shell
kubectl apply -f rook/cluster/examples/kubernetes/mysql.yaml
kubectl apply -f rook/cluster/examples/kubernetes/wordpress.yaml
```
>Statefulset

```shell
cat << EOF |sudo tee rook-ceph-statefulset.yaml
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
        image: nginx
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
      storageClassName: "rook-ceph-block"
      resources:
        requests:
          storage: 1Gi
EOF

kubectl apply -f rook-ceph-statefulset.yaml
```

## 七、CephFS

>mds

```shell
kubectl create -f rook/cluster/examples/kubernetes/ceph/filesystem.yaml
kubectl -n rook-ceph get pods -l app=rook-ceph-mds
```
>storageclass

```shell
kubectl create -f rook/cluster/examples/kubernetes/ceph/csi/cephfs/storageclass.yaml
kubectl get sc
```

>测试

```shell
kubectl create -f rook/cluster/examples/kubernetes/ceph/csi/cephfs/kube-registry.yaml
```

>集群维护

## 八、Object

```shell
kubectl create -f object.yaml
kubectl -n rook-ceph get pod -l app=rook-ceph-rgw
```

>连接外部rgw集群

```yaml
apiVersion: ceph.rook.io/v1
kind: CephObjectStore
metadata:
  name: external-store
  namespace: rook-ceph
spec:
  gateway:
    port: 8080
    externalRgwEndpoints:
      - ip: 192.168.39.182
  healthCheck:
    bucket:
      enabled: true
      interval: 60s
```

### 1、创建bucket

>Storgeclass

```shell
kubectl create -f storageclass-bucket-delete.yaml
```
>创建bucket

```shell
kubectl create -f object-bucket-claim-delete.yaml
radosgw-admin bucket list
```
### 2、使用

>获取相关信息

```shell
# 获取主机
export AWS_HOST=$(kubectl -n default get cm ceph-delete-bucket -o jsonpath='{.data.BUCKET_HOST}')
# 获取access_key
export AWS_ACCESS_KEY_ID=$(kubectl -n default get secret ceph-delete-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
# 获取secret_key
export AWS_SECRET_ACCESS_KEY=$(kubectl -n default get secret ceph-delete-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)
echo $AWS_HOST
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
kubectl -n rook-ceph get service rook-ceph-rgw-my-store
```

>配置

```shell
kubectl -n rook-ceph exec -it rook-ceph-tools-fc5f9586c-vcdrz -- bash
yum install -y s3cmd
export AWS_HOST=rook-ceph-rgw-my-store.rook-ceph.svc
export AWS_ENDPOINT=10.96.173.39:80
export AWS_ACCESS_KEY_ID=3BT1H5REL197ONG96JZF
export AWS_SECRET_ACCESS_KEY=jlR5DDoiMa9yLEjyB3kRZRmTXk6WsvBPBBNlfLF5
s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key: 3BT1H5REL197ONG96JZF
Secret Key: jlR5DDoiMa9yLEjyB3kRZRmTXk6WsvBPBBNlfLF5
Default Region [US]:

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: rook-ceph-rgw-my-store.rook-ceph.svc:80

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: rook-ceph-rgw-my-store.rook-ceph.svc:80/%(bucket)s

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program [/usr/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: no

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can\'t connect to S3 directly
HTTP Proxy server name:

New settings:
  Access Key: 3BT1H5REL197ONG96JZF
  Secret Key: jlR5DDoiMa9yLEjyB3kRZRmTXk6WsvBPBBNlfLF5
  Default Region: US
  S3 Endpoint: rook-ceph-rgw-my-store.rook-ceph.svc:80
  DNS-style bucket+hostname:port template for accessing a bucket: rook-ceph-rgw-my-store.rook-ceph.svc:80/%(bucket)
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] y
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Not configured. Never mind.

Save settings? [y/N] y
Configuration saved to '/root/.s3cfg'
```
>测试

```shell
# 查看
s3cmd ls
# 上传文件
s3cmd put /etc/passwd s3://ceph-bkt-e76f591a-c9d6-4a2e-ae0d-82225c2454a6
s3cmd ls s3://ceph-bkt-e76f591a-c9d6-4a2e-ae0d-82225c2454a6
# 下载文件
s3cmd get s3://ceph-bkt-e76f591a-c9d6-4a2e-ae0d-82225c2454a6/passwd
```

### 3、外部访问

>配置NodePort

```shell
kubectl apply -f rgw-external.yaml
```

>创建用户

```shell
kubectl create -f object-user.yaml

kubectl -n rook-ceph describe secret rook-ceph-object-user-my-store-my-user
```

>配置

```shell
export AWS_ACCESS_KEY_ID=$(kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o jsonpath='{.data.AccessKey}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o jsonpath='{.data.SecretKey}' | base64 --decode)
s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key [3TJZK3ZLZYDFBGG9TZ7T]:
Secret Key [V3R0kWWVyWs1D19xVJD6hMjNmjgG7grTZGRwUDjW]:
Default Region [US]:

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: 172.16.4.41:31991

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: 172.16.4.41:31991/%(bucket)

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program [/usr/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: no

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can\'t connect to S3 directly
HTTP Proxy server name:

New settings:
  Access Key: 3TJZK3ZLZYDFBGG9TZ7T
  Secret Key: V3R0kWWVyWs1D19xVJD6hMjNmjgG7grTZGRwUDjW
  Default Region: US
  S3 Endpoint: 172.16.4.41:31991
  DNS-style bucket+hostname:port template for accessing a bucket: 172.16.4.41:31991/%(bucket)
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] y
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Not configured. Never mind.

Save settings? [y/N] y
Configuration saved to '/home/ubuntu/.s3cfg'
```

>测试

```shell
# 创建bucket
s3cmd mb s3://external-object
s3cmd ls

# 上传文件
s3cmd put /etc/passwd s3://external-object
s3cmd put -r rook s3://external-object
s3cmd ls s3://external-object

# 下载文件
s3cmd get s3://external-object/passwd
```

## 八、OSD

### 1、健康状态监控

```shell
ceph status
ceph osd tree
ceph osd status
ceph osd df
ceph osd utilization
```

### 2、osd扩容


>OSD配置项

```yaml
- name: "node-1"
  devices:
  - name: "sdc"
    config:
      metadataDevice: "/dev/sdc"
      databaseSizeMB: "4096"
      walSizeMB: "4096"
      deviceClass: "ssd"
```

### 3、OSD移除

>云原生移除

```shell
# 停止OSD
kubectl -n rook-ceph scale deployment rook-ceph-osd-6 --replicas=0
# 启用job，移除OSD
kubectl apply -f osd-purge.yaml
kubectl get job rook-ceph-purge-osd  -n rook-ceph
# 移除job
kubectl delete -f osd-purge.yaml
```
>手动移除

```shell
ceph osd out osd.7
ceph status
ceph osd down osd.7
ceph osd purge 7 --yes-i-really-mean-it
ceph osd tree
kubectl delete deployment -n rook-ceph rook-ceph-osd-7
```

## 九、Dashboard

>默认启用

```shell
# 获取密码
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```

>配置NodePort进行外部访问

```shell
kubectl create -f dashboard-external-https.yaml
kubectl -n rook-ceph get service
```