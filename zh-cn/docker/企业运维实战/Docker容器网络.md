# Docker容器网络

四种网络模式

- **bridge**

` -net=bridge ` 默认网络，Docker启动后创建一个docker0网桥，默认创建的容器也是添加到这个网桥中。 也可以自定义网络，相比默认的具备内部DNS发现，可以通过容器名容器之间网络通信。

- **host**

`–net=host ` 容器不会获得一个独立的network namespace，而是与宿主机共用一个。这就意味着容器不会有自己的网卡信息，而是使用宿主机的。容器除了网络，其他都是隔离的。

- **none**

`-net=none ` 取独立的network namespace，但不为容器进行任何网络配置，需要我们手动配置。

- **container**

`–net=container:Name/ID `与指定的容器使用同一个` network namespace `，具有同样的网络配置信息，两个容器除了网络，其他都还是隔离的。

## 网络模式：bridge详解

**查看网络**
```shell
docker network ls
```

**创建网络**
```shell
docker network create test
```

**加入网络**
```shell
docker run -d --name web --network test -P nginx:1.18
```

**查看网络详情**
```shell
docker network inspect test
[
    {
        "Name": "test",
        "Id": "e0434bd8c39402acbfe02f40e33722329d9b87cee79aebc51bd651345e6b2099",
        "Created": "2021-03-05T16:14:53.606739869+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "a0461feb4d9d90eb3c4e11fba478f79609cdd348e40c3f3fb220dc8e455ab5c6": {
                "Name": "web",
                "EndpointID": "805af4200ff4fe906bc44a4663a05f45a8bc0588082d274c281717b7a4b7684d",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

**注**：
当两个应用容器需要通信时，创建新的业务容器网络，并将相关容器加入到网络中，应用中就可以使用容器名称进行通信了

---

## 网络模式：host、none和container

**host**

主机模式，会与主机共用网卡信息，其他资源依然保持隔离，如果有端口，则会直接绑定到宿主机网卡
```shell
docker run -d --name web --network host nginx:1.18
```

**container**

将一个容器加入到其他容器的网络命名空间中，则两个容器共用网络命名空间，及网卡信息
```shell
# 创建容器1
docker run -dit --name test1 busybox
# 创建容器2，并加入到容器1的网络命名空间中
docker run -dit --name test2 --network container:test1 busybox
# 分别查看网卡信息
docker exec -it test1 sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:02
          inet addr:172.17.0.2  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:11 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:906 (906.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ #
docker exec -it test2 sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:02
          inet addr:172.17.0.2  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:11 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:906 (906.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

```

---

## Docker网络模型与容器网络访问流程

**网络模型**

veth pair：成对出现的一种虚拟网络设备，数据从一端进,从另一 端出。 用于解决网络命名空间之间隔离。 
docker0：网桥是一个二层网络设备，通过网桥可以将Linux支持的不同的端口连接起来，并实现类似交换机那样的多对多的通信。

![网络模型](../../../_media/network-model.jpg)

**容器网络访问原理**

- **外部访问容器**

![外部访问](../../../_media/outtoin.jpg)

- **容器访问外部**

![范文外部](../../../_media/intoout.jpg)

