# cfssl

- [https://github.com/cloudflare/cfssl](https://github.com/cloudflare/cfssl)
- [二进制文件](https://pkg.cfssl.org)

>CFSSL是CloudFlare的PKI/TLS利器。它既是命令行工具，又是用于签名，验证和捆绑TLS证书的HTTP API服务器。它需要` Go1.12+ `才能构建。

## cfssl安装

**下载**
```shell
curl -s -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o /usr/bin/cfssl
curl -s -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o /usr/bin/cfssljson
curl -s -L https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o /usr/bin/cfssl-certinfo
chmod +x /usr/bin/cfssl*
```
### 创建CA

#### CA配置文件

生成默认配置
```shell
cfssl print-defaults config > ca-config.json
```
默认格式:
```json
{
    "signing": {
        "default": {
            "expiry": "168h"
        },
        "profiles": {
            "www": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            }
        }
    }
}
```

CA的参考配置：
```json
{
    "signing": {
        "default": {
            "expiry": "87600h"
        },
        "profiles": {
            "www": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
```

#### CA证书

生成默认证书配置：
```shell
cfssl print-defaults csr > ca-csr.json
```

默认样式：
```json
{
    "CN": "example.net",
    "hosts": [
        "example.net",
        "www.example.net"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "US",
            "L": "CA",
            "ST": "San Francisco"
        }
    ]
}
```

CA证书参考配置：
```json
{
    "CN": "Kuuun",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Shenzhen",
            "O": "CA",
            "OU": "Devops",
            "ST": "Guangdong"
        }
    ]
}
```

生成CA证书和CA秘钥
```shell
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
```

- ` ca-key.pem `：私钥
- ` ca.pem `：证书
- ` ca.csr `：证书签名请求

### 签发客户端证书

#### 生成客户端证书配置
```shell
cfssl print-defaults csr > www.kuuun.com-csr.json
```

**参考配置**
```json
{
    "CN": "www.kuuun.com",
    "hosts": [
       "172.16.4.13",
       "www.kuuun.com"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Shenzhen",
            "O": "CA",
            "OU": "Devops",
            "ST": "Guangdong"
        }
    ]
}
```

**签发客户端证书和秘钥**
```shell
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www www.kuuun.com-csr.json | cfssljson -bare www.kuuun.com
```

