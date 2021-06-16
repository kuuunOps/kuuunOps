# Istio

**云原生业界定义和技术发展趋势**

>CNCF对云原生定义：云原生技术有利于各组织在公有云、私有云和混合云等新型动态环境中，构建和运行可弹性扩展的应用。

>云原生的代表技术包括容器、服务网格、微服务、不可变基础设施和声明式API

>服务治理与业务逻辑逐步解耦，服务治理能力下沉到基础设施。

## 服务网格的概念介绍

>服务网格以基础设施的方式提供无侵入的连接控制、安全、可检测性、灰度发布等治理能力。

>服务网格是一个云原生的、应用层的网络技术

- 云原生：面向弹性、（微）服务化、去中心化业务场景
- 应用层：以应用为中心，关注应用的发布、监控、恢复等
- 网络：关注应用组件之间的接口、流量、数据、访问安全等

>Istio是一种云原生的、应用层的、网络技术、用于解决组成应用的组件之间的连接、安全、策略、可观察性等问题。

1. 容器和微服务共同的轻量、敏捷的特点，微服务运行在容器中日益流行
2. Kubernetes在容器编排领域成为事实标准
3. Istio提供Service Mesh方式无侵入微服务治理能力，成为微服务治理的趋势
4. Istio和Kubernetes紧密结合。基于Kubernetes构建，补齐了Kubernetes的治理能力，提供了端到端的微服务运行治理平台

>对于云原生应用，采用Kubernetes构建微服务部署和微服务管理能力，采用Istio构建服务治理能力，将逐渐成为应用微服务转型的标准配置。

Istio概念初识

**服务代理**

- 服务联通
- 流量控制
- 服务重试
- 服务熔断
- 链路安全
- 可观察性
- 可控制性


**控制面组件**

- Citadel
- Pilot
- Galley


**配置文件**

- Gateway

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: weather-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  server:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
```

- Virtual Service

```shell
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: frontend-route
  namespace: weather
spec:
  hosts:
  - "*"
  gateways:
  - istio-system/weather-gateway
  - match:
    - port: 80
    route:
    - destination:
        host: frontend
        subset: v1
```