# Prometheus监控Docker主机

- cAdvisor （Container Advisor）
  用于收集正在运行的容器资源使用和性能信息。

  [https://github.com/google/cadvisor](https://github.com/google/cadvisor) 

- Prometheus（普罗米修斯）
  容器监控系统。

  [https://prometheus.io](https://prometheus.io)

  [https://github.com/prometheus](https://github.com/prometheus)

- Grafana
  是一个开源的度量分析和可视化系统。
  
  [https://grafana.com/grafana](https://grafana.com/grafana)

cAdvisor（采集所有容器资源利用率，在每个Docker主机上部署）<-Prometheus（收集与存储）->Granfana（可视化展示）

## 搭建 cAdvisor 与 Prometheus 监控系统

### **Docker部署cAdvisor**
```shell
docker run -d \
--volume=/:/rootfs:ro \
--volume=/var/run:/var/run:ro \
--volume=/sys:/sys:ro \
--volume=/var/lib/docker/:/var/lib/docker:ro \
--volume=/dev/disk/:/dev/disk:ro \
--publish=8080:8080 \
--detach=true \
--name=cadvisor \
--privileged \
--device=/dev/kmsg \
google/cadvisor:latest
```
### **Docker部署Prometheus**
```shell
docker run -d \
--name=prometheus \
-p 9090:9090 \
prom/prometheus
```

**Prometheus配置cAdvisor数据采集**
```yaml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']
  - job_name: 'docker'
    static_configs:
    - targets: ['172.16.4.13:8080']
```

## Grafana 可视化展示


### 部署

**Docker部署Grafana**
```shell
docker run -d \
--name=grafana \
-p 3000:3000 \
grafana/grafana
```

## 监控多个 Docker 主机


