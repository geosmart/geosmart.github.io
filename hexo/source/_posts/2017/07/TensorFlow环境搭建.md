---
title: TensorFlow环境搭建
date: 2017-07-01 11:46:21
tags: [AI,Python]
categories: 机器学习
---


将近一年未更新博客，期间专注做互联网金融领域的身份识别类产品（身份证OCR、活体检测、人脸比对），现在产品线趋于成熟，可以静下心来研究神往已久的深度学习了。
- - -
<!-- more -->

# Anaconda安装
Anaconda是一个和Canopy类似的Python科学计算环境，但用起来更加方便。
* 下载：`wget https://repo.continuum.io/archive/Anaconda3-4.4.0-Linux-x86_64.sh`
* 安装：`bash Anaconda3-4.4.0-Linux-x86_64.sh`
* 配置：
```bash
# 将anaconda的bin目录加入PATH
echo 'export PATH="~/anaconda3/bin:$PATH"' >> ~/.bashrc
# 更新bashrc以立即生效
source ~/.bashrc
配置好PATH后，可以通过 which conda 或 conda --version 命令检查是否正确；
# 配置镜像
安装完以后，打开Anaconda Prompt，输入清华的仓库镜像，更新包更快；
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --set show_channel_urls yes
```

# TensorFlow安装
* 打开Anaconda Prompt，输入：`conda create -n tensorflow python=3.6`
* 查看已安装环境列表: `conda env list`；
* 激活环境：
    * linux：`source activate tensorflow`；
    * windows：`activate tensorflow`；
* 安装tensorflow的CPU版本，
    * linux安装：`pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.2.1-cp36-cp36m-linux_x86_64.whl`
    * windows安装：`pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/windows/cpu/tensorflow-1.2.1-cp36-cp36m-win_amd64.whl`

# HelloWorld示例
一个TensorFlow示例实现两个向量求和
```python
import tensorflow as tf
a=tf.constant([1.0,2.0],name="a")
b=tf.constant([2.0,3.0],name="b")
result=a+b
sess=tf.Session() 
sess.run(result)
```

# 开发环境
IDE：pycharm 2017  
注册服务器：http://idea.iteblog.com/key.php  
## pycharm远程调试
以pycharm配置remote interpreter远程开发调试，并以ssh自动上传本地程序到测试/生产环境； 
配置参考[feature-spotlight-python-remote-development-with-pycharm](https://blog.jetbrains.com/pycharm/2015/03/feature-spotlight-python-remote-development-with-pycharm/)


# 归档环境
[Jupyter Notebook](http://jupyter.org/)
[Jupyter Notebook-machine_learning](http://nbviewer.jupyter.org/github/masinoa/machine_learning/tree/master/)
1. 一次运行, 多次阅读,保存运行结果
2. 交互式编程, 边看边写
3. 可以添加各种元素,比如图片,视频, 链接, 文档(比代码注释要好看), 相当于PPT
[ref](http://python.jobbole.com/87527/?repeat=w3tc)
# 问题记录