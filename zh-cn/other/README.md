## 应知应会

1. MySQL主从复制原理？

- I/O线程。该线程连接到master机器，master机器上的binlog dump线程会将binlog的内容发送给该I/O线程。该I/O线程接收到binlog内容后，再将内容写入到本地的relay log。
- SQL线程。该线程读取I/O线程写入的relay log。并且根据relay log的内容对slave数据库做相应的操作。
---
2. redis集群复制原理？

---
3. k8s组件有哪些？作用分别是什么？

- `etcd`：保存了整个集群的状态;
- `apiserver`：提供了资源操作的唯一入口，并提供认证、授权、访问控制、API注册和发现等机制;
- `controller manager`：负责维护集群的状态，比如故障检测、自动扩展、滚动更新等;
- `scheduler`：负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上;
- `kubelet`：负责维护容器的生命周期，同时也负责Volume(CVI)和网络(CNI)的管理;
- `Container runtime`：负责镜像管理以及Pod和容器的真正运行(CRI);
- `kube-proxy`：负责为Service提供cluster内部的服务发现和负载均衡;
---
4. Deployment与Statefulset区别是什么？

Deployment：无状态的应用

1. pod之间没有顺序
2. 所有pod共享存储
3. pod名字包含随机数字
4. service都有ClusterIP,可以负载均衡
---
StatefulSet：有状态的应用

1. 部署、扩展、更新、删除都要有顺序
2. 每个pod都有自己存储，所以都用volumeClaimTemplates，为每个pod都生成一个自己的存储，保存自己的状态
3. pod名字始终是固定的
4. service没有ClusterIP，是headlessservice，所以无法负载均衡，返回的都是pod名，所以pod名字都必须固定，StatefulSet在Headless Service的基础上又为StatefulSet控制的每个Pod副本创建了一个DNS域名:$(podname).(headless server name).namespace.svc.cluster.local

---
5. Pod的生命周期是怎样的？

| 阶段      | 描述                                                                                                                               |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Pending   | Pod 已被 Kubernetes 接受，但尚未创建一个或多个容器镜像。这包括被调度之前的时间以及通过网络下载镜像所花费的时间，执行需要一段时间。 |
| Running   | Pod 已经被绑定到了一个节点，所有容器已被创建。至少一个容器正在运行，或者正在启动或重新启动。                                       |
| Succeeded | 所有容器成功终止，也不会重启。                                                                                                     |
| Failed    | 所有容器终止，至少有一个容器以失败方式终止。也就是说，这个容器要么已非 0 状态退出，要么被系统终止。                                |
| Unknown   | 由于一些原因，Pod 的状态无法获取，通常是与 Pod 通信时出错导致的。                                                                  |
