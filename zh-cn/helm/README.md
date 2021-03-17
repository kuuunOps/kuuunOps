# Helm

# Helm安装

```shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

# 镜像仓库

## 添加
```shell
helm repo add  aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
# 或
helm repo add  azure http://mirror.azure.cn/kubernetes/charts/
```

## 查看
```shell
helm repo list
NAME    URL
aliyun  https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
azure   http://mirror.azure.cn/kubernetes/charts/
```

## 删除
```shell
helm repo remove  azure
```


## 搜索镜像
```shell
helm  search repo mysql
```
