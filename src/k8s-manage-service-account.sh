#!/bin/sh

THIS_FILE_PATH=$(
  cd $(dirname $0)
  pwd
)

# import base lib
source "$THIS_FILE_PATH/sh-lib-path-resolve.sh"

###
# functions
###
#获取访问令牌
function get_service_account_token() {
  SECRET_TOKEN_NAME=$(kubectl get serviceaccount $SERVICE_ACOUNT_NAME -n $SERVICE_ACOUNT_NS -o jsonpath="{.secrets[0].name}")
  #SECRET_TOKEN_VALUE=$(kubectl get secret $SECRET_TOKEN_NAME -o jsonpath="{.data.token}" | base64 --decode)
  SECRET_TOKEN_VALUE=$(kubectl describe secret $SECRET_TOKEN_NAME -n kube-system | grep "token:" | sed "s/token:      //g")
  echo $SECRET_TOKEN_NAME
  echo $SECRET_TOKEN_VALUE
}

#创建服务账号
if [[ "$ACTION" =~ '创建' ]]; then
  kubectl create serviceaccount $SERVICE_ACOUNT_NAME -n $SERVICE_ACOUNT_NS
fi
#绑定集群角色
if [[ "$ACTION" =~ '绑定' ]]; then
  kubectl create clusterrolebinding $CLUTER_ROLE_BINDING_NAME --clusterrole=$CLUTER_ROLE_NAME --serviceaccount=${SERVICE_ACOUNT_NS}:${SERVICE_ACOUNT_NAME}
fi
if [[ "$ACTION" =~ '获取' ]]; then
  get_service_account_token
fi

#### 参考文献
# Kubernetes-dashboard安装、配置令牌和kubeconfig登录
# https://blog.csdn.net/bbwangj/article/details/82790026

:: <<EOF
#创建一个只能对default名称空间有权限的serviceaccount，它的名字是def-ns-admin
#这种情况下的权限较小，用token登陆后只能对default名称空间有权限

#创建服务账号
kubectl create serviceaccount def-ns-admin -n default
#绑定集群角色
kubectl create rolebinding def-ns-admin --clusterrole=admin --serviceaccount=default:def-ns-admin


#账号名字
SERVICE_ACOUNT_NAME=def-ns-admin
#命名空间
SERVICE_ACOUNT_NS=default
#角色名字
CLUTER_ROLE_NAME=admin
#账号角色绑定名字
ROLE_BINDING_NAME=def-ns-admin
#创建服务账号
kubectl create serviceaccount $SERVICE_ACOUNT_NAME -n $SERVICE_ACOUNT_NS
#绑定集群角色
kubectl create rolebinding  $ROLE_BINDING_NAME --clusterrole=$CLUTER_ROLE_NAME --serviceaccount=${SERVICE_ACOUNT_NS}:${SERVICE_ACOUNT_NAME}
#获取访问令牌
SECRET_TOKEN_NAME=$(kubectl get serviceaccount $SERVICE_ACOUNT_NAME -n $SERVICE_ACOUNT_NS -o jsonpath="{.secrets[0].name}")
#SECRET_TOKEN_VALUE=$(kubectl get secret $SECRET_TOKEN_NAME -o jsonpath="{.data.token}" | base64 --decode)
SECRET_TOKEN_VALUE=$(kubectl describe secret $SECRET_TOKEN_NAME -n kube-system | grep "token:" | sed "s/token:      //g")
echo $SECRET_TOKEN_NAME
echo $SECRET_TOKEN_VALUE

# 设置集群的认证
kubectl config set-cluster kubernetes --certificate-authority=./ca.crt --server="https://10.0.0.100:6443" --embed-certs=true --kubeconfig=/root/def-ns-admin.conf
# 查看集群的配置
kubectl config view --kubeconfig=/root/def-ns-admin.conf

# 获取集群的令牌
kubectl describe secret def-ns-admin-token-xdvx5

# 设置集群的认证
kubectl config set-credentials def-ns-admin --token=eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZi1ucy1hZG1pbi10b2tlbi14ZHZ4NSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJkZWYtbnMtYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI5MjhiYmNhMS0yNDVjLTExZTktODFjYy0wMDBjMjkxZTM3YzIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpkZWYtbnMtYWRtaW4ifQ.EzUF13MElI8b-kuQNh_u1hGQpxgoffm4LdTVoeORKUBTADwqHEtW2arj76oZuI-wQyy5P0v5VvOoefr6h3NpIgbAze8Lqyrpg9wO0Crfi30IE1kZ2wUPYU9P_5inMxmCPLttppyPyc8mQKDkOOB1xFUmEebC63my-dG4CZljsd8zwNU6eXnhaThSUUn12UTvRsbSBLD-dvau1OY6YgDL6mgFl3cVqzCPd7ELpEyNYWCh3x5rcRfCcjcHGfUOrWY2NvdW50Iiwia3ViZXJpby9-CI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2 --kubeconfig=/root/def-ns-admin.conf

# 设置集群上下文
CLUSTER_NAME=
USER_NAME=
CONFIG_FILE=
kubectl config set-context def-ns-admin@kubernetes --cluster=kubernetes --user=def-ns-admin --kubeconfig=/root/def-ns-admin.conf
# 切换集群上下文
kubectl config use-context def-ns-admin@kubernetes --kubeconfig=/root/def-ns-admin.conf
# 设置集群的认证
kubectl config view --kubeconfig=/root/def-ns-admin.conf

#### 参考文献
# K8S关于Dashboard浏览器访问填坑
# https://blog.csdn.net/loveyourselfjiuhao/article/details/91044268
EOF
