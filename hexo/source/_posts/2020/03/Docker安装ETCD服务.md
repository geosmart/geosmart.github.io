---
title: Docker安装ETCD服务
date: 2020-03-28
tags: [Docker,ETCD]
categories: [OPS]
---

记录docker容器安装etcd，以及etcd的日常使用命令
<!-- more -->  

# 制作etcd docker镜像
```shell
FROM alpine:latest

ADD etcd /usr/local/bin/
ADD etcdctl /usr/local/bin/
RUN mkdir -p /var/etcd/
RUN mkdir -p /var/lib/etcd/

# Alpine Linux doesn't use pam, which means that there is no /etc/nsswitch.conf,
# but Golang relies on /etc/nsswitch.conf to check the order of DNS resolving
# (see https://github.com/golang/go/commit/9dee7771f561cf6aee081c0af6658cc81fac3918)
# To fix this we just create /etc/nsswitch.conf and add the following line:
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

EXPOSE 2379 2380

# Define default command.
CMD ["/usr/local/bin/etcd"]
```

```shell
# 下载etcd Releases 
wget https://github.com/etcd-io/etcd/releases/download/v3.4.5/etcd-v3.4.5-linux-amd64.tar.gz
# 解压文件
tar -zxvf etcd-v3.4.5-linux-amd64.tar.gz
# 将etcd和etcdctl移动到和dockerfile同级目录
mv etcd-v3.4.5-linux-amd64/etcd etcd-v3.4.5-linux-amd64/etcdctl -t ./
# 构建etcd镜像
docker build -t etcd .
# 查看构建好的镜像
docker images
```

# 启动 etcd docker实例
```shell
docker run -d -v /usr/share/ca-certificates/:/etc/ssl/certs \
 -p 4001:4001 -p 2380:2380 -p 2379:2379 \
 --name etcd etcd /usr/local/bin/etcd \
 -name etcd0 \
--data-dir /etcd-data \
--enable-v2=true \
-advertise-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
-listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
-initial-advertise-peer-urls http://0.0.0.0:2380 \
-listen-peer-urls http://0.0.0.0:2380 \
-initial-cluster-token etcd-cluster-1 \
-initial-cluster etcd0=http://0.0.0.0:2380 \
-initial-cluster-state new \
--log-level info \
--logger zap \
--log-outputs stderr
# 查看状态
curl http://127.0.0.1:2379/version
curl -L http://127.0.0.1:2379/health
```

# 验证etcd http服务
```shell
# 插入kv
curl http://127.0.0.1:2379/v2/keys/message -XPUT -d value="Hello world"
curl http://192.168.135.3:2379/v3/keys/message
curl http://127.0.0.1:2379/v2/stats/store
```
