---
title: 如何在ECS上动态部署Hexo博客
date: 2020-03-26
tags: [HEXO]
categories: [工具]
---


<!-- more -->  
# ECS购买

阿里云买3年套餐，

* 开通80端口
* 重置Root密码
*  SSH连接ECS

# ECS配置

## 创建git用户

```bash
adduser git
chmod 740 /etc/sudoers
vim /etc/sudoers
# 找到以下内容
#Allow root to run any commands anywhereroot    ALL=(ALL)     ALL
# 在下面添加一行
git ALL=(ALL) ALL
# 保存退出后改回权限
chmod 400 /etc/sudoers
# 随后设置Git用户的密码，
sudo passwd git
```

## 配置git用户免密登陆

```bash
# 切换至git用户，创建 ~/.ssh 文件夹和 ~/.ssh/authorized_keys 文件，并赋予相应的权限
su git
mkdir ~/.ssh
vim ~/.ssh/authorized_keys
#然后将电脑中执行 cat ~/.ssh/id_rsa.pub | pbcopy ,将公钥复制粘贴到authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

## 安装软件
```bash
yum -y update
yum install -y git nginx
```

## 创建静态文件目录

```
mkdir -p /home/geosmart.top
```

## 配置nginx

```json
server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  geosmart.top;
        root         /home/geosmart.top;

        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
```
## 配置git更新自动同步到静态目录
```bash
#新建git库目录：
cd /home/git
git init --bare blog.git

#使用 git-hooks 同步网站根目录
vim /home/git/blog.git/hooks/post-receive
# post-receive文件内容如下:
#!/bin/sh
git --work-tree=/home/geosmart.top --git-dir=/home/git/blog.git checkout -f
# 设置权限
chmod +x hooks/post-receive
```

# 配置hexo发布
_config.yml配置

```yaml
deploy:
    type: git
    repo: git@47.114.57.4:/home/git/blog.git
    branch: master
    message: u
```

发布命令：hexo d -g


# 问题
## hexo deploy权限问题

sudo chmod -R ug+w .;