title: Tomcat服务器运维
date: 2015-10-03 17:44:53
tags: [Tomcat]
categories: [OPS]
---

记录Tomcat服务器的配置安装脚本

- - -
<!-- more -->

#	Tomcat安装
##	配置系统环境变量
*	JAVA_HOME=D:\java\JDK1.6
*	PATH环境变量加入：%JAVA_HOME%\bin

##	安装Tomcat
*	开始-运行-cmd
*	输入：cd D:\tomcat\bin进入tomcat安装目录
*	输入：service install tomcat7进行安装（xx为tomcat服务名称，可随意给，也可不设置）

##	设置为开机启动
开始-运行-services.msc进入服务管理器，将刚才安装的tomcat服务设置为自动，并启动，此时tomcat已成功安装并成功注册为自动启动的系统服务。

## 卸载Tomcat
*	输入：cd D:\tomcat\bin进入tomcat安装目录
*	输入：service remove tomcat7进行卸载（xx为已安装tomcat服务的名称，以前没设置就不用写）


#	tomcat内存配置
##	windows服务内存配置
编辑tomcat\bin\service.bat
找到`"%EXECUTABLE%" //US//%SERVICE_NAME% --JvmOptions`
新增`-Xms1024M;-Xmx2048M;-XX:PermSize=512M;-XX:MaxPermSize=1024M`;
然后卸载掉服务-->安装服务-->启动服务，生效。
在localhost:8080/manager/status 查看修改后的可用内存大小
##	console控制台内存配置
编辑catalina.bat，找到下面行修改

```yaml
rem ----- Execute The Requested Command ---------------------------------------
set JAVA_OPTS=%JAVA_OPTS% -server  -Xms6400m -Xmx6400m  -XX:MaxNewSize=2048m -XX:PermSize=512M -XX:MaxPermSize=1024m
```

##	Tomcat与Jetty
*	单纯比较 Tomcat与Jetty的性能意义不是很大，只能说在某种使用场景下，它表现的各有差异。因为它们面向的使用场景不尽相同。
*	从架构上来看 Tomcat 在处理少数非常繁忙的连接上更有优势，也就是说连接的生命周期如果短的话，Tomcat 的总体性能更高。而 Jetty 刚好相反，Jetty可以同时处理大量连接而且可以长时间保持这些连接。例如像一些 web 聊天应用非常适合用 Jetty 做服务器，像淘宝的 web 旺旺就是用 Jetty 作为 Servlet 引擎。由于 Jetty 的架构非常简单，作为服务器它可以按需加载组件，这样不需要的组件可以去掉，这样无形可以减少服务器本身的内存开销，处理一次请求也是可以减少产生的临时对象，这样性能也会提高。另外 Jetty 默认使用的是 NIO 技术在处理 I/O 请求上更占优势，Tomcat 默认使用的是 BIO，在处理静态资源时，Tomcat 的性能不如 Jetty。
