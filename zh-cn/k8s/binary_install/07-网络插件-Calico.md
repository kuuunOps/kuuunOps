## 网络插件-Calico

>官方文档地址：`https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises`

```shell
curl https://docs.projectcalico.org/manifests/calico.yaml -O
```
>修改IP自动发现

```shell
# 修改前
- name: IP
  value: "autodetect"

# 修改后
- name: IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
```

>修改 CIDR

```shell
- name: CALICO_IPV4POOL_CIDR
  value: "10.200.0.0/16"
```