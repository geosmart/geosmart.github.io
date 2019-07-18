title: jetty参数配置
date: 2015-07-06 16:49:20
tags:
---


jetty.xml

    <Get name="ThreadPool">
      <Set name="minThreads" type="int"><Property name="threads.min" default="500"/></Set>
      <Set name="maxThreads" type="int"><Property name="threads.max" default="900"/></Set>
      <Set name="idleTimeout" type="int"><Property name="threads.timeout" default="60000"/></Set>
      <Set name="detailedDump">false</Set>
    </Get>