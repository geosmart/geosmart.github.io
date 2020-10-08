---
title: 任务调度系统之Airflow
date: 2020-07-29
tags: [大数据]
---

airflow和传统的调度系统的最大区别是采用`workflow as code`思想，,dag是采用python代码定义，目标用户是熟悉python的工程师，普通用户使用成本较高。

<!-- more -->  

# airflow核心概念
* queue：任务执行环境依赖，按queue隔离执行机器
* pool：任务执行资源依赖，限制任务并发数
* dag：任务关系依赖
* cron：任务时间依赖
* hook：外部系统依赖

# airflow架构
中心化思想的实现，master(scheduler)分发任务，worker执行工作。

* airflow-scheduler：调度器，轮询元数据库（Metastore）已注册的DAG是否需要被执行，如果DAG需要被执行，scheduler守护进程就会先在元数据库创建一个DagRun实例，并触发DAG内部的task，即推送task消息到消息队列；
* airflow-webserver：dag管理；
* rabbitmq：celery broker，存储task消息，每一个task消息都包含此task的DAGID、taskID及具体需要被执行的函数；
* airflow-worker：任务执行，监听消息队列，如果有消息，就从消息队列中取出消息，当取出任务消息时，它会更新元数据中DagRun实例的状态为正在运行，并尝试执行DAG中的task。如果DAG执行成功，则更新DagRun实例的状态为成功，否则更新状态为失败。
* airflow-flower：worker监控
* airflow-metastore：调度数据存储

# airflow选型考虑
>**pros**
* `code as workflow`的最佳实践，配置即代码，且提供dag管道可视化；
* 架构偏数据科学风格，插件化设计，可扩展性强；
* 代码少，简洁，易维护，适合深度定制；
* 丰富的任务类型，自定义任务类型非常简单；
* 丰富的告警/通知机制，提供sentry/dingtalk/email等集成；
* 可基于queue和pool实现任务隔离和资源限制；
* 提供backfill机制补数据；
* 可采集数据血缘与元数据系统集成；
* slack和github社区活跃；

>**cons**
* 功能定制成本高：弱类型的python源码，理解维护成本较高；
* REST接口不成熟：目前处于experiment阶段，存在变动的；
* 流程定义方式工程化：dag文件定义需要依赖git或者分布式文件系统，没有使用数据库进行管理，不便于系统集成；
* 系统部署复杂：依赖组件多，与其他调度系统相比，需额外部署一个MQ集群；

# airflow调度规则
* cron：通过`croniter`实现
  * 每5分钟：*/5 * * * *
* 预定义presets调度周期：`@once,@hourly,@daily,@weekly,@monthly,@quarterly,@yearly`
  * 会转换为cron表达式执行（normalized_schedule_interval）
* timedelta:

# airflow的job状态
对应`dag_run`表的state字段
* 默认为running
* 执行成功：success
* 执行失败/超时：failed

# airflow的task状态
对应`task_instance`表的state字段
* no_status：scheduler调度ti，初始化状态：
* queued：scheduler将ti发送到队列后，等待pool的slot资源：
* running：worker任务执行开始：
* retry：worker任务执行失败后按配置的重试次数进行重试；
* success：worker任务执行成功；
* failed：worker任务执行失败/超时：
* skipped：一般分支节点下游的某个分支会存在跳过的情况；
* up_for_retry：task已failed但尚未进入retry状态；
* up_for_reschedule：主要针对sensor，等待被再次调度，避免直接执行占用worker的slot；
* upstream_failed：依赖的上游task执行失败后，下游task都标记为upstream_failed；

>调度器处理的状态：NONE, SCHEDULED, QUEUED, UP_FOR_RETRY  
>任务运行状态：RETRY，RUNNING  
>任务终止状态：SUCCESS，FAILED，SKIPPED，UPSTREAM_FAILED

# airflow任务触发规则
* all_success: 所有父节点都是success状态；
* all_failed: 所有父节点都是failed或upstream_failed状态；
* all_done: 所有父节点都是是终止状态状态；
* one_failed: 至少有1个父节点状态为failed，不需要等待所有父节点执行完成；
* one_failed: 至少有1个父节点状态为success，不需要等待所有父节点执行完成；
* one_failed: 所有父节点状态都不是failed或upstream_failed状态，即所有父节点执行完成（succeeded或skipped）；
* none_failed: 所有父节点状态都不是failed或upstream_failed状态，即所有父节点执行完成（succeeded或skipped）；
* none_failed_or_skipped: 所有父节点状态都不是failed或upstream_failed状态，至少1个父节点是success状态；
* none_skipped: 所有父节点都不是skipped状态；如所有父节点都是success, failed, 或 upstream_failed状态；
* dummy: 演示用的节点状态，可随意触发


# airflow核心参数
## dag调度参数
* start_date：task调度起始日期
* end_date：task调度截止日期
* execution_date：task逻辑时间执行
		* 逻辑执行时间：task理论上应该执行的时间
		* 物理执行时间：task执行时间可能由于服务阻塞而延迟
* schedule_interval：任务调度周期，timedelta或cron表达式
* execution_timeout: task执行超时时间
* retries：task失败后最大重试次数
* retry_delay: task失败后重试间隔

## dag执行参数
* parallelism：同时运行的最大task实例数，全局配置参数，默认32
* max_active_runs：单个dag同时运行最大dag实例数，可在dag定义时传入
* dag_concurrency：单个dag同时运行最大task数，可在dag定义时传入
* pool：通过pool的slo大小限制task的并行执行数，超过容量后任务将会按priority_weight排队，直到有任务完成空出solt

# airflow的数据结构


# 参考
* 