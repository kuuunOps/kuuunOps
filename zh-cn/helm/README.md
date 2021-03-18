# Helm

>Helm 是查找、分享和使用软件构建Kubernetes 的最优方式。

官网：https://helm.sh/zh/

Github：https://github.com/helm/helm/

---
# Helm 是什么？

Helm 帮助您管理 Kubernetes 应用——Helm 图表，即使是最复杂的 Kubernetes 应用程序，都可以帮助您定义，安装和升级。

---
# Helm概念

- `Chart`：代表着 Helm 包。它包含在 Kubernetes 集群内部运行应用程序，工具或服务所需的所有资源定义。你可以把它看作是 Homebrew formula，Apt dpkg，或 Yum RPM 在Kubernetes 中的等价物。
- `Repository`：是用来存放和共享 charts 的地方。
- `Release`：运行在 Kubernetes 集群中的 chart 的实例。

---
# Helm特点

- 复杂性管理
- 易于升级
- 分发简单
- 回滚

---
# Helm安装

## 下载安装包
   
下载地址：https://github.com/helm/helm/releases
```shell
# 国内需要科学上网
curl -o helm-v3.5.3-linux-amd64.tar.gz https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz
```

## 解压安装
```shell
tar xf helm-v3.5.3-linux-amd64.tar.gz
cd linux-amd64
mv helm /usr/local/bin/
ln -sf /usr/local/bin/helm /us/bin/helm
```
---

## Helm常用命令
| **命令**   | **描述**                                                                            |
| ---------- | ----------------------------------------------------------------------------------- |
| completion | 自动补全命令（`source <(helm completion bash)`）                                    |
| create     | 创建一个chart并指定名字                                                             |
| dependency | 管理chart依赖                                                                       |
| env        | helm环境变量信息                                                                    |
| get        | 下载一个release。可用子命令：all、hooks、manifest、notes、values                    |
| lint       | 检查chart是否有问题                                                                 |
| history    | 获取release历史                                                                     |
| install    | 安装一个chart                                                                       |
| list       | 列出release                                                                         |
| package    | 将chart目录打包到chart存档文件中                                                    |
| plugin     | 安装，列出、卸载helm插件                                                            |
| pull       | 从远程仓库中下载chart并解压到本地  # helm pull stable/mysql --untar                 |
| repo       | 添加，列出，移除，更新和索引chart仓库。可用子命令：add、index、list、remove、update |
| rollback   | 从之前版本回滚                                                                      |
| search     | 根据关键字搜索chart。可用子命令：hub、repo                                          |
| show       | 查看chart详细信息。可用子命令：all、chart、readme、values                           |
| status     | 显示已命名版本的状态                                                                |
| template   | 本地呈现模板                                                                        |
| uninstall  | 卸载一个release                                                                     |
| upgrade    | 更新一个release                                                                     |
| version    | 查看helm客户端版本                                                                  |

---
## 配置Chart仓库
- 微软（推荐）：http://mirror.azure.cn/kubernetes/charts/
- 阿里云：https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts 
- 官方：https://hub.kubeapps.com/charts/incubator

1. **添加仓库**
```shell
helm repo add stable http://mirror.azure.cn/kubernetes/charts/
helm repo update
```

2. **搜索**
```shell
helm search repo stable
```

3. **删除**
```shell
helm repo remove stable
```

---

# Helm基本使用

- `chart install`
- `chart upgrade`
- `chart rollback`

## 基本使用

### 1. 部署应用

**搜索chart**
```shell
helm search repo stable/mysql
```

**查看chart**
```shell
helm show chart stable/mysql
```

**安装chart**
```shell
helm install db stable/mysql
```

**查看状态**
```shell
helm status db
```

这时候`Pod`的状态属于`Pending`状态，是因为`Pod`在等待可用`PV`进行绑定，这时候我们就需要手动创建符合`PVC`要求的`PV资源`。

**PV示例**
```shell
cat > db-pv.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: db-pv
spec:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /data/project/nfs/kubernetes/db-pv
    server: 172.16.4.64
EOF
kubectl apply -f db-pv.yaml
```

### 2. 配置chart选项

- `--values (或 -f)`：使用 YAML 文件覆盖配置。可以指定多次，优先使用最右边的文件。
- `--set`：通过命令行的方式对指定项进行覆盖。

**查看可配置项**
```shell
helm show values stable/mysql
```

**应用新的配置项**
```shell
cat > values.yaml << EOF
persistence:
  enabled: true
  storageClass: "managed-nfs-storage"
  accessMode: ReadWriteOnce
  size: 8Gi
mysqlUser: "k8s"
mysqlPassword: "123456"
mysqlDatabase: "k8s"
EOF
helm install db -f values.yaml stable/mysql
```

或者
```shell
helm install db --set persistence.storageClass="managed-nfs-storage" stable/mysql
```

