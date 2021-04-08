#!/bin/sh
# Author: 张浩坤
# Date: 2021/04/08

. /etc/profile

HOSTNAME=$(hostname)
HOSTIP=$(hostname -i)

read -p "Please Enter the VIP address. If not, Enter: "  LBIP

print_msg () {
echo -e "\n\033[32m**** $1 ****\n\033[0m"
}

print_error_msg () {
echo -e "\n\033[31m**** $1 ****\n\033[0m"
}

# 计算签发时间
sign_date () {
print_msg 'Calculated time of issue! '
year=100
current_second=$(date +%s)
expire_second=$(date -d "${year}year" +%s)
inter_seconds=$((${expire_second} - ${current_second}))
inter_days=$((${inter_seconds}/60/60/24))
}

# 生成etcd的CA的key和cert
generate_etcd_ca () {
print_msg 'Generate etcd-ca for key and cert!'
openssl genrsa -out ${etcd_dir}/ca.key 2048
openssl req -x509 -new -nodes -key ${etcd_dir}/ca.key -subj "/CN=etcd-ca" -days $inter_days -out ${etcd_dir}/ca.crt
}

# 生成etcd-ca的server的key和cert
generate_etcd_server () {
print_msg 'Generate etcd-server for key and cert!'
openssl genrsa -out ${etcd_dir}/server.key 2048

cat > ${etcd_dir}/server-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = HOSTNAME

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = HOSTNAME
DNS.2 = localhost
IP.1 = HOSTIP
IP.2 = 127.0.0.1
IP.3 = ::1

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

sed -i "s#HOSTNAME#${HOSTNAME}#g" ${etcd_dir}/server-csr.conf
sed -i "s#HOSTIP#${HOSTIP}#g" ${etcd_dir}/server-csr.conf

openssl req -new -key ${etcd_dir}/server.key  -config ${etcd_dir}/server-csr.conf -out ${etcd_dir}/server.csr
openssl x509 -req -in ${etcd_dir}/server.csr -CA ${etcd_dir}/ca.crt -CAkey ${etcd_dir}/ca.key -CAcreateserial -out ${etcd_dir}/server.crt -days $inter_days -extensions v3_ext -extfile ${etcd_dir}/server-csr.conf
}

# 生成etcd的peer的key和cert
generate_etcd_peer () {
print_msg 'Generate etcd-peer for key and cert!'
openssl genrsa -out ${etcd_dir}/peer.key 2048

cat > ${etcd_dir}/peer-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = HOSTNAME

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = HOSTNAME
DNS.2 = localhost
IP.1 = HOSTIP
IP.2 = 127.0.0.1
IP.3 = ::1

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

sed -i "s#HOSTNAME#${HOSTNAME}#g" ${etcd_dir}/peer-csr.conf
sed -i "s#HOSTIP#${HOSTIP}#g" ${etcd_dir}/peer-csr.conf

openssl req -new -key ${etcd_dir}/peer.key  -config ${etcd_dir}/peer-csr.conf -out ${etcd_dir}/peer.csr
openssl x509 -req -in ${etcd_dir}/peer.csr -CA ${etcd_dir}/ca.crt -CAkey ${etcd_dir}/ca.key -CAcreateserial -out ${etcd_dir}/peer.crt -days $inter_days -extensions v3_ext -extfile ${etcd_dir}/peer-csr.conf
}

# 生成etcd的healthcheck-client的key和cert
generate_etcd_healthcheck () {
print_msg 'Generate etcd-healthcheck-client for key and cert!'
openssl genrsa -out ${etcd_dir}/healthcheck-client.key 2048

cat > ${etcd_dir}/healthcheck-client-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = kube-etcd-healthcheck-client
O = system:masters

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=clientAuth
EOF

openssl req -new -key ${etcd_dir}/healthcheck-client.key  -config ${etcd_dir}/healthcheck-client-csr.conf -out ${etcd_dir}/healthcheck-client.csr
openssl x509 -req -in ${etcd_dir}/healthcheck-client.csr -CA ${etcd_dir}/ca.crt -CAkey ${etcd_dir}/ca.key -CAcreateserial -out ${etcd_dir}/healthcheck-client.crt -days $inter_days -extensions v3_ext -extfile ${etcd_dir}/healthcheck-client-csr.conf
}

# 生成etcd的apiserver-etcd-client的key和cert
generate_apiserver_etcd_client () {
print_msg 'Generate etcd-healthcheck-client for key and cert!'
openssl genrsa -out ${etcd_dir}/apiserver-etcd-client.key 2048

cat > ${etcd_dir}/apiserver-etcd-client-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = kube-apiserver-etcd-client
O = system:masters

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=clientAuth
EOF

openssl req -new -key ${etcd_dir}/apiserver-etcd-client.key  -config ${etcd_dir}/apiserver-etcd-client-csr.conf -out ${etcd_dir}/apiserver-etcd-client.csr
openssl x509 -req -in ${etcd_dir}/apiserver-etcd-client.csr -CA ${etcd_dir}/ca.crt -CAkey ${etcd_dir}/ca.key -CAcreateserial -out ${etcd_dir}/apiserver-etcd-client.crt -days $inter_days -extensions v3_ext -extfile ${etcd_dir}/apiserver-etcd-client-csr.conf
}


# 生成k8s的CA的key和cert
generate_k8s_ca () {
print_msg 'Generate k8s for key and cert!'
openssl genrsa -out ${k8s_dir}/ca.key 2048
openssl req -x509 -new -nodes -key ${k8s_dir}/ca.key -subj "/CN=kubernetes" -days $inter_days -out ${k8s_dir}/ca.crt
}

# 生成k8s的apiserver的key和cert
generate_k8s_apiserver () {
print_msg 'Generate k8s-apiserver for key and cert!'
openssl genrsa -out ${k8s_dir}/apiserver.key 2048

cat > ${k8s_dir}/apiserver-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = kube-apiserver

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = HOSTNAME
DNS.2 = kubernetes
DNS.3 = kubernetes.default
DNS.4 = kubernetes.default.svc
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = 10.0.0.1
IP.2 = 127.0.0.1
IP.3 = HOSTIP
IP.4 = LBIP

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names
EOF

sed -i "s#HOSTNAME#${HOSTNAME}#g" ${k8s_dir}/apiserver-csr.conf
sed -i "s#HOSTIP#${HOSTIP}#g" ${k8s_dir}/apiserver-csr.conf

if [ -z $LBIP ] ; then
sed -i '/LBIP/d' ${k8s_dir}/apiserver-csr.conf
else
sed -i "s#LBIP#${LBIP}#g" ${k8s_dir}/apiserver-csr.conf
fi

openssl req -new -key ${k8s_dir}/apiserver.key  -config ${k8s_dir}/apiserver-csr.conf -out ${k8s_dir}/apiserver.csr
openssl x509 -req -in ${k8s_dir}/apiserver.csr -CA ${k8s_dir}/ca.crt -CAkey ${k8s_dir}/ca.key -CAcreateserial -out ${k8s_dir}/apiserver.crt -days $inter_days -extensions v3_ext -extfile ${k8s_dir}/apiserver-csr.conf
}

# 生成k8s的apiserver-kubelet-client的key和cert
generate_apiserver_kubelet_client () {
print_msg 'Generate apiserver-kubelet-client for key and cert!'
openssl genrsa -out ${k8s_dir}/apiserver-kubelet-client.key 2048

cat > ${k8s_dir}/apiserver-kubelet-client-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = kube-apiserver-kubelet-client
O = system:masters

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=clientAuth
EOF

openssl req -new -key ${k8s_dir}/apiserver-kubelet-client.key  -config ${k8s_dir}/apiserver-kubelet-client-csr.conf -out ${k8s_dir}/apiserver-kubelet-client.csr
openssl x509 -req -in ${k8s_dir}/apiserver-kubelet-client.csr -CA ${k8s_dir}/ca.crt -CAkey ${k8s_dir}/ca.key -CAcreateserial -out ${k8s_dir}/apiserver-kubelet-client.crt -days $inter_days -extensions v3_ext -extfile ${k8s_dir}/apiserver-kubelet-client-csr.conf
}


# 生成front-proxy的CA的key和cert
generate_front_proxy_ca () {
print_msg 'Generate front-proxy for key and cert!'
openssl genrsa -out ${k8s_dir}/front-proxy-ca.key 2048
openssl req -x509 -new -nodes -key ${k8s_dir}/front-proxy-ca.key -subj "/CN=front-proxy-ca" -days $inter_days -out ${k8s_dir}/front-proxy-ca.crt
}

# 生成front-proxy的front-proxy-client的key和cert
generate_front_proxy_client () {
print_msg 'Generate front-proxy-client for key and cert!'
openssl genrsa -out ${k8s_dir}/front-proxy-client.key 2048

cat > ${k8s_dir}/front-proxy-client-csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = front-proxy-client

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=clientAuth
EOF

openssl req -new -key ${k8s_dir}/front-proxy-client.key  -config ${k8s_dir}/front-proxy-client-csr.conf -out ${k8s_dir}/front-proxy-client.csr
openssl x509 -req -in ${k8s_dir}/front-proxy-client.csr -CA ${k8s_dir}/front-proxy-ca.crt -CAkey ${k8s_dir}/front-proxy-ca.key -CAcreateserial -out ${k8s_dir}/front-proxy-client.crt -days $inter_days -extensions v3_ext -extfile ${k8s_dir}/front-proxy-client-csr.conf
}

generate_sa () {
print_msg 'Generate SA for PRIVATE KEY and  PUBLIC KEY!'
openssl genrsa -out ${k8s_dir}/sa.key 2048
openssl rsa -in ${k8s_dir}/sa.key -pubout -out  ${k8s_dir}/sa.pub
}

copy_cert () {
KUBERNETES_PKI_DIR="/etc/kubernetes/pki"
mkdir -p ${KUBERNETES_PKI_DIR}/etcd

for i in apiserver.crt apiserver.key  ca.crt  front-proxy-ca.crt  front-proxy-client.key   apiserver-kubelet-client.crt  ca.key  front-proxy-ca.key  sa.key   apiserver-kubelet-client.key  front-proxy-client.crt  sa.pub
do

\cp -r $k8s_dir/${i[@]} $KUBERNETES_PKI_DIR/
done

cp $etcd_dir/apiserver-etcd-client.crt $KUBERNETES_PKI_DIR/
cp $etcd_dir/apiserver-etcd-client.key $KUBERNETES_PKI_DIR/

for j in ca.crt  ca.key  healthcheck-client.crt  healthcheck-client.key  peer.crt  peer.key  server.crt  server.key
do
\cp -r $etcd_dir/${j[@]} $KUBERNETES_PKI_DIR/etcd/
done

}

etcd () {
print_msg 'ETCD!'
etcd_dir='etcd'

if [ ! -d "${etcd_dir}" ] ; then
mkdir $etcd_dir
rm -rf ${etcd_dir}/*
fi

sign_date
generate_etcd_ca
generate_etcd_server
generate_etcd_peer
generate_etcd_healthcheck
generate_apiserver_etcd_client
}

k8s () {
print_msg 'Kubernetes!'
k8s_dir='k8s'
if [ ! -d "${k8s_dir}" ] ; then
mkdir $k8s_dir
rm -rf ${k8s_dir}/*
fi

generate_k8s_ca
generate_k8s_apiserver
generate_apiserver_kubelet_client
generate_front_proxy_ca
generate_front_proxy_client
generate_sa
}

main () {
etcd
k8s
copy_cert
print_msg 'Finished!'
}

main