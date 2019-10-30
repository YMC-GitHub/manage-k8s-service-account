#!/bin/sh

########
# k8s授权：rbac-权限检查
########

USER_NAME=yemiancheng
USER_CERT_CSR_FILE=${USER_NAME}.csr
USER_CERT_KEY_FILE=${USER_NAME}.key
USER_CERT_CRT_FILE=${USER_NAME}.crt
# 有多少集群：
# kubectl config view
# 证书放在哪：
# ls /etc/kubernetes/pki/
# cd /etc/kubernetes/pki/
# 创建某私钥:
# umask 077; openssl genrsa -out $USER_CERT_KEY_FILE 2048
# 查看某私钥：
# cat $USER_CERT_KEY_FILE
# 创建某证书：
openssl req -new -key $USER_CERT_KEY_FILE -out $USER_CERT_CSR_FILE -subj "/CN=${USER_NAME}"
# 查看某证书：
cat $USER_CERT_CSR_FILE
# 查看某签证：
cat ca.crt
cat ca.key
# 签证某证书：
openssl x509 -req -in $USER_CERT_CSR_FILE -CA ca.crt -CAkey ca.key -CAcreateserial -out $USER_CERT_CRT_FILE -days 365
# 查看某证书：
cat $USER_CERT_CSR_FILE
openssl x509 -in $USER_CERT_CRT_FILE -text -noout
# 用某证认证：
kubectl config set-credentials mageedu  --client-certificate=./$USER_CERT_CRT_FILE --client-key=./$USER_CERT_KEY_FILE --embed-certs=true
# 有哪些集群：（集群名字，集群登录用户名字，集群上下文名字）
kubectl config view
# 让它访集群：
kubectl config set-context  kubernetes-admin@kubernetes --cluster=kubernetes --user=$USER_NAME
# kubectl config set-context  kubernetes-admin@kubernetes --cluster=kubernetes --user=kubernetes-admin
# 切换上下文：
kubectl config use-context kubernetes-admin@kubernetes
# 访问某集群：
kubectl get pods
kubectl get pods --namespace=kube-system 

##### 参考文献
# k8s之serviceaccount,登录账号创建
# https://www.cnblogs.com/leiwenbin627/p/11324806.html
# 纯手工搭建k8s集群-(三)认证授权和服务发现
# https://www.kubernetes.org.cn/3789.html
