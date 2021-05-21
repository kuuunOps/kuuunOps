## 1、安装依赖软件包

```shell
yum install -y ntpdate
```

## 2、设置主机名

>各个节点设置主机名称

```shell
hostnamectl set-hostname admin-node
hostnamectl set-hostname node1
hostnamectl set-hostname node2
hostnamectl set-hostname node3
```

>在admin节点配置hosts

```shell
cat >> /etc/hosts << EOF
172.16.4.41 node1
172.16.4.42 node2
172.16.4.43 node3
EOF
```

## 3、关闭selinux，关闭防火墙

```shell
# 关闭selinux
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

# 关闭防火墙
systemctl stop firewalld && systemctl disable firewalld
```

## 4、时间同步

```shell
ntpdate ntp1.aliyun.com
```

## 5、设置SSH免密登录

```shell
# 生成秘钥
if [ -f "$HOME/.ssh/id_rsa.pub" ] ; then
    echo "The secret key already exists"
    cat $HOME/.ssh/id_rsa.pub
else
    echo "A new key is generated when the key does not exist"
    ssh-keygen -t rsa -N '' -q -f $HOME/.ssh/id_rsa
    cat $HOME/.ssh/id_rsa.pub
fi

# 复制秘钥
HOSTS=(node1 node2 node3)
for instance in ${HOSTS[@]}; do
  ssh-copy-id -i ${HOME}/.ssh/id_rsa.pub root@${instance}
done
```

## 6、配置软件源

```shell
# 生成镜像文件
cat << EOF |sudo tee /etc/yum.repos.d/ceph.repo
[norch]
name=norch
baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/noarch
enabled=1
gpgcheck=0

[x86_64]
name=x86_64
baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/x86_64/
enabled=1
gpgcheck=0
EOF

yum makecache fast

# 分发镜像文件
NODES=(node1 node2 node3)
for instance in ${NODES[@]};
do
    scp /etc/yum.repos.d/ceph.repo root@${instance}:/etc/yum.repos.d/
    ssh root@${instance} "yum makecache fast"
done
```