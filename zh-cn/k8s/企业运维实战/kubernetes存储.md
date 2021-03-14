# Kubernetes存储

# 管理应用程序配置

- ConfigMap
- Secret

---

## 1. ConfigMap

>`ConfigMap` 是一种` API `对象，用来将非机密性的数据保存到键值对中。使用时， Pods 可以将其用作环境变量、命令行参数或者存储卷中的配置文件。

创建ConfigMap后，数据实际会存储在K8s中Etcd，然后通过创建Pod时引用该数据。 

应用场景：应用程序配置 

Pod使用ConfigMap数据主要两种方式：
- 变量注入
- 数据卷挂载

**示例：ConfigMap配置**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data: 
  player_initial_lives: "30"
  ui_properties_file_name: "config.properties"
  game.properties: |
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice
```

**示例：Pod配置**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      env:
        # 定义环境变量
        - name: PLAYER_INITIAL_LIVES # 请注意这里和 ConfigMap 中的键名是不一样的
          valueFrom:
            configMapKeyRef:
              name: game-demo           # 这个值来自 ConfigMap
              key: player_initial_lives # 需要取值的键
        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name
      volumeMounts:
      - name: config
        mountPath: "/config"
        readOnly: true
  volumes:
    # 你可以在 Pod 级别设置卷，然后将其挂载到 Pod 内的容器中
    - name: config
      configMap:
        # 提供你想要挂载的 ConfigMap 的名字
        name: game-demo
        # 来自 ConfigMap 的一组键，将被创建为文件
        items:
        - key: "game.properties"
          path: "game.properties"
        - key: "user-interface.properties"
          path: "user-interface.properties"
```
应用` ConfigMap `与` Pod `的配置文件，进入` Pod `中，分别查看变量，数据卷
```shell
kubectl exec -it  configmap-demo-pod -- sh
/ # env
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
UI_PROPERTIES_FILE_NAME=config.properties
HOSTNAME=configmap-demo-pod
SHLVL=1
WEB_SERVICE_PORT=80
WEB_PORT=tcp://10.110.101.129:80
HOME=/root
WEB_PORT_80_TCP_ADDR=10.110.101.129
WEB_PORT_80_TCP_PORT=80
WEB_PORT_80_TCP_PROTO=tcp
TERM=xterm
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
WEB_PORT_80_TCP=tcp://10.110.101.129:80
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_SERVICE_PORT_HTTPS=443
PLAYER_INITIAL_LIVES=30
KUBERNETES_SERVICE_HOST=10.96.0.1
PWD=/
WEB_SERVICE_HOST=10.110.101.129
/ # cd config/
/config # ls
game.properties            user-interface.properties
/config # cat game.properties
enemies=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLRBABAS
secret.code.allowed=true
secret.code.lives=30
```

---

### 创建

语法格式：`kubectl create configmap NAME [--from-file=[key=]source] [--from-literal=key1=value1] [--dry-run=server|client|none]`

### 基于字面值创建，多用于Pod环境变量注入

```shell
kubectl create configmap my-config --from-literal=NAME=admin --from-literal=PASSWORD=123456
```

**配置样式**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  NAME: admin
  PASSWORD: "123456"
```

---

### 基于文件创建，多用于数据卷挂载配置

```shell
kubectl create configmap my-config --from-file=redis.conf
```

等效于
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  redis.conf: |
    redis_host = 127.0.0.1
    redis_port = 6379
    requirepass = '123456'
```

---

### 基于目录创建，多用于含有多个配置文件
  
```shell
kubectl create configmap my-config --from-file=config/
```

等效于
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  my.cnf: |
    [client]
    socket = /tmp/mysql.sock

    [mysqld]
    port = 3306
    user = mysql
    basedir = /usr/local/mysql
    datadir = /usr/local/mysql/data
    port=3306
    server-id = 1
    socket=/tmp/mysql.sock
    character-set-server = utf8

    [mysqldump]
    quick
    max_allowed_packet = 16M

    [myisamchk]
    key_buffer_size = 8M
    sort_buffer_size = 8M
    read_buffer = 4M
    write_buffer = 4
  redis.conf: |
    redis_host = 127.0.0.1
    redis_port = 6379
    requirepass = '123456'
```

---

### 基于环境变量文件创建，多用于注入的变量值过多

```shell
kubectl create configmap my-config --from-env-file=mysql.env
```

等效于
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  MYSQL_DATABASE: test
  MYSQL_PASSWORD: test
  MYSQL_ROOT_PASSWORD: "123456"
  MYSQL_USER: test
```

---

### 基于`kustomization.yaml`创建，不常用，一般用于`Secret`

`kustomization`配置样式
```yaml
configmapGenerator:
- name: my-config
  literals:
  - username=admin
  - password=123456
```

或

```yaml
configmapGenerator:
- name: my-config
  files:
  - my.cnf
  - redis.conf
```

创建
```shell
kubectl apply -k . 
```

---

## 2. Secret 

>` Secret `对象类型用来保存敏感信息，例如密码、` OAuth `令牌和 SSH 密钥。
>
>Kubernetes ` Secret `默认情况下存储为 base64-编码的、非加密的字符串。 

`kubectl create secret `支持主要的三种数据类型： 
- `docker-registry（kubernetes.io/dockerconfigjson）`：存储镜像仓库认证信息
- `generic（Opaque）`：存储密码、密钥等
- `tls（kubernetes.io/tls）`：存储TLS证书 

| 内置类型                              | 用法                                      |
| ------------------------------------- | ----------------------------------------- |
| `Qpaque` （默认数据类型）             | 用户自定义的任意数据                      |
| `kubernetes.io/service-account-token` | 服务账号令牌                              |
| `kubernetes.io/dockercfg`             | ` ~/.dockercfg `文件的序列化形式          |
| `kubernetes.io/dockerconfigjson`      | ` ~/.docker/config.json `文件的序列化形式 |
| `kubernetes.io/basic-auth`            | 用于基本身份认证的凭据                    |
| `kubernetes.io/ssh-auth`              | 用于 SSH 身份认证的凭据                   |
| `kubernetes.io/tls`                   | 用于 TLS 客户端或者服务器端的数据         |
| `bootstrap.kubernetes.io/token`       | 启动引导令牌数据                          |

1. 对数据进行编码
   ```shell
   # echo "123456"|base64
   MTIzNDU2Cg==
   ```

2. 将编码后的值放到`Secret`中
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: mysql-secret
   data:
     mysql_database: dGVzdA==
     mysql_password: dGVzdA==
     mysql_root_password: MTIzNDU2
     mysql_user: dGVzdA==
   ```
3. 创建` Pod `引入` Secret `中
   `Pod`中引入`Secret`数据和`ConfigMap`一样
   
   **示例Pod配置**
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: mysql
   spec:
     restartPolicy: Always
     containers:
     - image: mysql:5.7
       name: mysql
       ports:
       - containerPort: 3306
       env:
         - name: MYSQL_ROOT_PASSWORD
           valueFrom:
             secretKeyRef:
               name: mysql-secret
               key: mysql_root_password
         - name: MYSQL_DATABASE
           valueFrom:
             secretKeyRef:
               name: mysql-secret
               key: mysql_database
         - name: MYSQL_USER
           valueFrom:
             ecretKeyRef:
               name: mysql-secret
               key: mysql_user
         - name: MYSQL_PASSWORD
           valueFrom:
             secretKeyRef:
               name: mysql-secret
               key: mysql_password
   ```
