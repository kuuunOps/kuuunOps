## 单节点
```shell
cat > docker-compose.yml << EOF
version: "3.7"
services:
  redis:
    image: redis:5
    container_name: redis
    restart: always
    ports:
      - "6379:6379"
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - "./conf/redis.conf:/usr/local/redis/redis.conf"
      - "./data:/data"
    command: ["redis-server", "/usr/local/redis/redis.conf"]
EOF
```

## RDB持久化

默认持久化机制

```shell
# 代表RDB执行的时机
save 900 1
save 300 10
save 60 10000
# 开启持久化压缩
rdbcompression yes
# RDB持久化名称
dbfilename dump.rdb
```

## AOF持久化

```shell
# 开启AOF持久化
appendonly yes
# AOF持久化文件名称
appendfilename "appendonly.aof"
# AOF执行化执行的时机
# appendfsync always
appendfsync everysec
# appendfsync no
```
