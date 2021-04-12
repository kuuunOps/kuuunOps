# systemd

>https://www.freedesktop.org/software/systemd/man/systemd.service.html

- `sshd`示例

```shell
[root@ansible ~]# cat /usr/lib/systemd/system/sshd.service
[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.service
Wants=sshd-keygen.service

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D $OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

- `Unit`

| 参数            | 参数描述                                                                                                                                                                                                                                                                                                                       |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Description`   | 当我们使用`systemctl list-units`时，输出给管理员看的简易说明！使用`systemctl satus`输出的此服务的说明，也是这个选项                                                                                                                                                                                                            |
| `Documentation` | 这个选项为管理员提供进一步资料查询的功能！可以如下样式：<br>- `Documentation=http://www....`<br>- `Documentation=man:sshd(8)`<br>- `Documentation=file:/etc/ssh/sshd_config`                                                                                                                                                   |
| `After`         | 说明此unit是在哪个服务启动之后再启动的意思。基本只是仅用于说明此服务启动的顺序而已，并没有强制要求的意思。以`sshd.service`的内容为例，该说明提到`After`后面的`network.target`以及`sshd-keygen.service`，但是若这两个`unit`没有启动，而强制启动`sshd.service`的话，那么`sshd.service`还是能启动的，与`Requires`的设定有区别的。 |
| `Before`        | 与`After`的意思相反，是在什么服务之前启动这个服务最好。不过这个只是规范的启动顺序，并没有强制的意思。                                                                                                                                                                                                                          |
| `Requires`      | 明确要求此`unit`需要在哪个服务启动后才能启动！属于强依赖顺序！如果在此选项设定的服务没有启动，那么此`unit`就不会启动                                                                                                                                                                                                           |
| `Wants`         | 与`Requires`相反，规范这个`Unit`需要在哪个服务启动之后再启动比较好的意思。并不是强制的意思！主要目的是希望建立让使用者比较好的操作环境。因此，如果`Wants`后面接的服务没有启动，也不会此`unit`本身。                                                                                                                            |
| `Conflicts`     | 代表冲突的服务，即这个选项后面的服务如果启动，那么我们这个`Unit`就不能进行启动。如果我们`Unit`启动，那么此选项的服务就不能启动。                                                                                                                                                                                               |

- `Service`

| 参数 | 参数说明 |
| ---- | -------- |

