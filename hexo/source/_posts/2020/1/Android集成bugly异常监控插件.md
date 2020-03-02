---
title: Android集成bugly异常监控插件
date: 2020-01-01
tags: []
categories: 安卓开发
---

安卓开发中的异常监控方案-Bugly
<!-- more --> 

# bugly集成
主程序中集成bugly
```java
public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        initBugly();
    }
}
/**
* 初始化bugly
*/
private void initBugly() {
    CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
    strategy.setAppVersion(BuildConfig.APPLICATION_ID);
    strategy.setAppPackageName(BuildConfig.VERSION_NAME);
    strategy.setDeviceID(ZqznFaceSDK.getDeviceIdNotSafe());
    //Bugly会在启动20s后联网同步数据
    strategy.setAppReportDelay(20000);
    CrashReport.initCrashReport(getApplicationContext(), getString(R.string.bugly_app_id), true);
    CrashReport.setUserId(this, ZqznFaceSDK.getDeviceIdNotSafe());
}
```

# 符号表集成
## 什么是符号表？
>符号表是内存地址与函数名、文件名、行号的映射表。符号表元素如下所示：
><起始地址> <结束地址> <函数> [<文件名: 行号>]

## 为什么要配置符号表
>为了能快速并准确地定位用户APP发生Crash的代码位置，Bugly使用符号表对APP发生Crash的程序``堆栈进行解析和还原。

## 配置全局build.gradle
```gradle
buildscript {
    repositories {
        maven {
            url 'https://maven.aliyun.com/repository/google'
        }
        maven {
            url 'https://maven.aliyun.com/repository/jcenter'
        }
        maven {
            url 'http://172.26.12.78:8081/repository/zqzn-release/'
        }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.5.1'
        //bugly symbol uploader
        classpath 'com.tencent.bugly:symtabfileuploader:2.2.1'
    }
}
```

## 配置项目build.gradle
```gradle
apply plugin: 'bugly'
bugly {
    appId = 'xxx'
    appKey = 'xxx'
}
```
