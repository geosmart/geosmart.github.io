title: CentOS配置本地Yum源
date: 2015-12-07 18:59:18
tags: [yum,CentOS]
categories: [运维]
---

现场环境没有网络，有些软件安装简直太痛苦，和maven的依赖链一样，最终耗时耗力不一定能安装好，此时制作本地yum只读光盘就是一个好主意，此文主要介绍如何配置本地yum。
- - -
<!-- more -->

# 建立本地源目录
`mkdir   /mnt/cdrom`
# 挂载CentOS光盘
`mount   /dev/cdrom    /mnt/cdrom`

# 备份repo
进入/etc/yum.repos.d目录，可以看到四个文件分别为CentOS-Base.repo、 CentOS-Media.repo 、CentOS-Vault.repo、CentOS-Vault.repo.repo,将其中三个改名或者移走留下CentOS-Media.repo
```bash
cd /etc/yum.repos.d
mv  CentOS-Base.repo     CentOS-Base.repo.bak
mv  CentOS-Vault.repo     CentOS-Vault.repo.bak
mv  CentOS-Vault.repo     CentOS-Vault.repo.bak
cp  CentOS-Media.repo     CentOS-Vault.Media.bak
```
# 编辑CentOS-Media.repo
编辑CentOS-Media.repo：`vi  CentOS-Media.repo`
将以下内容
```bash
[c6-media]
name=CentOS-$releasever - Media
baseurl=file:///media/CentOS/
        file:///media/cdrom/
        file:///media/cdrecorder/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
```
修改为
```bash
[c6-media]
name=CentOS-$releasever - Media
baseurl=file:///mnt/cdrom/  #这里为本地源路径
        file:///media/cdrom/
        file:///media/cdrecorder/
gpgcheck=1
enabled=1    ##开启本地源
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
```
修改好保存并退出

# 清yum缓存
`yum   clean  `   

# 备注
如需要将yum源改为网络，还原`/etc/yum.repos.d`目录下的四个文件即可！
