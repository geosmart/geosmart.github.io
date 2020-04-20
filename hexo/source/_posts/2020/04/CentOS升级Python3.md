---
title: CentOS升级Python3
date: 2020-04-19 10:50:45
categories: [OPS]
---

OPS笔记：centos7系统默认python2升级python3
<!-- more -->

# 安装python
```shell
wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
tar -zxvf Python-3.7.0.tgz
mkdir /usr/local/python3
cd Python-3.7.0
./configure --prefix=/usr/local/python3
make && make install
```

# 设置默认python软连接
```shell
rm -rf /usr/bin/python
rm -rf /usr/bin/pip
rm -rf /usr/bin/python3-config

ln -s /usr/local/python3/bin/python3.7 /usr/bin/python
ln -s /usr/local/python3/bin/python3.7 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3.7 /usr/bin/pip
ln -s /usr/local/python3/bin/pip3.7 /usr/bin/pip3
ln -s /usr/local/python3/bin/python3.7-config /usr/bin/python3-config

```
# 测试python是否可用
```shell
python2 --version
python3 --version
python --version
```

# yum改为python2
```shell
vi /usr/bin/yum
将第一行"#!/usr/bin/python" 改为 "#!/usr/bin/python2"。
# vi /usr/libexec/urlgrabber-ext-down
将第一行"#!/usr/bin/python" 改为 "#!/usr/bin/python2"即可。
```