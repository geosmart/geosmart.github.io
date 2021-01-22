---
title: FlinkOnYarn
date: 2021-01-22 18:47:50
tags: [大数据,flink]
---

dolphinscheduler这个dag的任务类型就差flink就都玩个遍了.
简单记录一下，flink word count入门小实验。

<!-- more -->
# Flink on Yarn执行流程
![flink on yarn](flink_on_yarn.jpg)

>yarn任务提交流程和`spark on yarn`类似
>不过ui端口，spark是启在driver，flink是启在jobManager

# Flink on Yarn 部署模式
![flink deploy mode](flink_deploy_mode.png)

* Application Mode：JobManager独立，flink main()在cluster中执行
* Per-Job Mode：JobManager独立，flink main()在client中执行
* Session Mode：JobManager共享，flink main()在client中执行

>数据加工时，由于采用flink定时跑批，租户隔离保证互不影响，所以采用第一种模式；

# flink版本
* flink 1.10.2

>1.11和1.12的spark on yarn的参数改动有点大，还是保守点用1.10了。
>其实是dolphinscheduler目前支持的是1.9...升级flink run的args拼起来太麻烦了-_-

# 环境变量
```bash 
export HADOOP_CLASSPATH=`hadoop classpath`
export FLINK_HOME=/opt/cloudera/parcels/CDH/lib/flink-1.10.2
export PATH=$PATH:$FLINK_HOME/bin
```

# kerberos初始化
kinit -kt /etc/krb5/$principle.keytab $principle

# Flink WordCount
## WordCount-batch

```bash
flink run -m yarn-cluster  \
-ys 4  \
-ynm myapp \
-yjm 1024  \
-ytm 10240 \
-d  \
-c org.apache.flink.streaming.examples.wordcount.WordCount  \
/opt/cloudera/parcels/CDH/lib/flink-1.10.2/examples/streaming/WordCount.jar
```

## WordCount-streaming
* 在某个服务器192.168.1.6开启socket端口监听：nc -l 9000
* 启动flink streaming任务计算wordcount

```bash 
flink run  \
-m yarn-cluster  \
-ys 1  \
-yjm 1G  \
-ytm 1G  \
-d  \
-c org.apache.flink.streaming.examples.socket.SocketWindowWordCount flink/WordCount-SocketWindow.jar  \
--hostname 192.168.1.6   \
--port 9000   \
--qu default
```

# flink jobmanager
```
Found Web Interface 192.168.1.7:40320 of application 'application_1611216022576_0309'.
Job has been submitted with JobID 42d4cc8ec8bdacc01e8678089152f414
```
![flink_streaming_wordcount](flink_streaming_wordcount.jpg)

>PS 不说流计算的时效性，flink的web ui比spark实在强太多了。

# 参考
* [flink on yarn模式](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/#deployment-modes)
* [flink config](https://ci.apache.org/projects/flink/flink-docs-release-1.10/ops/config.html)
