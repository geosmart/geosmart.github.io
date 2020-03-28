aty---
title: Docker的安装与使用
date: 2020-03-27
tags: [Docker]
categories: [运维]
---

记录docker的安装部署和日常使用命令
<!-- more -->  

# 准备工作
## 确认系统版本
```shell
cat /etc/redhat-release 
CentOS Linux release 7.7.1908 (Core)
```
## 配置yum
```shell
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
```

# 安装Docker
```shell
sudo yum update
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

# 添加docker的yum源
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# 更新yum
sudo yum update
# 安装docker
sudo yum install docker-ce

```

# 配置docker
```shell
# 加入 docker 用户组命令
sudo usermod -aG docker geolab
# 开机启动
sudo systemctl enable docker
# 启动docker
sudo systemctl start docker
# 验证docker
sudo docker run hello-world
```

## 配置阿里云镜像加速
关于加速器的地址，登陆[阿里云控制台](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)获取
添加以下内容
```json
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["address"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

```bash
# 重启docker
systemctl daemon-reload
systemctl restart docker
# 将 --registry-mirror 加入到你的 Docker 配置文件
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io

# 重启docker
service docker restart
```

# docker常用命令

# 问题