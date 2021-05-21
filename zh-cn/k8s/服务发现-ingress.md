## 1. 常见的服务发现方式

- Service
- Headless
- NodePort
- hostPort
- Ingress

## 2. Ingress

Kubernetes文档：https://kubernetes.io/zh/docs/concepts/services-networking/ingress

Ingress 是对集群中服务的外部访问进行管理的 API 对象，典型的访问方式是 HTTP。Ingress 可以提供负载均衡、SSL 终结和基于名称的虚拟托管。

Ingress 公开了从集群外部到集群内服务的 HTTP 和 HTTPS 路由。 流量路由由 Ingress 资源上定义的规则控制。可以将 Ingress 配置为服务提供外部可访问的 URL、负载均衡流量、终止 SSL/TLS，以及提供基于名称的虚拟主机等能力。

使用`Ingress controller`通常负责通过负载均衡器来实现 Ingress，尽管它也可以配置边缘路由器或其他前端来帮助处理流量。

```yaml
# 简单的ingress样式
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```

>Ingress rules

- 主机名称（可选）
- 访问路径的列表（例如：`/testpath`）,路径中使用`service.name`，`service.port.name`或`service.port.number`定义关联的后端。
- 后端是服务中描述的服务和端口名称的组合

>DefaultBackend

没有匹配规则的Ingress将所有流量发送到单个默认后端。

>Resource backends

资源后端是与Ingress对象相同命名空间中另一个Kubernetes资源的Objectref。资源是具有服务的互斥设置，并且如果指定两者，则将失败验证。资源后端的常见用法是使用静态资产将数据进入对象存储后端。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-resource-backend
spec:
  defaultBackend:
    resource:
      apiGroup: k8s.example.com
      kind: StorageBucket
      name: static-assets
  rules:
    - http:
        paths:
          - path: /icons
            pathType: ImplementationSpecific
            backend:
              resource:
                apiGroup: k8s.example.com
                kind: StorageBucket
                name: icon-assets
```

>Path types

必须具有相应的路径类型所需的每个路径。

- ImplementationSpecific：使用此路径类型，匹配可以达到IntractClass。实现可以将其视为单独的路径类型或与其相同地处理以前缀或精确路径类型。
- Exact: 匹配URL路径完全呈现，符合案例灵敏度。
- Prefix: 基于URL路径前缀的匹配`/`分隔的路径。匹配区分大小写，按元素的路径元素完成。路径元素指的是由/分隔符分割的路径中的标签列表。

## 3. Ingress controller

>Ingress controller：https://kubernetes.io/docs/concepts/services-networking/ingress-controllers

>安装ingess-nginx

文档地址：
- https://github.com/kubernetes/ingress-nginx/blob/master/README.md
- https://kubernetes.github.io/ingress-nginx/deploy

### 1、下载Ingress

```shell
curl -o nginx-ingress.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/baremetal/deploy.yaml
```

### 2、配置

>修改镜像地址

```shell
# 修改前
      containers:
        - name: controller
          image: k8s.gcr.io/ingress-nginx/controller:v0.46.0@sha256:52f0058bed0a17ab0fb35628ba97e8d52b5d32299fbc03cc0f6c7b9ff036b61a
          imagePullPolicy: IfNotPresent

IMAGE="bitnami/nginx-ingress-controller:0.46.0"
sed -i "s#image: k8s.gcr.io/ingress-nginx/controller:v0.46.0.*#image: ${IMAGE}#" nginx-ingress.yaml

# 修改后
      containers:
        - name: controller
          image: bitnami/nginx-ingress-controller:0.46.0
          imagePullPolicy: IfNotPresent

```


>修改网络类型：hostNetwork

```shell
    spec:
      hostNetwork: true
      dnsPolicy: ClusterFirst
      containers:
        - name: controller
```

### 3、部署

```shell
kubectl apply -f nginx-ingress.yaml
```
>生产建议部署方案：deamonset+nodeAffinity

1. 在节点打上相应的label，例如：app=nginx
2. 添加nodeAffinity配置，例如：

```shell
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchFields:
      - key: app
        operator: In
        values:
        - nginx
```







