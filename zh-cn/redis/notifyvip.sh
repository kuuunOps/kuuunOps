#!/bin/bash
# notifyvip.sh脚本内容

#第六个参数是新主redis的ip地址
MASTER_IP=$6
#其他两个服务器上为172.16.213.77，172.16.213.78
LOCAL_IP='172.16.213.75'
VIP='172.16.213.229'
NETMASK='24'
INTERFACE='em2'
if [[ "${MASTER_IP}" == "${LOCAL_IP}" ]];then
  #将VIP绑定到该服务器上
   /sbin/ip  addr  add ${VIP}/${NETMASK}  dev ${INTERFACE}
   /sbin/arping -q -c 3 -A ${VIP} -I ${INTERFACE}
   exit 0
else
   #将VIP从该服务器上删除
  /sbin/ip  addr del  ${VIP}/${NETMASK}  dev ${INTERFACE}
  exit 0
fi
#如果返回1，sentinel会一直执行这个脚本
exit 1