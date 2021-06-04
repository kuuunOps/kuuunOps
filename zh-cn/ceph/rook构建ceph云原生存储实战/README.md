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
blkdiscard $DISK

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
    all:
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