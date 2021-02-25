# Gitlab

### Gitlab备份

1. 执行备份命令
```bash
sudo gitlab-backup create
```

2. 备份配置文件
```bash
/etc/gitlab/gitlab-secrets.json
/etc/gitlab/gitlab.rb
```

### Gitlab升级

- 在线升级

1. 备份操作
```bash
sudo gitlab-rake gitlab:backup:create STRATEGY=copy
```

2. 执行更新升级命令
```bash
sudo yum install -y gitlab-ce
```


- 离线升级

1. 备份操作
```bash
sudo gitlab-rake gitlab:backup:create STRATEGY=copy
```

2. 下载离线软件包
   
3. 执行更新升级命令
```bash
rpm -Uvh xxx.rpm
```
