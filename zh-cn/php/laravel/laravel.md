# Laravel

### 一、安装composer
> 安装参考地址：https://developer.aliyun.com/composer

**1. 下载最新稳定版compose**
```bash
wget https://mirrors.aliyun.com/composer/composer.phar
mv composer.phar /usr/local/bin/composer
```

**2. 进行全局配置**
```bash
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
```

**3. 调试**
```bash
composer -vvv require alibabacloud/sdk
```


### 二、安装Laravel

**1. 使用compose下载Laravel安装程序**
```bash
composer global require "laravel/installer"
```
**2. 通过composer创建项目**
```bash
composer create-project --prefer-dist laravel/laravel blog "5.5.*"
```

**3. 启动服务**
```bash
php artisan serve
```

### 三、Laravel的nginx参考配置
```bash
server {
    listen 80;
    server_name example.com;
    root /example.com/public;


    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";


    index index.html index.htm index.php;


    charset utf-8;


    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }


    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }


    error_page 404 /index.php;


    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }


    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

