---
title: Kuboard安装K8S集群
date: 2020-04-01 14:36:33
tags: [DevOps,Kuboard,Kubernetes]
categories: [OPS]
---

记录如何用kuboard工具安装k8s集群
<!-- more -->
[kuboard界面](kuboard.jpg)
# 检查网络
```shell
# master  修改 hostname
hostnamectl set-hostname geolab.demo

# 查看修改结果
hostnamectl status
# 设置 hostname 解析
echo "127.0.0.1   $(hostname)" >> /etc/hosts
```
# 安装docker及kubelet
```shell
# 在 master 节点和 worker 节点都要执行
# 最后一个参数 1.18.0 用于指定 kubenetes 版本，支持所有 1.18.x 版本的安装
# 腾讯云 docker hub 镜像
# export REGISTRY_MIRROR="https://mirror.ccs.tencentyun.com"
# DaoCloud 镜像
# export REGISTRY_MIRROR="http://f1361db2.m.daocloud.io"
# 华为云镜像
# export REGISTRY_MIRROR="https://05f073ad3c0010ea0f4bc00b7105ec20.mirror.swr.myhuaweicloud.com"
# 阿里云 docker hub 镜像
export REGISTRY_MIRROR=https://registry.cn-hangzhou.aliyuncs.com
curl -sSL https://kuboard.cn/install-script/v1.18.x/install_kubelet.sh | sh -s 1.18.0
```

# master配置
## 初始化master节点
```shell
# 只在 master 节点执行
# 替换 x.x.x.x 为 master 节点实际 IP（请使用内网 IP）
# export 命令只在当前 shell 会话中有效，开启新的 shell 窗口后，如果要继续安装过程，请重新执行此处的 export 命令
export MASTER_IP=192.168.135.3
# 替换 apiserver.demo 为 您想要的 dnsName
export APISERVER_NAME=geolab.demo
# Kubernetes 容器组所在的网段，该网段安装完成后，由 kubernetes 创建，事先并不存在于您的物理网络中
export POD_SUBNET=10.100.0.1/16
echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts
curl -sSL https://kuboard.cn/install-script/v1.18.x/init_master.sh | sh -s 1.18.0
```

## 检查 master 初始化结果
```shell
# 只在 master 节点执行

# 执行如下命令，等待 3-10 分钟，直到所有的容器组处于 Running 状态
watch kubectl get pod -n kube-system -o wide

# 查看 master 节点初始化结果
kubectl get nodes -o wide
```

# worker配置
master执行获取join命令
```shell
kubeadm token create --print-join-command
```

>该 token 的有效时间为 2 个小时，2小时内，您可以使用此 token 初始化任意数量的 worker 节点。

```shell
# 只在 worker 节点执行
# 替换 x.x.x.x 为 master 节点的内网 IP
export MASTER_IP=192.168.135.3
# 替换 apiserver.demo 为初始化 master 节点时所使用的 APISERVER_NAME
export APISERVER_NAME=geolab.demo
echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts

# 替换为 master 节点上 kubeadm token create 命令的输出
kubeadm join geolab.demo:6443 --token bekn32.5jf2ih9zo2qptfw9     --discovery-token-ca-cert-hash sha256:3c8e58572a57f14b8de1ca3368d2c6eae9831a1fb6b1fcc6d35fce334bfaf78f 
```
// todo 重新加入master


# master检测配置结果
```shell
# 查看 master 节点初始化结果
kubectl get nodes -o wide
```

# 官方可视化工具Kubernetes Dashboard
```shell
# 安装 Kubernetes Dashboard
kubectl apply -f https://kuboard.cn/install-script/k8s-dashboard/v2.0.0-beta5.yaml
# 创建 Service Account 和 ClusterRoleBinding
kubectl apply -f https://kuboard.cn/install-script/k8s-dashboard/auth.yaml
# 获取Bearer Token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
# 启动kubernetes dashboard
nohup kubectl proxy --address='0.0.0.0' --port=9090 --accept-hosts='^*$' &
```
访问路径： http://192.168.135.3:9090/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/


# Kuboard可视化工具
## 安装Kuboard
```shell
kubectl apply -f https://kuboard.cn/install-script/kuboard.yaml
kubectl apply -f https://addons.kuboard.cn/metrics-server/0.3.6/metrics-server.yaml
kubectl get pods -l k8s.eip.work/name=kuboard -n kube-system
```

## 获取Kuboard界面地址
获取Token
```shell
kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep kuboard-user | awk '{print $1}') -o go-template='{{.data.token}}' | base64 -d
```
http://192.168.135.3:32567/dashboard?k8sToken=获取的Token

# 参考
* [kuboard](https://kuboard.cn/)

