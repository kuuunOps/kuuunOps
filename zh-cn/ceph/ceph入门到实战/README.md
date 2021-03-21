# Ceph入门到实战
---
# 第一章 存储介绍

- DAS
- NAS
- SAN
- Object Storage

## DAS存储介绍

### 1. 概念

`Direct Attached Storage` 直接附加存储

### 2. 方式

服务器使用SCSI或FC协议连接到存储阵列

### 3. 协议类型

- SCSI总线
- FC光纤

### 4. 表现形式

一块空间大小裸磁盘如`/dev/sdb`

### 5. 优点

组网简单，成本低廉，第一代

### 6. 缺点

可扩展性有限，不灵活，无法多机共享

### 7. 产品举例

目前很少使用

---

## NAS存储介绍

### 1. 概念

`Network Attached Storage` 网络附加存储

### 2. 方式

服务器使用TCP网络协议连接至文件共享存储

### 3. 协议类型

- NFS
- CIFS

### 4. 表现形式

映射到存储的一个目录，如/data

### 5. 优点

使用简单，通过IP协议实现互访，多机同时共享同个存储

### 6. 缺点

性能有限，可靠性不高

### 7. 产品举例

- NFS，samba，GlusterFS，存储厂商提供的NAS存储
- 公有云：AWS EFS，腾讯云CFS，阿里云NAS

---



---
# 第二章 Ceph存储架构
---
# 第三章 Ceph集群部署
---
# 第四章 RBD块存储
---
# 第五章 RGW对象存储
---
# 第六章 CephFS文件存储
---
# 第七章 OSD扩容和还盘
---
# 第八章 Ceph集群运维
---
# 第九章 定制Crush map规则
---
# 第十章 RBD高级功能
---
# 第十一章 RGW高可用集群
---
# 第十二章 Ceph集群测试
---
# 第十三章 Ceph与Kubernetes集成
---
# 第十四章 Ceph与KVM集成
---
# 第十五章 Ceph与OpenStack对接
---
# 第十六章 Ceph管理与监控
---
# 第十七章 SDK开发与排障分析
---