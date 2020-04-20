---
title: Kubeadm安装K8S集群
date: 2020-04-08 14:36:33
tags: [DevOps,Kubeadm,Kubernetes]
categories: [OPS]
---

记录如何用kubernetes官方提供的kubeadm工具安装k8s集群
<!-- more -->
# 准备工作
* host配置
* SSH免密登录配置
* 清理已有安装：
```bash
kubectl drain geolab.master --ignore-daemonsets
kubectl delete node geolab.master
kubeadm reset
```
# 重新安装
## 设置国内阿里云镜像
添加阿里云源,安装kubelet,kubeadm,kubectl
```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
# 开机自启
systemctl enable kubelet && systemctl start kubelet
```

# master安装
## 准备k8s依赖的镜像
```bash 
#!/bin/bash
for i in `kubeadm config images list`; do 
  imageName=${i#k8s.gcr.io/}
  docker pull registry.aliyuncs.com/google_containers/$imageName
  docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.aliyuncs.com/google_containers/$imageName
done;
```

## 安装k8s
kubeadm init  --kubernetes-version=v1.18.1 --apiserver-advertise-address=192.168.135.3 --pod-network-cidr=10.10.0.0/16   --ignore-preflight-errors=Swap
输出
```bash
[root@geolab ~]# kubeadm init  --kubernetes-version=v1.18.1 --apiserver-advertise-address=192.168.135.3 --pod-network-cidr=10.10.0.0/16   --ignore-preflight-errors=Swap
W0411 16:32:29.608282   40905 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.18.1
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [geolab.master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.135.3]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [geolab.master localhost] and IPs [192.168.135.3 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [geolab.master localhost] and IPs [192.168.135.3 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0411 16:32:34.260249   40905 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0411 16:32:34.261367   40905 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 19.002848 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node geolab.master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node geolab.master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 2rmc0j.ef90k3cxqzuo15df
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

```

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

## master安装dashboard
```
# 卸载已有
# kubectl delete ns kubernetes-dashboard
# 安装
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc7/aio/deploy/recommended.yaml
# 启动proxy
kubectl proxy --address='0.0.0.0' --port=9090 --accept-hosts='^*$' 

# 查看token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') 
# 登陆
http://192.168.135.3:9090/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
```

# woker加入master
kubeadm token create --print-join-command

```bash
# 创建token
kubeadm token create
# 列出创建的token
kubeadm token list		
# 查到discovery-token-ca-cert-hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt |openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex |sed 's/^.* //'
#加入节点
kubeadm join 192.168.135.3:6443  \
--token 1ialrj.w5hb23c97wmwclcy  \
–-discovery-token-unsafe-skip-ca-verification  \
--discovery-token-ca-cert-hash  \
sha256:0d347e9a2dd9e45724bd2c9d264525813f5bd7a51ead73e1b87348ff1c7e5672  \
-v=10
```

# 问题
## worker在joins时couldn't validate the identity of the API Server
```bash
[root@geolab ~]# kubeadm join 192.168.135.3:6443 --token gcwq0r.2da1200lrzpurxro     --discovery-token-ca-cert-hash sha256:0d347e9a2dd9e45724bd2c9d264525813f5bd7a51ead73e1b87348ff1c7e5672 
W0411 08:27:49.560351   11398 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
error execution phase preflight: couldn't validate the identity of the API Server: Get https://192.168.135.3:6443/api/v1/namespaces/kube-public/configmaps/cluster-info?timeout=10s: x509: certificate has expired or is not yet valid
To see the stack trace of this error execute with --v=5 or higher
```
--v5后显示的错误
curl https://192.168.135.3:6443/api/v1/nodes/geolab.worker?timeout=10s 
  "message": "nodes \"geolab.worker\" is forbidden: User \"system:anonymous\" cannot get resource \"nodes\" in API group \"\" at the cluster scope",
解决：还么解决。。。

# 参考
* [kubeadm](https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/kubeadm/)
* [阿里云镜像安装k8s](https://blog.csdn.net/qq_34348168/article/details/84137311)
* [基于kubeadm的国内镜像源安装](https://cloud.tencent.com/developer/article/1525487)
* [kubeadm安装k8s完整教程](https://segmentfault.com/a/1190000021209788)