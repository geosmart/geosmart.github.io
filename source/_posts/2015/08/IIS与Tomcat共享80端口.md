title: IIS与Tomcat共享80端口
date: 2015-08-03 16:27:21 
tags: [Web服务器,J2EE,IIS,Tomcat]
categories: [运维] 
---

微信公众号有80端口要求，但是80端口已运行了一个项目，如何将后端J2EE实现的服务集成到80端口，即Tomcat集成进IIS。
调研了三种方案，Apache Tomcat Connector（isapi_redirect实现）、ARR（IIS中的反向代理）和 IIS2Tomcat(BonCode AJP实现)，按照最轻量最简洁的部署要求，最终采用AJP实现。


- - -
<!-- more -->
# isapi_redirect
[官方参考](http://tomcat.apache.org/connectors-doc/webserver_howto/iis.html)  
实现思路： 
1. The IIS-Tomcat redirector is an IIS plugin (filter + extension), IIS load the redirector plugin and calls its filter function for each in-coming request.
2. The filter then tests the request URL against a list of URI-paths held inside uriworkermap.properties, If the current request matches one of the entries in the list of URI-paths, the filter transfers the request to the extension.
3. The extension collects the request parameters and forwards them to the appropriate worker using the defined protocol like ajp13.
4. The extension collects the response from the worker and returns it to the browser   
配置注册表，DLL等步骤繁琐，易出错，如官方所说你很难一次性配置成功-_-

# ARR
ARR：Application Request Routing，类似Nginx的反向代理  
[配置教程](http://www.iisadmin.co.uk/?p=326)  
ARR is a good starting point if you want to connect Apache Tomcat to IIS 7, however, there are some issues especially under load that make this less than ideal solution. 
1. There are still differences in the way headers are handled between ARR and Tomcat and not all are transferred.  
2. ARR will be heavier on the network as it requires that http data is transferred in full byte length without being able to take advantage of binary compression and byte encoding the AJP protocol offers.  
3. Under load ARR will not be aware of Tomcat thread handling resulting in unnecessarily dropped connections. 
4. Secure (https) connections cannot be easily handled if tomcat needs to be aware of certificates used. 

# AJP
AJP：Apache JServ Protocol version   
[项目地址](https://github.com/Bilal-S/iis2tomcat)   
[下载地址（需翻墙）](http://tomcatiis.riaforge.org)    
[参考博客](http://blog.csdn.net/zhang_hui_cs/article/details/9399373#reply)  
[详细配置视频教程](http://v.youku.com/v_show/id_XNTg1MTgyODgw.html)  

## 默认网站二级应用程序配置要点    
1. 在IIS下新增网站examples，或者在默认网站中新增应用程序examples,物理路径指向`｛catalina_home｝/webapps/examples`；
2. 执行Connector_Setup.exe安装，默认参数即可，选择指定的IIS网站，如examples；
3. 应用程序池的托管管道模式设置为集成；
4. 在examples根目录新增配置BIN目录（包含BonCodeAJP13.dll、BonCodeIIS.dll），并在根目录新增web.config，内容如下：

* 完整配置

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <validation validateIntegratedModeConfiguration="false"/>
        <handlers>
            <add name="BonCodeForAll" path="*" verb="*" type="BonCodeIIS.BonCodeCallHandler" resourceType="Unspecified" preCondition="integratedMode" />
            <add name="BonCode-Tomcat-JSP-Handler" path="*.jsp" verb="*" type="BonCodeIIS.BonCodeCallHandler" preCondition="integratedMode" />
            <add name="BonCode-Tomcat-CFC-Handler" path="*.cfc" verb="*" type="BonCodeIIS.BonCodeCallHandler" preCondition="integratedMode" />
            <add name="BonCode-Tomcat-CFM-Handler" path="*.cfm" verb="*" type="BonCodeIIS.BonCodeCallHandler" preCondition="integratedMode" />
        </handlers>
        <defaultDocument>
            <files>
                <add value="index.jsp" />
                <add value="index.cfm" />
            </files>
        </defaultDocument>
    </system.webServer>
</configuration>
```

* 精简配置

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <validation validateIntegratedModeConfiguration="false"/>  
    </system.webServer>
</configuration>
```

若完整配置报错，采用精简配置即可。

### 问题记录
1. 在唯一密钥属性“name”设置为“BonCode-Tomcat-JSP-Handler”时，无法添加类型为“add”的重复集合项 
解决：改用精简配置

