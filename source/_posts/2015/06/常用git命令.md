title: 常用git命令
date: 2015-06-30 13:18:03
tags: [Git]
categories: [版本控制]
---

用github来搭建个人技术笔记，少不了记录一些常用的git命令
- - -
<!-- more -->
# Git
[Git基础](http://git-scm.com/book/zh/v2/%E8%B5%B7%E6%AD%A5-Git-%E5%9F%BA%E7%A1%80)  
[用爱一起画Git](http://yanminx.com/blog/understand-git-by-drawing)  
[参考教程](https://www.atlassian.com/git/tutorials/)  

#  克隆库
```
git clone https://github.com/geosmart/geosmart.io
```
#  新建 'gh-pages'分支，会自动生成github pages
```
git checkout --orphan gh-pages  
```
#  本地提交
```
git commit -a -m "commit message"
```
#  初始版本提交
```
git push --set-upstream origin master
或
git push origin master
```
#  推送到服务器
```
git push origin  
```  
#   git同步配置
```
git sync
git config --global credential.helper store
git config --global push.default matching
```
#  git bash记住密码
## 设置环境变量
在windows中添加一个HOME环境变量，变量名:HOME,变量值：%USERPROFILE%
## 创建git用户名和密码存储文件
进入%HOME%目录，新建一个名为 "_netrc" 的文件，文件中内容格式如下：
```yaml
machine {git account name}.github.com
login your-usernmae
password your-password
```
重新打开git bash即可，无需再输入用户名和密码

#  查看git配置
```
git config --list
```

# 问题记录
 ## CAfile: C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt
You have to fix the path to bin/curl-ca-bundle.crt. I had to specify the absolute path, using back-slashes:
`git config --system http.sslcainfo "C:\Program Files (x86)\git\bin\curl-ca-bundle.crt"``
or — not really recommended — you may choose to switch off SSL checks completely by executing:
`git config --system http.sslverify false`
