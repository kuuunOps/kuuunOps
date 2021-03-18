# 管理应用程序配置

- ConfigMap
- Secret

---

# 1. ConfigMap

>`ConfigMap` 是一种` API `对象，用来将非机密性的数据保存到键值对中。使用时， Pods 可以将其用作环境变量、命令行参数或者存储卷中的配置文件。

创建ConfigMap后，数据实际会存储在K8s中Etcd，然后通过创建Pod时引用该数据。 

应用场景：应用程序配置 

Pod使用ConfigMap数据主要两种方式：
- 变量注入
- 数据卷挂载


## 创建

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

### 基于变量文件创建，多用于注入的变量值过多

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

## 使用

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

# 2. Secret 

>`Secret`对象类型用来保存敏感信息，例如密码、` OAuth `令牌和 SSH 密钥。
>
>在`Kubernetes`中的`Secret`默认情况下存储为 base64-编码的、非加密的字符串。 


## 创建

`Secret`支持的三种数据类型： 

- `docker-registry`：创建用于存储镜像仓库认证信息的密文。
- `generic`：根据文件、目录或指定的文字创建一个通用类型的密文。
- `tls`：给指定的公钥/私钥对创建一个TLS密文。

---

### 创建`docker-registry`的密文

语法格式：`kubectl create secret docker-registry NAME --docker-username=user --docker-password=password --docker-email=email [--docker-server=string] [--from-literal=key1=value1]`[--dry-run=server|client|none] [options]

```shell
kubectl create secret docker-registry my-secret --docker-username=admin --docker-password=123456
```

等效于
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOnsidXNlcm5hbWUiOiJhZG1pbiIsInBhc3N3b3JkIjoiMTIzNDU2IiwiYXV0aCI6IllXUnRhVzQ2TVRJek5EVTIifX19
```

---
### 创建通用模式密文

语法格式：`kubectl create secret generic NAME [--type=string] [--from-file=[key=]source] [--from-literal=key1=value1] [--dry-run=server|client|none] [options]`

- **基于字面值创建，多用于环境变量使用**

```shell
kubectl create secret generic my-secret --from-literal=MYSQL_ROOT_PASSWORD=123456
```

等效于
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
data:
  MYSQL_ROOT_PASSWORD: MTIzNDU2
```

- **基于文件创建，多用于数据卷挂载**

```shell
kubectl create secret generic my-secret --from-file=.ssh/id_rsa --from-file=.ssh/id_rsa.pub
```

等效于
```shell
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
data:
  id_rsa: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBb3ZZSS80T1VPT3VGbExaVjVEYWcyWVkzL3c2NVN3dGxNUThwRVhVaG44bDZhM2x0CmdaWVNlakZKaEhPNnM3QTk2ZkdieWJtQWp5MTNIaCsvTTlGUEphc2kzcjAzMkNqY3U0YnlDRDQzZzIvTEREd0kKeDVsdFpEYzliU3MyWXNLSHBRYjNTbENmUFlyVitJK0dZMW5kY1RyUXg4eHM5Y1Z0Wm1YM2RtOW9WbmpMekpjdgo2YjlRbHl1SXA4R1VNSXNGMHd0MG9TNnU5eDJhbmN5RWE0WTYyaFI5TjdPQzlUZjFsZmhEMWViSXNqcm9oUGVBCm9zZXBLQTVKemREV1A3Y2RpQVA3ejhMSnVJVnFTRlprcXRmR3VZcUZkc3I4WkIwWHVLQmR6bHVUS0x3Si9XeGoKeUZrWWg4YlI0MU5ON04xemxmTTdFazl5MEhadlhNYzBUNllRUlFJREFRQUJBb0lCQVFDTDBabHEwZFJNK2hjRQp2MlQyaDhCK29tQk5JSzd1cW5wS0czM2JFcXFrMUZPSy93WnIxdjFIaGg1VDNJL21PR01HNUZ3TU9uTUpaYkw4ClQ3VFhtdERUdXdBU0tEdFA1Yzl0dnB6UFljSnpyV21EdDhhNHF2Vm10TmFwWWhncHFFcUYxM0k1ZXU4RitLY1oKdXR0TlJ2OXVkVTVJL3liRndIemJETVhFQWxaOVNZemRXL3JoMlg3cmxoWUxZRmlSUENadVZpNURDbkZrTE9zRgpnR1lxeTFoR1RRekcwcFgwTXpjeTUwV2tiQ3N4OVZGSnBpalhpd0M3eGcwNjZLdFk2bVNaT25MdmhTVE5iZjBjCjdwelFtUVVMRlFoWVJZeFh2SlFwUXZIT3NaZmluTUxidnNGUURSR1dLR0gyL3JSdDRLYnI5RjZ5WUJsQytKWE8KZ2h1SXdTRkpBb0dCQU03TXRtSWdwbm5CV2d5Smo1aHpwSFVwSFhPMk12VTBmMTM1MnZ4M1h0RkFzS3duTHdZbgp5eGV2elRnek0vUE5ub21pUWpsZk55WFRqZDMwTG9tK2hHbll0TENKTC9FTzJpeE0za0pkam1BVHJIRSt0TytiCm5TVEIrTVFmVml4YWZVVW1hWjlyQVdNL1dQMmtGSWh4bXFFMGpyN0R6cTBaRC9VVUJvbTl1VFBMQW9HQkFNbTcKVFJObHhlQTMwTmNNS2ljbFFVc2RNN2lyYklwUlprQkZoY0ttdElQVEUzbHFlM3pmS0VtR2JBNVNzdWY4a0tESApBd2NVdFdFM3JlWURncXltcjdqWmJVUzZuMUhBOEZtZlRoaGhhMjRCTWVXNGZlZHRQL0ovOWNHNDF1cGpRTXJ3Ck1HMFZ5a2ltTW5xcFNNcEFCbXZ3OWliWk9KaFNJVXpKMEZQV0t1b3ZBb0dBVHBsMkZKUE9VbWFQNEVZRWd2QXAKS0xLbzFBc0RFVG1UMDFjY3lXcGhhbTBJK1ZXblJOS3BHV2FqUEdJUnMrK0orMHZsbWNLN3hpL0RNd0lWRWh1TQpYbUtVUXFqUnhQQmRNZ3RCU3I0ZVdCd0NKY1NzcG9saHo4Kzl5bVVTcnFieUIrOVNvOW5hM0NyK211RGJRUVRVCnZjS3BJbzV2cGxEcFJNQUl3QitSSGNNQ2dZQUtzeGgvY3VKdjVnWDVvZmVLWS90MmxISHQxWW5JUEZFRUQ2dnMKaXhMLyt1NEpmcEJXS3kvajFuRmN3UjRrRjgxRCtjbzdVZW5jNGlzakRBU2VTNmorVU9udXYwYzcrdFBFclNKagpRS2VHQ2lJdllQMnNqS3JibmRYWEZJcXhtOW9QNlhWb0U4UEszcVhHdzd2TW5tQzQwT3I5WElBWDlDTTRBMnc5ClJocTRtUUtCZ1FDK0dSeVAvbzhVYVRlM3lMOXZyR3ZYMGIrYVNtSkJlTmh0RGpLNTB2d0pYYU85WFg2M1AvTGcKcTBJa1JZVzZORTNUWXYwb2huM2dvdjZXRG9TTVBDWHMwRmEwZTdQbm5Pa1RwNVNKejRvb3l0c1ozTk1vMmlTWApQTFRPTHRmZHFKdE9SbjBrRityNDdKd3c3Q3RrT3ZTUlhFcDhtVytVdVlzYmY4QmJyWlZzSGc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
  id_rsa.pub: c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCQVFDaTlnai9nNVE0NjRXVXRsWGtOcURaaGpmL0RybExDMlV4RHlrUmRTR2Z5WHByZVcyQmxoSjZNVW1FYzdxenNEM3A4WnZKdVlDUExYY2VINzh6MFU4bHF5TGV2VGZZS055N2h2SUlQamVEYjhzTVBBakhtVzFrTnoxdEt6Wml3b2VsQnZkS1VKODlpdFg0ajRaaldkMXhPdERIekd6MXhXMW1aZmQyYjJoV2VNdk1seS9wdjFDWEs0aW53WlF3aXdYVEMzU2hMcTczSFpxZHpJUnJoanJhRkgwM3M0TDFOL1dWK0VQVjVzaXlPdWlFOTRDaXg2a29Ea25OME5ZL3R4MklBL3ZQd3NtNGhXcElWbVNxMThhNWlvVjJ5dnhrSFJlNG9GM09XNU1vdkFuOWJHUElXUmlIeHRIalUwM3MzWE9WOHpzU1QzTFFkbTljeHpSUHBoQkYgcm9vdEBjZW50b3Mtdm0tNC02NAo=
```

- **基于变量文件引入，多用于有多个加密字段**

```shell
kubectl create secret generic my-secret --from-env-file=mysql.env
```
等效于
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
data:
  MYSQL_PASSWORD: dGVzdA==
  MYSQL_ROOT_PASSWORD: MTIzNDU2
  MYSQL_USER: dGVzdA==
```
---
### 创建TLS的密文

语法格式：`kubectl create secret tls NAME --cert=path/to/cert/file --key=path/to/key/file [--dry-run=server|client|none] [options]`

```shell
kubectl create secret tls my-secret --cert=www.kuuun.com.pem --key=www.kuuun.com-key.pem
```

等效于
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQ5VENDQXQyZ0F3SUJBZ0lVV2JFeUd1cXh1NjY3d0lVK3dUWnZyYnVON0k4d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lqRUxNQWtHQTFVRUJoTUNRMDR4RWpBUUJnTlZCQWdUQ1VkMVlXNW5aRzl1WnpFUk1BOEdBMVVFQnhNSQpVMmhsYm5wb1pXNHhDekFKQmdOVkJBb1RBa05CTVE4d0RRWURWUVFMRXdaRVpYWnZjSE14RGpBTUJnTlZCQU1UCkJVdDFkWFZ1TUI0WERUSXhNRE14TWpBM01UY3dNRm9YRFRNeE1ETXhNREEzTVRjd01Gb3dhakVMTUFrR0ExVUUKQmhNQ1EwNHhFakFRQmdOVkJBZ1RDVWQxWVc1blpHOXVaekVSTUE4R0ExVUVCeE1JVTJobGJucG9aVzR4Q3pBSgpCZ05WQkFvVEFrTkJNUTh3RFFZRFZRUUxFd1pFWlhadmNITXhGakFVQmdOVkJBTVREWGQzZHk1cmRYVjFiaTVqCmIyMHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEQlRyZFc5MzlGSVZ6UE5JMkcKdDM5SWxmdkc2YmFGd1FueDdlVktkaEFoMlBPV2hnYWU4ejF0MzZaeWNQY2lXdkxEWk1FWUVUYkJJbXBheXMxRApKWDl0Vm5LeDZzZ000a1lxMHlVdkpOdzluVkdVbHNKNFFDMHJ3aG5CWjhWZnh1VzhqS0h3K3dYTUcramdtTE1YCmlUS2kzUFJLaldtdHY4Rk12MGhKTXJLbEtQRHZkN2cwbEJhQmJJK3R5aVRjWHhadVFOWTJEak5EZm9obVhjaGwKeURFK3dNcDNtRWhlb0RHc0xIeUdLM2E5MDlES1FoS3Y2cXYrTEhibkJXK2lBT0JYQjZuWXovR2k2NnRhWVk3cQpKRHhiUGJYSlNXcmNDWG1nOENaWFU3Q3RabC92Y1kzTmlNZTRWdkhVRzVWeEJZR2RaNmRJSWF4dmZSaVBTa3pqCnJsVFRBZ01CQUFHamdab3dnWmN3RGdZRFZSMFBBUUgvQkFRREFnV2dNQjBHQTFVZEpRUVdNQlFHQ0NzR0FRVUYKQndNQkJnZ3JCZ0VGQlFjREFqQU1CZ05WSFJNQkFmOEVBakFBTUIwR0ExVWREZ1FXQkJRTWhtQ0NGRVdnd3VFLwowZ2FuMURFWUdmOGhmREFmQmdOVkhTTUVHREFXZ0JSaGNjTURQbUZJYUl1bEJFazFyYmUyalQxSXNUQVlCZ05WCkhSRUVFVEFQZ2cxM2QzY3VhM1YxZFc0dVkyOXRNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUFyS3JiQVFaaE4KS2Y4SnQweTNLZDB5NUhQNVFDUWozejJsZUswOUpVeGVmb0V4NHRnWFdCRkNxNDJ0M1d6QnF2b1JWblE4OTZZSAp0ZWx4UUVYbjBzOTZYVFpJdjVQNG1tdFB5NGxpc2wxYlpIdUxZSHN1eUluNFZ3MnJ5YTFNL1R3TWlSU2JHT3ZDCkI2aE9XZUJuQVVpY3FSdmdlSGhUd1dZM0RrdlorekhDUzlHZFZqWExpdTRsRlFnZmhHUUtGWCtsY1l2Wk1ReWUKSW5tTWhsWUpRUE1GTHpDOFJ0L0hzY2h5Tm9mQzhHT1R4THBHSUROaCs0Wld5Umk1RzIvQUM1VjYyeGwrOVM1SgpwN1FjQXByeENBTG1PNVVkdFE2S1piQ3lvUWxXRXd4YW4zcmM3dThzS2ZtcUJrK1FpVEhZYlVDM1lockY5RWtjCm1ZQU0vRU5Kc1RjZgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBd1U2M1Z2ZC9SU0ZjenpTTmhyZC9TSlg3eHVtMmhjRUo4ZTNsU25ZUUlkanpsb1lHCm52TTliZCttY25EM0lscnl3MlRCR0JFMndTSnFXc3JOUXlWL2JWWnlzZXJJRE9KR0t0TWxMeVRjUFoxUmxKYkMKZUVBdEs4SVp3V2ZGWDhibHZJeWg4UHNGekJ2bzRKaXpGNGt5b3R6MFNvMXByYi9CVEw5SVNUS3lwU2p3NzNlNApOSlFXZ1d5UHJjb2szRjhXYmtEV05nNHpRMzZJWmwzSVpjZ3hQc0RLZDVoSVhxQXhyQ3g4aGl0MnZkUFF5a0lTCnIrcXIvaXgyNXdWdm9nRGdWd2VwMk0veG91dXJXbUdPNmlROFd6MjF5VWxxM0FsNW9QQW1WMU93cldaZjczR04KellqSHVGYngxQnVWY1FXQm5XZW5TQ0dzYjMwWWowcE00NjVVMHdJREFRQUJBb0lCQUJscDUrQ2ZHVFJWZG9ZbgpPcFFEZTlCbkozcTNMeS9XZVNBOVRtL0RwY3ROWW5qZmxlOC91MHUrbzN0WUxxVnRuNHpncWlJbjRUTHkrMWlFCllRZjYzZzNaMTZwY1c0Q1dIdk55WHVrYngzaXlQZzl5NG80OG9iT25DUXZNUUw2ZXY0VlNWOWYrcUh4MUR1QzQKTXBOZGpqS3JLZExEVktsckZGYXFyeTR3WkJ3aVUwaENoYSs0dzB1cUZ0dWphWGt1ZStkV2xjWkt5ZGhSSDBHUwpNNFBSems4VTJiVDcxWWRUblB6a29yQmt5THI0UjRUMjZTYWowYmZNblN6YkkrVzZKckpZdW9EYnhvYTQzUDFtCi9xNFRBcCs3MnpEYS9ndDYwK3hENWZUY0hIaGttMnpBd1h0SGdPR0g3WWxLVmR1aUV1c05ENWd1ZUFERnlwakkKcFNEaDFzRUNnWUVBMlN6dEdFck1Sa085c2NYc1cxWlUxMzJNZWtoWVBaOHgxTjNzYTVSb3BSQlZ2WkRmaWNqdQpXa3RMMXkyWDRTWWFFeWxHYk5acUhXdUJHVEN2cVBCd29DQ1gyN3UvcW5Dc212QWdacVVnYTBJNzJhaWMrVFNDCnpYRFdGYWdWQjVXeDZONHJmMXUzN0k3VHdsUmtaenBTelFJaHYybWE1YmZXeU9LQUpOY1lUOGNDZ1lFQTQ5MTMKYnFTb0hDd3IwaGFnRWx3MDRWb3JEa3RZeHpMVWNHd2RFUTBkWjR5d3JCcWMyL2NkM1lzanNGNU1BUW9ISi9ZZwpFay8zS0VGdExlUXpobjFUKzJKdGhaR1dIcmFwY1RXYTRyWWJ6YkE2V0UybkFuVWJ1Z0JVZVFMYVVBOWFnSWp5CjZqSFlrNVdrQS9iT1F6RCt6OG9ablkxS29pSnc5NGdXaFBHRTZwVUNnWUVBaWUrdjgyTG1sYVpHNEplZVJIRHoKMkI1a3ovSU5JYTV2L3d5cE1iY0VNL3JKQ21ydW45dmdEN2VOUnZFdGF4SkJNM1JleDVmenRCWG8zREFCRWVNTgpGWmM5L0pFbDdrSThUdmcvREJMTElYVGpBSjdJZkx1dWJIL0RhZVBrMzNsamswMHhBV1ltem5mMDVaT21aYTQwCmt3Tk1uZitjSTFWOWRQL3ZkZmFyK1ZjQ2dZRUExTVdjSEVqTVlXSXRtUU5mZlVWMGEybFRBd29BWUNGcWxYK2UKdEtsV1o3YkwwaWtYaDU1ODJMNXdHT1EwZkZQczByZlV3c1RBdVdvK2xMZWVGVnM1N0diQWRoUzM1UDRUd282WApqbE1XS3o3L2ZDMG1ZZmtRWnVLZi9rOVhvNkp5azh0TmFMb2F6ZFRSVHBKTGtCcFVGWnRWeC9TRFdGcG91ZnJ0CmJENUtLdkVDZ1lBS0YzbTdWeXJBMUk5K3FGQmJBMlYzWjVLSFZDZVo3czcwaHU1ZW1TMEI0UXRhRzFmQTNGZkIKNnllV2NTdWJQYTFQVUF2NldmMHpGWExxTS82QVJ5VnF5TVBXMzl5alp5anVscVNPU0RkV0Y0Vm5PRi9xajVIVApBdXNSckxqVDdMdStkbnByTUMyUE1rcFV3TGVIN2pHZVpsanhST29GOHdCSDcwenJVYkppS3c9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
```

---
### 基于`kustomization.yaml`创建

`kustomization`配置样式
```yaml
secretGenerator:
- name: my-secret
  literals:
  - MYSQL_ROOT_PASSWORD=123456
  - MYSQL_USER=test
  - MYSQL_PASSWORD=test
```

或

```yaml
secretGenerator:
- name: my-secret
  files:
  - mysql.txt
```

创建
```shell
kubectl apply -k . 
```

---

## 使用

1. **编码**

  **示例**
  ```shell
  # echo "123456"|base64
  MTIzNDU2Cg==
  ```

2. **创建`Secret`**

  **示例**
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

3. **`Pod`引入**

  `Pod`中引入`Secret`数据和`ConfigMap`一样，支持环境变量和数据卷挂载。
   
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

  ---