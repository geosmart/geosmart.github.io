title: Maven使用笔记
date: 2015-09-15 15:52:57
tags: [J2EE,Maven]
categories: [后端技术]
---

# 关于Maven
Maven是基于项目对象模型(POM)，可以通过一小段描述信息来管理项目的构建，报告和文档的软件项目管理工具。  

本文记录Maven开发过程中常用的脚本和遇到的问题。

- - -
<!-- more -->

# Maven Dependency
在POM 4中，<dependency>中还引入了<scope>，它主要管理依赖的部署。目前<scope>可以使用5个值：

    * compile，缺省值，适用于所有阶段，会随着项目一起发布。
    * provided，类似compile，期望JDK、容器或使用者会提供这个依赖。如servlet.jar。
    * runtime，只在运行时使用，如JDBC驱动，适用运行和测试阶段。
    * test，只在测试时使用，用于编译和运行测试代码。不会随项目发布。
    * system，类似provided，需要显式提供包含依赖的jar，Maven不会在Repository中查找它。

# Maven常用指令
`package`：打包  
`war:exploded`：编译不生成war包  
`install`：安装到本地资源库  
     eg：`mvn install:install-file -Dfile=lt.util-1.0.jar -DgroupId=com.lt -DartifactId=util -Dversion=1.0 -Dpackaging=jar  `
`process-resources`：编译并打包资源  
新建项目：`mvn archetype:generate -DgroupId=com.lt -DartifactId=uadb.etl -DarchetypeArtifactIdmaven-archetype-webapp -DinteractiveMode=false  `

# maven dependency exclusion


# maven远程库
* https://search.maven.org/#search

* http://maven-repository.com/

* http://mvnrepository.com/

* http://repository.apache.org/snapshots/

* http://maven.outofmemory.cn/

# 上传项目到Maven Central Repository

## Maven本地开发
*	下载apache-maven
*	设置本地库路径  
在maven\config\settings.xml中设置本地库路径：`<localRepository>D:\Dev\Maven-Respository</localRepository>`
*	在Myeclipse中设置安装路径   
在`Window>Preferences>Myeclipse>Maven4Myeclipse>Installations`中执行Add加入本地maven路径
在`Window>Preferences>Myeclipse>Maven4Myeclipse>User Settings`中Browser选择maven\config\settings.xml，执行Update Settings，Reindex

## Maven项目聚合
为解决多个依赖项目自动打包，可通过聚合maven项目解决
pom示例
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<groupId>com.lt.util</groupId>
	<artifactId>util.aggregation</artifactId>
	<version>0.0.1</version>
	<packaging>pom</packaging>

	<name>util.aggregation</name>

	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	</properties>
	<modules>
		<module>../util.common</module>
		<module>../util.jdbc</module>
		<module>../util.web</module>
		<module>../util.geo</module>
		<module>../util.hibernate</module>
	</modules>
</project>
```
通过`mvn clean install`进行打包

## Maven项目依赖继承
`uadb.parent`项目
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<groupId>com.lt.uadb</groupId>
	<artifactId>uadb.parent</artifactId>
	<version>0.0.1</version>
	<packaging>pom</packaging>

	<name>uadb.parent</name>
	<!-- 项目属性 -->
	<properties>
		<!-- framework -->
		<jdk.version>1.7</jdk.version>
		<!-- test -->
		<junit.version>4.8.2</junit.version>
		<!-- encode -->
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	</properties>
	<dependencyManagement>

		<dependencies>
			<!--test -->
			<dependency>
				<groupId>junit</groupId>
				<artifactId>junit</artifactId>
				<version>${junit.version}</version>
				<scope>test</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>
</project>
```
child项目引用parent项目
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<artifactId>uadb.etl.pre</artifactId>
	<version>1.0</version>
	<name>uadb.etl.pre</name>
	<packaging>jar</packaging>

	<parent>
		<groupId>com.lt.uadb</groupId>
		<artifactId>uadb.parent</artifactId>
		<version>0.0.1</version>
	</parent>
	<!-- 项目属性 -->
	<properties>
		<!-- framework -->
		<jdk.version>1.7</jdk.version>
		<!-- test -->
		<junit.version>4.8.2</junit.version>
		<!-- encode -->
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	</properties>

	<dependencies>
			<!--test -->
  		<dependency>
  			<groupId>junit</groupId>
  			<artifactId>junit</artifactId>
  		</dependency>
	</dependencies>
</project>
```

# Maven问题记录
*	本地库有改jar包但是依旧无法编译
本地下载的Zip已损坏，删除本地库中的jar文件和目录，重新从远处库下载


*	远程库只能下载索引，不能下载jar！
日志：The container 'Maven Dependencies' references non existing library 'D:\soft\Maven\Maven-Respository\org\apache\ant\ant\1.9.3\ant-1.9.3.jar'
解决：
So I get you are using Eclipse with the M2E plugin. Try to update your Maven configuration : In the Project Explorer, right-click on the project, Maven -> Update project.
If the problem still remains, try to clean your project: right-click on your pom.xml, Run as -> Maven build (the second one). Enter "clean package" in the Goals fields. Check the Skip Tests box. Click on the Run button.
