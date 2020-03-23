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
