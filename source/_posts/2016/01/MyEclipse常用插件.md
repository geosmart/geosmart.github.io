title: MyEclipse常用插件
date: 2016-01-27 20:19:06
tags: [J2EE,Eclipse]
categories: [IDE]
---
记录以J2EE开发采用MyEclipse IDE的常用插件
- - -
<!-- more -->
![Eclipse内核版本](Eclipse版本.png)

# SVN
[svn update site URL](http://subclipse.tigris.org/update_1.12.x/)  
[svn offline package](http://subclipse.tigris.org/servlets/ProjectDocumentList?folderID=2240)

# FatJar
[FatJar update site URL](http://kurucz-grafika.de/fatjar)

# Freemarker Editor
[Freemarker Editor update site URL](http://download.jboss.org/jbosstools/updates/development/kepler/)
安装时选择Jboss IDE即可

# Drools插件
[drools 5.5.0 update site URL](http://download.jboss.org/drools/release/5.5.0.Final/org.drools.updatesite/)

# OneJar
[OneJar官网](http://one-jar.sourceforge.net/)
## maven配置onejar打包
```xml
<!-- Make this jar executable -->
  <plugin >
    <groupId >org.apache.maven.plugins </groupId >
    <artifactId >maven-jar-plugin </artifactId >
    <configuration >
    <archive >
      <manifest >
        <mainClass >gto.amo.mapper.app.form.Main </mainClass >
      </manifest >
    </archive >
    </configuration >
  </plugin >
  <!-- Includes the runtime dependencies -->
  <plugin >
  <groupId >com.jolira </groupId >
  <artifactId >onejar-maven-plugin </artifactId >
  <version >1.4.4 </version >
  <executions >
    <execution >
    <configuration >
      <attachToBuild >true </attachToBuild >
      <classifier >onejar </classifier >
    </configuration >
    <goals >
      <goal >one-jar </goal >
    </goals >
    </execution >
  </executions >
  </plugin >
```
