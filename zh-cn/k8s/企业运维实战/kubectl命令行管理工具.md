# Kubectl命令行管理工具

## kubeconfig配置文件

kubectl命令默认会读取`$HOME/.kube/config`配置文件，否则会访问`localhost:8080`。

或者使用参数`--kubeconfig`指定配置文件
```shell
kubectl get node --kubeconfig=admin.conf
```

## 文件格式：

**集群**
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: 
    server: https://172.16.4.6:6443
  name: kubernetes
```

**上下文**
```yaml
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
```

**当前上下文**
```yaml
current-context: kubernetes-admin@kubernetes
```

**客户端认证信息**
```yaml
users:
- name: kubernetes-admin
user:
    client-certificate-data: 
    client-key-data: 
```

## 牛刀小试

### 常见命令
[参考文献](https://kubernetes.io/zh/docs/reference/kubectl/overview/)
<table>
<thead>
  <tr>
    <th>命令类型</th>
    <th>命令</th>
    <th>描述</th>
  </tr>
</thead>
<tbody>
  <tr>
    <th rowspan="8">基础命令</th>
    <td>create</td>
    <td>通过文件名或标准输入创建资源</td>
  </tr>
  <tr>
    <td>expose</td>
    <td>为Deployment,Pod创建Service </td>
  </tr>
  <tr>
    <td>run</td>
    <td>在集群中运行一个特定的镜像 </td>
  </tr>
  <tr>
    <td>set</td>
    <td>在对象上设置特定的功能</td>
  </tr>
  <tr>
    <td>explain</td>
    <td>文档参考资料</td>
  </tr>
  <tr>
    <td>get</td>
    <td>显示一个或多个资源</td>
  </tr>
  <tr>
    <td>edit</td>
    <td>使用系统编辑器编译一个资源</td>
  </tr>
  <tr>
    <td>delete</td>
    <td>通过文件名、标准输入、资源名称或标签选择器来删除资源</td>
  </tr>
  <tr>
    <th rowspan="4">部署命令</th>
    <td>rollout</td>
    <td>管理Deployment、Daemonset资源的发布（例如状态、发布记录、回滚等）</td>
  </tr>
  <tr>
    <td>rolling-update</td>
    <td>滚动升级，仅限ReplicaionController</td>
  </tr>
  <tr>
    <td>scale</td>
    <td>对Deployment、ReplicaSet、RC或job资源扩容或缩容Pod数量</td>
  </tr>
  <tr>
    <td>autoscale</td>
    <td>为Deploy,RS,RC配置自动伸缩规则（依赖metrics-server和hpa）</td>
  </tr>
  <tr>
    <th rowspan="7">集群管理命令</th>
    <td>certificate</td>
    <td>修改证书资源</td>
  </tr>
  <tr>
    <td>cluster-info</td>
    <td>显示集群信息</td>
  </tr>
  <tr>
    <td>top</td>
    <td>查看资源利用率（依赖metrics-server）</td>
  </tr>
  <tr>
    <td>cordon</td>
    <td>标记节点不可调度</td>
  </tr>
  <tr>
    <td>uncordon</td>
    <td>标记节点可调度</td>
  </tr>
  <tr>
    <td>drain</td>
    <td>驱逐节点上的应用，准备下线维护</td>
  </tr>
  <tr>
    <td>taint</td>
    <td>修改节点taint标记</td>
  </tr>
  <tr>
    <th rowspan="7">故障诊断和调试命令</th>
    <td>describe</td>
    <td>显示资源详细信息</td>
  </tr>
  <tr>
    <td>logs</td>
    <td>查看Pod内容器日志，如果Pod有多个容器，-c参数指定容器名称</td>
  </tr>
  <tr>
    <td>attach</td>
    <td>附加到Pod内的一个容器</td>
  </tr>
  <tr>
    <td>exec</td>
    <td>在容器内执行命令</td>
  </tr>
  <tr>
    <td>port-forward</td>
    <td>为Pod创建本地端口映射</td>
  </tr>
  <tr>
    <td>proxy</td>
    <td>为Kubernetes API server创建代理</td>
  </tr>
  <tr>
    <td>cp</td>
    <td>拷贝文件或目录到容器中，或者从容器内向外拷贝</td>
  </tr>
  <tr>
    <th rowspan="4">高级命令</th>
    <td>apply</td>
    <td>从文件名或标准输入对资源创建/更新</td>
  </tr>
  <tr>
    <td>patch</td>
    <td>使用补丁方式修改、更新资源的某些字段</td>
  </tr>
  <tr>
    <td>replace</td>
    <td>从文件名或标准输入替换一个资源</td>
  </tr>
  <tr>
    <td>convert</td>
    <td>在不同API版本之间转换对象定义</td>
  </tr>
  <tr>
    <th rowspan="3">设置命令</th>
    <td>lable</td>
    <td>给资源设置、更新标签</td>
  </tr>
  <tr>
    <td>annotate</td>
    <td>给资源设置、更新注解</td>
  </tr>
  <tr>
    <td>completion</td>
    <td>kubectl工具自动补全，source<(kubectl completion bash) (依赖软件包bash-completion)</td>
  </tr>
  <tr>
    <th rowspan="5">其他命令</th>
    <td>api-resources</td>
    <td>查看所有资源</td>
  </tr>
  <tr>
    <td>api-versions</td>
    <td>打印受支持的API版本</td>
  </tr>
  <tr>
    <td>config</td>
    <td>修改kubeconfig文件（用于访问API，比如配置认证信息）</td>
  </tr>
  <tr>
    <td>help</td>
    <td>所有命令帮助</td>
  </tr>
  <tr>
    <td>version</td>
    <td>查看kubectl和k8s版本</td>
  </tr>
</tbody>
</table>

## 使用deployment控制器部署
```shell
kubectl create deployment web --image=lizhenliang/java-demo
kubectl get deploy,pods
```

## 使用service将pod暴露出去
```shell
kubectl expose deployment web --port=80 --target-port=8080 --type=NodePort
kubectl get service
```

**访问应用**

端口随机生成的，可以通过`get svc`获取
http://NodeIP:Port


## 基本资源概念

- Pod：k8s最小部署单元，一组容器的集合
- Deployment：最常见的工作负载控制器，用于更高级部署和管理Pod
- Service：为一组Pod提供负载均衡，对外提供统一访问入口
- Label：标签，附加到某个资源上，拥有关联对象、查询和筛选
  - 查看标签
  ```shell
  kubectl get pods --show-labels
  NAME                     READY   STATUS    RESTARTS   AGE     LABELS
  nginx-6799fc88d8-qt6wh   1/1     Running   1          7h11m   app=nginx,pod-template-hash=6799fc88d8
  web-674477549d-2c7v6     1/1     Running   0          5h27m   app=web,pod-template-hash=674477549d
  web-674477549d-d8mx8     1/1     Running   0          5m      app=web,pod-template-hash=674477549d
  web-674477549d-gtxqk     1/1     Running   0          5m      app=web,pod-template-hash=674477549d
  ```
  - 筛选
  ```shell
  kubectl get pods -l app=nginx
  NAME                     READY   STATUS    RESTARTS   AGE
  nginx-6799fc88d8-qt6wh   1/1     Running   1          7h12m
  ```
- Namespaces：命名空间，将对象逻辑上隔离，也利于权限控制，从而形成多个虚拟集群
  - 应用场景
    - 根据不同团队划分命名空间
    - 根据项目划分命名空间
  - `kubectl get namespace`查看命名空间
    - default：默认命名空间
    - kube-system：K8S系统方面的命名空间
    - kube-public：公开的命名空间，谁都可以访问
    - kube-node-lease：K8S内容命名空间
  - 命名空间的指定
    - 命令行：`-n`
    - 配置文件：`namespace`字段
  - 创建命名空间
  ```shell
  kubectl create namespace test
  ```