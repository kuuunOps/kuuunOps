# Nginx

## Nginx的应用场景

- 静态资源服务
>通过本地文件系统提供服务

- 反向代理服务
  - 缓存
  - 负载均衡

- API服务
  - OpenResty

---

## Nginx的优点

- 高并发，高性能
- 可扩展性好
- 高可靠性
- 热部署
- BSD许可证

---

## Nginx的组成

- Nginx二进制可执行文件
>由各模块源码编译出的一个文件

- Nginx.conf配置文件
>控制Nginx的行为

- access.log访问日志
>记录每一条请求信息

- error.log错误日志
>定位问题

---

## Nginx配置语法

- 配置文件由指令与指令块构成
- 每条指令以分号`;`结尾，指令与参数间以空格符号分隔
- 指令块以大括号`{}`将多条指令组织在一起
- include语句允许组合多个配置文件以提升可维护性
- 使用`#`添加注释，提供可读性
- 使用`$`引用变量
- 部分指令的参数支持正则表达式

---

## Nginx的http指令块

- http
- server
- upstream
- location

---

## Nginx热部署升级

```shell
cp nginx nginx.old
kill -USR2 13195
kill -WINCH 13195
```

---

## Nginx日志切割

```shell
cp www_access.log www_access.log.bak
# 等效于kill -USR1 $(cat nginx.pid)
nginx -s reopen
```
---

## Nginx启用静态文件压缩-gzip

```shell
gzip on;
gzip_min_lenth 1024;
gzip_comp_level 3;
gzip_types text/plain application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
```

---

## Nginx显示网站目录结构

```shell
location / {
    autoindex on;
}
```

---

## Nginx请求频率限制

```shell
location / {
    set $limit_rate 1k;
}
```

---

## Nginx日志格式

定义

```shell
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status [$request_lenth:$body_bytes_sent] "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for" "$upstream_cache_status" ';
```

使用

```shell
access_log logs/www_access.log main;
```

---

## Nginx反向代理

```shell
upstream local {
    server 127.0.0.1:8080;
}
server {
    server_name docs.kuuun.com;
    listen 80;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://local;
    }
}
```

## Nginx反向代理缓存

```shell
http {
    proxy_cache_path /tmp/nginxcache levels=1:2 keys_zone=my_cache:10m max_size=10g
                     inactive=60m use_temp_path=off;
    server {
        location / {
            proxy_cache my_cache;
            proxy_cache_key $host$uri;
            proxy_cache_valid 200 304 302 1d;
        }
    }
}
```
---

## 使用Goaccess实时显示日志情况

>官网地址：https://goaccess.io/

---

## 证书验证

域名验证：DV
组织验证：OV
扩展验证：EV

---
## TLS通讯过程

1. 验证身份
2. 达成安全套件共识
3. 传递秘钥
4. 加密通讯

---

## 使用Let's Encrypt配置SSL证书

1. cert

```shell
$ yum install -y certbot python2-certbot-nginx
$ certbot --nginx --nginx-server-root=/usr/local/openresty/nginx/conf/ -d docs.kuuun.com
```

2. acme

---

## SSL连接优化

```shell
ssl_session_cache shared:le_nginx_SSL:1m;
ssl_session_timeout 1440m;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5";
ssl_dhparam /usr/local/nginx/ssl/ssl-dhparams.pem;
```

扩展：`openssl dhparam -out /usr/local/nginx/ssl/ssl-dhparams.pem 2048`

---

## Nginx信号管理

- Master进程
  1. 监控worker进程：CHLD
  2. 管理worker进程
  3. 接收信号
    - TERM,INT
    - QUIT
    - HUP
    - USR1
    - USR2
    - WINCH

- Worker进程
  - 接收信号
    - TERM,INT
    - QUIT
    - USR1
    - WINCH

- nginx命令行
  - reolad：HUP
  - reopen：USR1
  - stop：TERM
  - quit：QUIT

---

## reload流程

1. 向master进程发送HUP信号
2. master进程校验配置语法是否正确
3. master进程打开新的监听端口
4. master进程用新配置启动新的worker子进程
5. master进程向老worker子进程发送QUIT信号
6. 老worker进程关闭监听句柄，处理完当前连接后结束进程

---

## 热升级流程

1. 将旧Nginx文件换成新Nginx文件（注意备份）
2. 向master进程发送USR2信号
3. master进程修改pid文件名，加后缀`.oldbin`
4. master进程用新Nginx文件启动新master进程
5. 向老master进程发送QUIT信号，关闭老master进程
6. 回滚：向老master发送HUP，向新master发送QUIT

---

## Worker进程的优雅关闭

1. 设置定时器：worker_shutdown_timeout
2. 关闭监听句柄
3. 关闭空闲连接
4. 在循环中等待全部连接关闭
5. 退出进程

---

