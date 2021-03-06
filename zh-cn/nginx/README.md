# Nginx

## 安装Nginx

**环境准备**：

- 操作系统：CentOS
- 网络要求：可以访问互联网

### 1. 准备安装文件

`nginx-1.18.0.tar.gz`

### 2. 安装依赖包及工具
```shell
yum install -y gcc openssl openssl-devel pcre pcre-devel zlib-devel wget
```

### 3. 创建守护进程用户
```shell
useradd -s /sbin/nologin www
```

### 4. 安装nginx
```shell
# 解压安装包
tar -xvf nginx-1.18.0.tar.gz
cd nginx-1.18.0
# 配置选项
./configure --prefix=/usr/local/nginx \
--user=www \
--group=www \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-stream
# 编译
make && make install
```

### 5. 启动nginx
```shell
# 检测nginx配置文件是否正确
/usr/local/nginx/sbin/nginx -t
# 启动nginx
/ust/local/nginx/sbin/nginx
```

---
## ` nginx.conf `参考

```shell
user www www;
worker_processes auto;
worker_cpu_affinity auto;
error_log logs/nginx_error.log info;
pid /var/run/nginx.pid;
worker_rlimit_nofile 65535;

events
{
    use epoll;
    worker_connections 10240;
    multi_accept on;
}

http
{
    # 加载媒体类型
    include mime.types;
    default_type application/octet-stream;
    server_names_hash_bucket_size 3526;
    server_names_hash_max_size 4096;
    # 定义日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request"'
                    '$status $body_bytes_sent "$http_referer"'
                    '"$http_user_agent" "$http_x_forwarded_for"'
                    '$upstream_addr $upstream_response_time';

    access_log logs/access.log main;
    # 关闭版本号显示
    server_tokens off;
    # 提升文件传输
    sendfile on;
    send_timeout 10;
    tcp_nopush on;
    tcp_nodelay on;
    # TCP长连接超时时间
    keepalive_timeout 30;
    # 客户端请求信息配置
    client_header_timeout 30;
    client_header_buffer_size 4k;
    large_client_header_buffers 8 16k;
    client_body_timeout 10;
    client_max_body_size 500m;
    client_body_buffer_size 256k;
    connection_pool_size 256;
    request_pool_size 4k;
    output_buffers 4 32k;
    postpone_output 1460;
    # 启用gzip模块，并配置
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 16k;
    gzip_comp_level 3;
    gzip_http_version 1.0;
    gzip_types     text/plain application/javascript application/x-javascript text/javascript text/css application/xml;
    gzip_vary on;
    gzip_proxied   expired no-cache no-store private auth;
    gzip_disable "MSIE [1-6]\.";
    # 子配置
    include default.d/default.conf;
}
```

---

## Nginx启动脚本参考
```bash
#!/bin/bash
# chkconfig: - 30 21
# description: http service.
# Source Function Library
. /etc/init.d/functions
# Nginx Settings

NGINX_SBIN="/usr/local/nginx/sbin/nginx"
NGINX_CONF="/usr/local/nginx/conf/nginx.conf"
NGINX_PID="/usr/local/nginx/logs/nginx.pid"
RETVAL=0
prog="Nginx"

start() {
        echo -n $"Starting $prog: "
        mkdir -p /dev/shm/nginx_temp
        daemon $NGINX_SBIN -c $NGINX_CONF
        RETVAL=$?
        echo
        return $RETVAL
}

stop() {
        echo -n $"Stopping $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -TERM
        rm -rf /dev/shm/nginx_temp
        RETVAL=$?
        echo
        return $RETVAL
}

reload(){
        echo -n $"Reloading $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -HUP
        RETVAL=$?
        echo
        return $RETVAL
}

restart(){
        stop
        start
}

configtest(){
    $NGINX_SBIN -c $NGINX_CONF -t
    return 0
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  reload)
        reload
        ;;
  restart)
        restart
        ;;
  configtest)
        configtest
        ;;
  *)
        echo $"Usage: $0 {start|stop|reload|restart|configtest}"
        RETVAL=1
esac
exit $RETVAL
```