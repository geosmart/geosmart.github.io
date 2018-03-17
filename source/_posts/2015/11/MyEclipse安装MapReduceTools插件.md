title: MyEclipse安装MapReduceTools插件
date: 2015-11-20 21:03:50
tags: [分布式,Hadoop,MapReduce]
categories: [大数据]
---

Windwos10开发环境测试MapReduce程序，需自行编译hadoop2x-eclipse-plugin，生成MyEclipse2014的MapReduceTolls插件，可结合MRUnit进行单元测试。

- - -
<!-- more -->
[参考中文教程](http://my.oschina.net/muou/blog/408543)
具体配置步骤如下：

## 安装MyEclipse2014
Myeclipse安装位置：C:\Dev\myeclipse（路径无中文字段/空格）

## 下载Hadoop lib
下载hadoop-2.6.0.tar.gz并解压到目录（路径无中文字段/空格）
[hadoop-2.6.0.tar.gz下载地址](http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz)  
解压后置于F:\Dev\hadoop\hadoop-2.6.0

## 配置Ant
[ant-1.9.0下载地址](http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.0-bin.zip)  
配置环境变量

``` yaml
ANT_HOME=F:\Dev\apache-ant-1.9.0
PATH 后追加 ;%ANT_HOME%\bin
```
检验Ant配置：`ant -version`

## 编译hadoop-eclipse-plugin插件
[hadoop-eclipse-plugin下载地址](https://github.com/winghc/hadoop2x-eclipse-plugin)  
解压后置于F:\Dev\hadoop\hadoop2x-eclipse-plugin-master
打开cmd执行以下脚本编译hadoop-eclipse-plugin插件

```yaml
cd F:\Dev\hadoop\hadoop2x-eclipse-plugin-master\src\contrib\eclipse-plugin
ant jar -Dversion=2.6.0 -Declipse.home=C:\Dev\myeclipse -Dhadoop.home=F:\Dev\hadoop\hadoop-2.6.0
```
执行成功后生成的jar位置：
`F:\Dev\hadoop\hadoop2x-eclipse-plugin-master\build\contrib\eclipse-plugin\hadoop-eclipse-plugin-2.6.0.jar`

## 配置hadoop-eclipse-plugin-2.6.0.jar
1. 将`hadoop-eclipse-plugin-2.6.0.jar`剪切到`C:\Dev\myeclipse\dropins`目录；
2. 重启Myeclipse即完成MyEclipse2014的MapReduceTolls插件；
3. 可在Window>Show View>MapReduce Tools打开插件视图。

## 配置hadoop location
Location name ：随便取个名字 比如 hadoop2.6.0
Map/Reduce（V2） Master ：根据hdfs-site.xml中配置dfs.datanode.ipc.address的值填写，50020
DFS Master： Name Node的IP和端口，根据core-site.xml中配置fs.defaultFS的值填写，8020

CDH配置文件位置：/etc/hadoop/conf.cloudera.yarn
