# Consul

> Consul是一个分布式的服务发现和键/值存储系统。

### 基于docker安装

参考地址：https://gitee.com/kuuun/learn-consul-docker

`Consul`默认访问端口为8500。

```yaml
version: '3.7'

services:

  consul-server1:
    image: consul:1.9.3
    container_name: consul-server1
    restart: always
    volumes:
     - ./server1.json:/consul/config/server1.json:ro
     - ./certs/:/consul/config/certs/:ro
    networks:
      - consul
    ports:
      - "8500:8500"
      - "8600:8600/tcp"
      - "8600:8600/udp"
    command: "agent -bootstrap-expect=3"

  consul-server2:
    image: consul:1.9.3
    container_name: consul-server2
    restart: always
    volumes:
     - ./server2.json:/consul/config/server2.json:ro
     - ./certs/:/consul/config/certs/:ro
    networks:
      - consul
    command: "agent -bootstrap-expect=3"

  consul-server3:
    image: consul:1.9.3
    container_name: consul-server3
    restart: always
    volumes:
     - ./server3.json:/consul/config/server3.json:ro
     - ./certs/:/consul/config/certs/:ro
    networks:
      - consul
    command: "agent -bootstrap-expect=3"

  consul-client:
    image: consul:latest
    container_name: consul-client
    restart: always
    volumes:
     - ./client.json:/consul/config/client.json:ro
     - ./certs/:/consul/config/certs/:ro
    networks:
      - consul
    command: "agent"

networks:
  consul:
    driver: bridge
```

配置文件示例：

client.json

```json
{
    "node_name": "consul-client",
    "data_dir": "/consul/data",
    "retry_join":[
        "consul-server1",
        "consul-server2",
        "consul-server3"
     ],
    "encrypt": "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w=",
    "verify_incoming": true,
    "verify_outgoing": true,
    "verify_server_hostname": true,
    "ca_file": "/consul/config/certs/consul-agent-ca.pem",
    "cert_file": "/consul/config/certs/dc1-server-consul-0.pem",
    "key_file": "/consul/config/certs/dc1-server-consul-0-key.pem"
}
```

server1.json

```json
{
    "node_name": "consul-server1",
    "server": true,
    "ui_config": {
        "enabled" : true
    },
    "data_dir": "/consul/data",
    "addresses": {
        "http" : "0.0.0.0"
    },
    "retry_join":[
        "consul-server2",
        "consul-server3"
    ],
    "encrypt": "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w=",
    "verify_incoming": true,
    "verify_outgoing": true,
    "verify_server_hostname": true,
    "ca_file": "/consul/config/certs/consul-agent-ca.pem",
    "cert_file": "/consul/config/certs/dc1-server-consul-0.pem",
    "key_file": "/consul/config/certs/dc1-server-consul-0-key.pem",
    "enable_script_checks": true
}
```

server2.json

```json
{
    "node_name": "consul-server2",
    "server": true,
    "ui_config": {
        "enabled" : true
    },
    "data_dir": "/consul/data",
    "addresses": {
        "http" : "0.0.0.0"
    },
    "retry_join":[
        "consul-server1",
        "consul-server3"
    ],
    "encrypt": "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w=",
    "verify_incoming": true,
    "verify_outgoing": true,
    "verify_server_hostname": true,
    "ca_file": "/consul/config/certs/consul-agent-ca.pem",
    "cert_file": "/consul/config/certs/dc1-server-consul-0.pem",
    "key_file": "/consul/config/certs/dc1-server-consul-0-key.pem",
    "enable_script_checks": true
}
```

server3.json

```json
{
    "node_name": "consul-server3",
    "server": true,
    "ui_config": {
        "enabled" : true
    },
    "data_dir": "/consul/data",
    "addresses": {
        "http" : "0.0.0.0"
    },
    "retry_join":[
        "consul-server1",
        "consul-server2"
    ],
    "encrypt": "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w=",
    "verify_incoming": true,
    "verify_outgoing": true,
    "verify_server_hostname": true,
    "ca_file": "/consul/config/certs/consul-agent-ca.pem",
    "cert_file": "/consul/config/certs/dc1-server-consul-0.pem",
    "key_file": "/consul/config/certs/dc1-server-consul-0-key.pem",
    "enable_script_checks": true
}
```


### 服务注册示例

```shell
curl -X PUT -d '{
  "id": "Linux-1",
  "name": "Linux",
  "address": "172.16.4.252",
  "port": 9100,
  "tags": ["Linux"],
  "checks": [
    {
      "http":"http://172.16.4.252:9100",
      "method":"GET",
      "interval": "5s",
      "timeout": "1s"
    }]
    }' http://172.16.4.245:8500/v1/agent/service/register
```

