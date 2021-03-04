# 深入理解Service

## Service存在的意义

>Service引入主要是解决Pod的动态变化，提供统一访问入口： 

- 防止Pod失联，准备找到提供同一个服务的Pod（服务发现）
- 定义一组Pod的访问策略（负载均衡）

**Pod与Service的关系**
- Service通过标签关联一组Pod 
- Service使用iptables或者ipvs为一组Pod提供负载均衡能力


## Service定义与创建

**示例配置**
```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: web
  name: default
spec:
  ports:
    # 端口
  - port: 80
    # 协议
    protocol: TCP
    # 目标容器端口
    targetPort: 80
  # 标签选择器
  selector:
    # 指定关联Pod的标签
    app: nginx
  # 服务类型
  type: ClusterIP
```

**创建**
```shell
kubectl apply -f example-service.yaml
```

**查看**
```shell
kubectl get service
# 查看后端绑定的pod
kubectl get ep
```


