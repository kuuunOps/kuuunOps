# cfssl

[https://github.com/cloudflare/cfssl](https://github.com/cloudflare/cfssl)
[二进制文件](https://pkg.cfssl.org)

>CFSSL是CloudFlare的PKI/TLS利器。它既是命令行工具，又是用于签名，验证和捆绑TLS证书的HTTP API服务器。它需要` Go1.12+ `才能构建。

## cfssl安装

**下载**
```shell
curl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o /usr/bin/cfssl
curl https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o /usr/bin/cfssljson
curl https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o /usr/bin/cfssl-certinfo
chmod +x /usr/bin/cfssl*
```
**创建CA**

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

修改为CA的配置文件：
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

生成默认证书：
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

修改为CA证书：
```json
```
