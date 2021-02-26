# PHP

### 使用 systemd 运行 Horizon

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