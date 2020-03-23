#!/bin/sh

#账号名字
SERVICE_ACOUNT_NAME=dashboard-admin
#命名空间
SERVICE_ACOUNT_NS=kube-system
#角色名字
CLUTER_ROLE_NAME=cluster-admin
#账号角色绑定名字
CLUTER_ROLE_BINDING_NAME=dashboard-cluster-admin
#操作行为
ACTION="创建|绑定|获取" #"创建|绑定|获取"
