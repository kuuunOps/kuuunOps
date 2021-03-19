# Prometheus

普罗米修斯是一个开源系统监控和警报工具包，最初建于声云。自 2012 年成立以来，许多公司和组织都采用了 Prometheus，该项目拥有非常活跃的开发人员和用户社区。它现在是一个独立的开源项目，独立于任何公司维护。为了强调这一点，并澄清项目的治理结构，普罗米修斯于2016年加入云原生计算基金会，成为继Kubernetes之后的第二个托管项目。

官方网站：https://prometheus.io

Github：https://github.com/prometheus

# 概述与架构

## 特点

- 多维数据模型：由度量名称和键值对标识的时间序列数据 
- PromQL：一种灵活的查询语言，可以利用多维数据完成复杂的查询
- 不依赖分布式存储，单个服务器节点可直接工作 
- 基于HTTP的pull方式采集时间序列数据 
- 推送时间序列数据通过PushGateway组件支持 
- 通过服务发现或静态配置发现目标 
- 多种图形模式及仪表盘支持（grafana）


## 组件与架构

![](../../_media/Prometheus+Grafana讲义.jpg)

- Prometheus Server：收集指标和存储时间序列数据，并提供查询接口
- ClientLibrary：客户端库
- Push Gateway：短期存储指标数据。主要用于临时性的任务
- Exporters：采集已有的第三方服务监控指标并暴露metrics
- Alertmanager：告警
- Web UI：简单的Web控制台

---

# 部署与配置

## 部署

### 二进制部署

```shell
curl -o prometheus-2.25.2.linux-amd64.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.25.2/prometheus-2.25.2.linux-amd64.tar.gz
tar xf prometheus-2.25.2.linux-amd64.tar.gz
cd prometheus-2.25.2.linux-amd64
./prometheus
```
通过浏览器访问：http://ip:9090

`prometheus`命令常用参数选项

| 参数选项                               | 描述                   |
| -------------------------------------- | ---------------------- |
| `--config.file="prometheus.yml"`       | 指定配置文件           |
| `--web.listen-address= "0.0.0.0:9090"` | 监听地址和端口         |
| `--log.level=info`                     | 日志级别               |
| `--alertmanager.timeout=10s`           | 与报警组件的超时时间   |
| `--storage.tsdb.path="data/"`          | 数据目录               |
| `--storage.tsdb.retention.time=15d`    | 数据保存时间，默认15天 |



### Docker部署

```shell
docker run \
    -p 9090:9090 \
    -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus
```

---

## 配置系统服务

配置`systemd`
```shell
cat >/usr/lib/systemd/system/prometheus.service <<EOF
[Unit]
Description=prometheus
[Service]
ExecStart=/opt/monitor/prometheus/prometheus --config.file=/opt/monitor/prometheus/prometheus.yml ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload 
systemctl start prometheus 
systemctl enable prometheus
```

---

## 配置文件

官方配置文献：https://prometheus.io/docs/prometheus/latest/configuration/configuration/

```yaml
global:
  # How frequently to scrape targets by default.
  [ scrape_interval: <duration> | default = 1m ]

  # How long until a scrape request times out.
  [ scrape_timeout: <duration> | default = 10s ]

  # How frequently to evaluate rules.
  [ evaluation_interval: <duration> | default = 1m ]

  # The labels to add to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    [ <labelname>: <labelvalue> ... ]

  # File to which PromQL queries are logged.
  # Reloading the configuration will reopen the file.
  [ query_log_file: <string> ]

# Rule files specifies a list of globs. Rules and alerts are read from
# all matching files.
rule_files:
  [ - <filepath_glob> ... ]

# A list of scrape configurations.
scrape_configs:
  [ - <scrape_config> ... ]

# Alerting specifies settings related to the Alertmanager.
alerting:
  alert_relabel_configs:
    [ - <relabel_config> ... ]
  alertmanagers:
    [ - <alertmanager_config> ... ]

# Settings related to the remote write feature.
remote_write:
  [ - <remote_write> ... ]

# Settings related to the remote read feature.
remote_read:
  [ - <remote_read> ... ]
```
