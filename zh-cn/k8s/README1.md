## 容器的基本实现原理

- Namespace
  用来修改进程视图的主要方法。
- Cgroups
  用来制造约束的主要手段。最主要的作用，就是限制一个进程组能够使用的资源上限，包括 CPU、内存、磁盘、网络带宽等等。
- rootfs

容器，其实是一种特殊的进程而已。

---

## kubernetes架构中组件有哪些？

- Master：控制节点
  - `kube-apiserver`：负责API服务
  - `kube-scheduler`：负责调度PODs的相关工作
  - `kube-controler-manager`：负责容器编排
    - `Node Controller`： 负责在节点出现故障时进行通知和响应
    - `Job controller`：监测代表一次性任务的 Job 对象，然后创建 Pods 来运行这些任务直至完成
    - `Endpoints Controller`：负责Service与pod对应端点关系
    - `Service Account & Token Controllers`：为新的命名空间创建默认帐户和 API 访问令牌
  - etcd：负责保存集群数据的数据库
- Node：
  - `kubelet`：负责同容器运行时
  - `kube-proxy`：负责每个节点运行的网络代理，用以控制集群内部和集群外部与POD进行的通信
  - `Container Runtime`：容器运行环境是负责运行容器的软件。