title: Python安装升级教程
date: 2015-08-05 20:32:44
tags: [CentOS,Python]
categories: [运维] 
---

# 升级前安装依赖
`yum groupinstall "Development tools" `

# Python 2.7.9 下载>解压>编译>安装 
```
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz 
tar jxvf Python-2.7.9.tgz   
mv Python-2.7.9  python
cd python
./configure --prefix=/usr/local/python
make && make altinstall 
```

* 关于altinstall
``` 
  Warning
 make install can overwrite or masquerade the python binary. make altinstall is therefore recommended instead of make install since it only installs exec_prefix/bin/pythonversion.
```


# 修改系统默认Python

1.  查看已有python版本
`python -V`
2.  查看Python版本
`/usr/local/python/bin/python2.7 -V`
3.  将系统默认Python改为新安装的Python
`ln -fs /usr/local/python/bin/python2.7 /usr/bin/python`

# yum无法运行问题
进行更改后，yum会无法运行了。修改/usr/bin/yum文件，将第一行的  
`#!/usr/bin/python`  
中的python改为系统原有的python版本，如下：  
`#!/usr/bin/python2.6`  



