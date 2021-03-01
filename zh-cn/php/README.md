# PHP


## 安装php7

### 1. 准备php7软件包

### 2. 安装依赖包
```bash
yum install -y gcc  autoconf libxml2-devel libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel libmcrypt-devel libxslt-devel libtool-ltdl-devel zlib libxml libjpeg freetype libpng gd curl libiconv zlib-devel gd-devel libcurl-devel libmcrypt mhash mcrypt libmcrypt openssl openssl-devel gmp-devel readline-devel bzip2-devel wget
```

### 3. 创建用户
```bash
useradd -s /sbin/nologin www
```

### 4. 解压编译
```bash
# 创建软件存放目录，将Nginx安装包放到目录中（或下载安装包）
mkdir -p /data/software
# wget -P /data/software/ http://cn2.php.net/distributions/php-7.2.13.tar.gz
# 进入存放目录，解压文件
cd /data/software/
tar xf php-7.2.13.tar.gz
# 进入nginx解压目录
cd php-7.2.13
# 执行编译参数配置
./configure --prefix=/usr/local/php7 --with-config-file-path=/usr/local/php7/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-inline-optimization --disable-debug --disable-rpath --enable-shared --enable-soap --enable-pcntl --with-xmlrpc --with-openssl --with-mcrypt --with-pcre-regex --with-sqlite3 --with-zlib --enable-bcmath --with-iconv --with-bz2 --enable-calendar --with-curl --with-cdb --enable-dom --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir --enable-ftp --with-gd --with-openssl-dir --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --enable-json --enable-mbstring --enable-mbregex --enable-mbregex-backtrack --with-libmbfl --with-onig --enable-pdo --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib-dir --with-pdo-sqlite --with-readline --enable-session --enable-shmop --enable-simplexml --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-libxml-dir --with-xsl --enable-zip --enable-mysqlnd-compression-support --with-pear --enable-opcache
# 编译及安装
make && make install
```

### 5. 配置
```bash
# 复制配置文件到php安装目录
cd /data/software/php-7.2.13/
cp php.ini-production /usr/local/php7/etc/php.ini
# 复制php控制脚本
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm7
chmod a+x /etc/init.d/php-fpm7
# 修改php-fpm配置文件
cd /usr/local/php7/etc/
cp php-fpm.conf.default php-fpm.conf
cd php-fpm.d/
cp www.conf.default www.conf
vi www.conf
...
# 确认一下监听的IP及端口号（默认为9000），这里修改为9001
listen = 0.0.0.0:9001
...
# 确认一下php子进程管理模式（可选模式：'static', 'dynamic' or 'ondemand'）
pm = dynamic
...
pm.max_children = 1000
...
pm.start_servers = 10
...
pm.min_spare_servers = 5
...
pm.max_spare_servers = 15
...
```

### 6. 启动，停止，重启
```bash
# 启动
/etc/init.d/php-fpm7 start
# 停止
/etc/init.d/php-fpm7 start
# 重启
/etc/init.d/php-fpm7 start
```

---

## 使用systemd运行Horizon

**1. 编辑/etc/systemd/system/文件**
```bash
vim /etc/systemd/system/horizon.service
```

**2. 参考配置**
```bash


[Unit]
# 描述
Description=Laravel Horizon
# 表明本服务要在 mysql 和 redis 之后启动，Laravel 依赖 mysql，Horizon 依赖 redis
After=mysqld.service redis-server.service


[Service]
# !!!这里修改为laravel项目根目录
WorkingDirectory=/project/laravel/root
# 这里可以指定运行的用户
User=www
Group=www
# 启动命令，php 建议使用绝对路径
ExecStart=/usr/bin/php artisan horizon
# 停止命令，使用 horizon 提供的优雅停止方法
ExecStop=/usr/bin/php artisan horizon:terminate
# 可以控制服务在什么情况下重新启动，这里设置为异常退出时重新启动
Restart=on-failure
# 重新启动的前等待的时间
RestartSec=30s
# 指定正确退出的代码，一些没有处理 TERM 信号的程序退出代码会是 143 ，Horizon 的退出代码是 0
SuccessExitStatus=0


[Install]
# 指定在 多用户 模式下启动，就是一般的命令行模式啦，也包括图形界面模式
WantedBy=multi-user.target
```

**3. 重载配置**
```bash
systemctl daemon-reload
systemctl start horizon.service
systemctl enable horizon.service
```

---

## PHP7编译参考

1. 安装软件包
```bash
yum install -y gcc  autoconf libxml2-devel libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel libmcrypt-devel libxslt-devel libtool-ltdl-devel zlib libxml libjpeg freetype libpng gd curl libiconv zlib-devel gd-devel libcurl-devel libmcrypt mhash mcrypt libmcrypt openssl openssl-devel gmp-devel readline-devel wget curl
```

2. 编译参数
```bash
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-inline-optimization --disable-debug --disable-rpath --enable-shared --enable-soap --enable-pcntl --with-xmlrpc --with-openssl --with-mcrypt --with-pcre-regex --with-sqlite3 --with-zlib --enable-bcmath --with-iconv --with-bz2--enable-calendar --with-curl --with-cdb --enable-dom --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir --enable-ftp --with-gd --with-openssl-dir --with-jpeg-dir --with-png-dir --with-freetype-dir --enable-gd-native-ttf --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --enable-json --enable-mbstring --enable-mbregex --enable-mbregex-backtrack --with-libmbfl --with-onig --enable-pdo --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib-dir --with-pdo-sqlite --with-readline --enable-session --enable-shmop --enable-simplexml --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-libxml-dir --with-xsl --enable-zip --enable-mysqlnd-compression-support --with-pear --enable-opcache
```

---

## 安装第三方插件

### redis
```bash
# 下载并解压
wget https://github.com/phpredis/phpredis/archive/3.1.4.tar.gz
cd phpredis-3.1.4

# 执行编译
/usr/local/php/bin/phpize
./configure --enable-redis --with-php-config=/usr/local/php/bin/php-config
make && make install

# 配置php
extension_dir = "/usr/local/php/lib/php/extensions/no-debug-zts-20090626"
extension_dir = /usr/local/php/lib/php/extensions/no-debug-non-zts-20170718/
extension=redis.so
```

### mcypt

1. 下载编辑
```bash
wget https://pecl.php.net/get/mcrypt-1.0.3.tgz
tar xf mcrypt-1.0.3.tgz
cd mcrypt-1.0.3
/usr/local/php7/bin/phpize
./configure --with-php-config=/usr/local/php7/bin/php-config
make && make install
```

2. 修改配置
```bash
vi php.ini
extension_dir = "/usr/local/php7/lib/php/extensions/no-debug-non-zts-20170718/"
extension = "mcrypt.so"
```

3. 重启`php-fpm`服务
```bash
/etc/init.d/php-fpm restart
```