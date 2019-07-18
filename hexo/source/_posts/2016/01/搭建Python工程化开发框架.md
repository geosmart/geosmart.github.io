title: 搭建Python工程化开发框架
date: 2016-01-20 14:40:10
tags: [Python]
categories: [脚本工具]
---

2016的元月以python作为开端。  
采用python进行网络数据聚合抽取，需调研并搭建python工程化开发框架，几番迭代，一个适用于数据采集的开发环境搭建完成：
* 开发环境：python2.7.10 32位/pycharm5
* 项目构建：virtualenv/virtualenvWrapper 虚拟运行环境；pip 依赖项管理；pyBuilder项目构建，其中pyBuilder以disutils用于项目打包
* 项目文档：mkdocs/sphinx；参考[python-guide-writing](http://docs.python-guide.org/en/latest/writing/documentation/)
* Web框架：Tornado/web,py（非阻塞式web服务器，精简）；django（文档功能齐全，但生态封闭）
* 单元测试：unittest/coverage(测试覆盖率统计)
* 并行框架：gevent(多线程)+monkey patch(运行时动态替换模块)，multiprocessing(多进程)
* 爬虫框架：scrapy/selenium
* 接口设计： zope.interface
* 编码风格：[google-python-styleguide](http://zh-google-styleguide.readthedocs.org/en/latest/google-python-styleguide/contents/)

- - -
<!-- more -->
pip install -i  http://pypi.douban.com/simple  Shapely --trusted-host pypi.douban.com

# pip源配置
## 临时换源
临时换源只在某一条命令中生效，只要在命令中加上”-i“，指定使用的源即可`pip install scrapy -i url`，  
如安装pandas：`pip install -i  http://pypi.douban.com/simple  pandas --trusted-host pypi.douban.com`
## 永久换源
要是想永久更改pip源，在pip的配置文件（~/.pip/pip.conf）中增加
```shell
[global]
index-url=http://pypi.douban.com/simple
```
## 一些国内的pip源
```shell
http://mirrors.aliyun.com/pypi/simple/ # 阿里云
http://pypi.douban.com/simple  #豆瓣
http://pypi.hustunique.com/simple  #华中理工大学
http://pypi.sdutlinux.org/simple  #山东理工大学
http://pypi.mirrors.ustc.edu.cn/simple  #中国科学技术大学
```

# 打包部署问题
[python打包部署历史](http://zengrong.net/post/2169.htm)
distutils>setuptools/easyinstall(*.egg)>pip/wheel(*.whl)
## pip
导出dependency:`pip freeze > requirements.txt`
安装dependency:`pip install -r requirements.txt`
## whl
二进制文件whl
## 如何cmd中运行开发的*.py程序模块
新增workspace.path文件到virtualenv目录（如`E:\PythonWorkspace\ugc\ugc_venv\Lib\site-packages`）
```
E:\PythonWorkspace\ugc\ugc.aggregator
E:\PythonWorkspace\ugc\ugc.aggregator\src\main\python
```
注意path文件中的模块目录必须有__init__.py文件

# virtualenv
习惯了J2EE下的maven开发，对于python默认的module都安装到site-packages下的混乱不能理解，好在原来有virtualenv，它比maven本地repositoy库更具有独立性，当然冗余module是代价,好在python intepreter足够小巧。
virtualenv可以用来创建隔离的python环境 ，但新建出来的virtualenv都依赖本机安装的python底层dll等库。
* 安装：`pip install virtualenv`
* 新建virtualEnv：`virtualenv --no-site-packages venv`
* 进入venvShel：`E:\PythonWorkspace\ugc\ugc_venv\Scripts\activate`

## 问题记录
* 问题描述：执行`pip install MySQL-python`报错： `fatal error C1083: Cannot open include file: 'config-win.h': No such file or directory`或者报错`No module named MySQLdb`
解决方案：从`C:\Python27\Lib\site-packages`复制mysql相关的文件到虚拟环境的site-packages目录

# virtualenvwrapper
virtualenv创建的环境都是零散的，而且还要执行cd，执行source 来激活环境。 如此繁琐十分影响工作效率，于是有了virtualenvwrapper。vw可以进行环境的管理，把创建的环境记录下来，并进行管理。

## 安装
* linux：`pip install  virtualenvwrapper`  
* windows：`pip install virtualenvwrapper-win`  

## 配置
* 安装完毕过后在环境变量里面新建一个WORKON_HOME字段存储虚拟python环境,WORKON_HOME：`E:\PythonWorkspace\venv`
* 环境变量立即生效：cmd中运行`set WORKON_HOME=E:\PythonWorkspace\venv`

## 常用命令
virtualenvwrapper运行bat默认安装在`C:\Python27\Scripts\*.bat`
* 创建虚拟环境:`mkvirtualenv VirtualenvName`
* 列出所有虚拟环境:`Lsvirtualenv`
* 移除虚拟环境:`rmvirtualenv VirtualenvName`
* 切换到VirtualenvName环境:`workon VirtualenvName`
* 退出当前虚拟环境:`deactivate`

## 问题记录
* 问题描述：执行virtualenv报错：`SyntaxError: Non-ASCII character '\x90' in file C:\Python27\Scripts\virtualenv.exe on line 1, but no encoding declared;`
解决方案：卸载virtualenv`pip uninstall virtualenv`；卸载virtualenvwarpper`pip uninstall virtualenvwarpper-win`；重新安装virtualenvwarpper`pip install virtualenvwarpper-win`,要是还不行那就重装python！

* 问题描述：  File "E:\PythonWorkspace\venv\ugc.venv\Scripts\pip.exe", line 1 SyntaxError: Non-ASCII character '\x90' in file E:\PythonWorkspace\venv\ugc.venv\Scripts\pip.exe on line 1, but no encoding declared;  
解决方案：原因是pip安装python包会加载我的用户目录，我的用户目录恰好是中文的，ascii不能编码。解决办法是：
python目录 Python27\Lib\site-packages 建一个文件sitecustomize.py,python会自动运行这个文件。
```python
import sys
sys.setdefaultencoding('gb2312')
```

# pybuilder
[pybuilder官网](http://pybuilder.github.io/)
经常在java/c#/javascript之间切着敲代码，今年又多了python这个数据分析神器，习惯了Maven约定俗成的构建环境，为了实现单元测试打包一体化的高效，于是决定采用pybuidler进行工程构建

## 安装
在venv环境安装：`pip install pybuilder`

## pybuilder项目目录结构
`src/main/python`：源码
`src/main/scripts`：可执行脚本
`src/main/unittest`：单元测试

## 常用命令
* 进入venvShell：`workon ugc.venv`
* 执行默认build文件：`pyb_.exe` (参考官方文档执行pyb报错，暂未找到办法)
* 执行默认build文件，并打印unittest错误详情：`pyb_.exe -v`
* 新增测试项目：`pyb_.exe  --start-project`
* 发布：`pyb_.exe install_dependencies publish`

## 问题记录
* 单元测试执行错误：`BUILD FAILED - 'module' object has no attribute 'FileUtil_test`
