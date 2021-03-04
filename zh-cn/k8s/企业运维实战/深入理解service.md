# 深入理解Service

## Service存在的意义

>Service引入主要是解决Pod的动态变化，提供统一访问入口： 

- 防止Pod失联，准备找到提供同一个服务的Pod（服务发现）
- 定义一组Pod的访问策略（负载均衡）

**Pod与Service的关系**
- Service通过标签关联一组Pod 
- Service使用iptables或者ipvs为一组Pod提供负载均衡能力