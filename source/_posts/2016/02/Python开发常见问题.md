title: Python开发常见问题
date: 2016-02-24 15:30:20
tags: [Python]
categories: [脚本工具]
---

记录Python开发过程中的遇到的问题
- - -
<!-- more -->

# ImportError: No module named MySQLdb
You can find binary installers here (Python 2.6-3.2), here (2.7) or here (2.6). Note that you don't have to use 64bit Python on Windows x64. You can just as well use a 32bit build of Python, for which there are more pre-built 3rd party packages around.

# TypeError: '_Callable' object is not callable
That error occurs when you try to call, with (), an object that is not callable.
A callable object can be a function or a class (that implements __call__ method). According toPython Docs:
解决：在init构造函数删除初始化对象的代码

# TypeError: getPointByBounds() takes exactly 4 arguments (5 given)
`def getPointByBounds(lng0, lat0, lng1, lat1, step=0.001) :`应该为
`def getPointByBounds(self,lng0, lat0, lng1, lat1, step=0.001) :`第一个参数为self

## apply_async最后一个process调用的函数被中止
暂未发现原因

##  hangs on 'scanning files to index' background task
go to the "File" on the left top, then select "invalidate caches/restart...", and press "invalidate and restart".

## pycharm添加已有virtualEnv
如通过virtualEnvWarpper创建的env，默认在pycharm中无法选择已有virtualEnv，只能新建，可通过add local手动完成虚拟环境导入
`File>setting>Project Interpreter>add local>选择virtualEnv\Scripts\python.exe`

## pycharm5源代码管理之svn配置
[svn1.8下载地址](http://netcologne.dl.sourceforge.net/project/win32svn/1.8.14/Setup-Subversion-1.8.14.msi)
* svn安装：注意安装路径不能带空格：
* pycharm配置svn：在version contro>svn>command line client设置为C:\Dev\SVN\bin\svn.exe
