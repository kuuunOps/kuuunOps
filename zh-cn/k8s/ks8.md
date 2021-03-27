#### 给一个pod创建service，并可以通过ClusterIP/NodePort访问
>考察点：创建Service资源
```shell
# 创建deployment
kubectl create deployment web --image=nginx --replicas=3
# 创建Service
kubectl expose deployment web --port=80 --target-port 80 --type=NodePort
```
验证
```shell
$ kubectl get svc web
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web    NodePort   10.109.209.17   <none>        80:31395/TCP   25s
# 通过集群IP访问
$ curl -I 10.109.209.17
HTTP/1.1 200 OK
Server: nginx/1.19.6
Date: Sat, 27 Mar 2021 13:20:56 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 15 Dec 2020 13:59:38 GMT
Connection: keep-alive
ETag: "5fd8c14a-264"
Accept-Ranges: bytes
# 通过节点IP访问
$ curl -I 172.16.4.41:31395
HTTP/1.1 200 OK
Server: nginx/1.19.8
Date: Sat, 27 Mar 2021 13:21:20 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 09 Mar 2021 15:27:51 GMT
Connection: keep-alive
ETag: "604793f7-264"
Accept-Ranges: bytes

```
---
#### 任意名称创建deployment和service，使用busybox容器nslookup解析service
>考察点：了解service的作用
```shell
$ kubectl get svc web
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web    NodePort   10.109.209.17   <none>        80:31395/TCP   6m6s

$ kubectl run --rm -it --image=busybox:1.28.4 -- sh
If you don't see a command prompt, try pressing enter.
/ # nslookup web
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web
Address 1: 10.109.209.17 web.default.svc.cluster.local
/ #

```

---

#### 列出命名空间下某个service关联的所有pod，并将pod名称写到/opt/pod.txt文件中（使用标签筛选）

- 命名空间：default 
- service名称：web
>考察点：labels的使用

```shell
$ kubectl get svc web
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web    NodePort   10.109.209.17   <none>        80:31395/TCP   15m
$ kubectl get pods -l app=web -o name >/opt/pod.txt
$ cat /opt/pod.txt
web-96d5df5c8-5tsdv
web-96d5df5c8-8jxtv
web-96d5df5c8-wppm8

```
---

#### 使用Ingress将美女示例应用暴露到外部访问
>考察点：Ingress的使用

1. 创建deployment
```shell
kubectl create deployment demo --image=lizhenliang/java-demo --port=8080
```

2. 创建Service
```shell
kubectl expose deployment demo --port=80 --target-port=8080
```

3. 创建Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress 
metadata: 
  name: tomcat-demo-ingress
spec: 
  rules: 
  - host: demo.kuuun.com
    http: 
      paths: 
      - path: "/"
        pathType: Prefix 
        backend: 
          service: 
            name: demo 
            port: 
              number: 80
```

4. 浏览器验证

![](../../_media/demo-ingress.png)

---

查所有节点的污点

```shell
kubectl get nodes -o custom-columns=NODE:.metadata.name,TAINTS:.spec.taints[0].key
NODE         TAINTS
k8s-master   node-role.kubernetes.io/master
k8s-node1    <none>
k8s-node2    <none>

```