---
title: 记一次MySQL死锁问题排查
date: 2019-12-12
tags: [MySQL]
categories: [存储层]
---

记录一次线上MySQL数据库的死锁问题和相关知识：
* MySQL数据库事务的4要素，
* 事务隔离的4种级别，
* 事务隔离导致的3类问题，
* 死锁的4个必要条件，
* 死锁的解决方案...

<!-- more -->
# 问题描述
```sql
-- 初始化
CREATE TABLE
    test_deadlock
    (
        id INT NOT NULL AUTO_INCREMENT,
        name VARCHAR(36),
        code VARCHAR(36),
        PRIMARY KEY (id)
    )
    ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into test_deadlock(name,code) values('device1','d1');
insert into test_deadlock(name,code) values('device2','d1');
select id,name,code from test_deadlock;


-- 测试不按顺序加锁不同记录导致的死锁
-- txA
-- 1
start transaction;
update test_deadlock set code='tx1' where id=1;
-- 3
update test_deadlock set code='tx1' where id=2;
commit ;

-- txB
--2 
start transaction;
update test_deadlock set code='tx2' where id=1;
update test_deadlock set code='tx2' where id=2;
-- block atfer 3
commit ;
```

# 事务的ACID4要素
## 原子性（atomicity）
一个事务必须被视为一个不可分割的最小工作单元，整个事务中的所有操作要么全部提交成功，要么全部失败回滚，对于一个事务来说，不可能只执行其中的一部分操作，这就是事务的原子性

## 一致性（consistency）
 数据库总是从一个一致性的状态转换到另一个一致性的状态。

## 隔离性（isolation）
通常来说，一个事务所做的修改在最终提交以前，对其他事务是不可见的。

## 持久性（durability）
一旦事务提交，则其所做的修改会永久保存到数据库。
>此时即使系统崩溃，修改的数据也不会丢失。持久性是个有占模糊的概念，因为实际上持久性也分很多不同的级别。有些持久性策略能够提供非常强的安全保障，而有些则未必，而且不可能有能做到100%的持久性保证的策略。

# 事务引发的3个问题
* 脏读：uncommit导致
* 不可重复读:update,delete导致
* 幻读:insert导致

# 事务的4个隔离级别
简写：`ru，rc，rr，se`

事务隔离级别 | 脏读 | 不可重复读 | 幻读
-- | -- | -- | --
读未提交（read-uncommitted） | 是 | 是 | 是
读已提交（read-committed） | 否 | 是 | 是
可重复读（repeatable-read） | 否 | 否 | 是
串行化（serializable） | 否 | 否 | 否

# 死锁的4个条件
1. 互斥条件：一个资源每次只能被一个进程使用。
2. 请求与保持条件：一个进程因请求资源而阻塞时，对已获得的资源保持不放。
3. 不剥夺条件：进程已获得的资源，在末使用完之前，不能强行剥夺。
4. 循环等待条件：若干进程之间形成一种头尾相接的循环等待资源关系。
这四个条件是死锁的`必要条件`，只要系统发生死锁，这些条件必然成立，
而只要上述条件之一不满足，就不会发生死锁。

# 死锁的解决方案
## 顺序加锁
对索引加锁顺序的不一致很可能会导致死锁，所以如果可以，尽量以相同的顺序来访问索引记录和表。
在程序以批量方式处理数据的时候，如果事先对数据排序，保证每个线程按固定的顺序来处理记录，也可以大大降低出现死锁的可能；
>串行执行，不会死锁，先执行txA再执行txB

## 事务拆分
避免大事务，尽量将大事务拆成多个小事务来处理；
因为大事务占用资源多，耗时长，与其他事务冲突的概率也会变高；

## 设置锁等待超时参数
设置锁等待超时参数：innodb_lock_wait_timeout，

这个参数并不是只用来解决死锁问题，在并发访问比较高的情况下，如果大量事务因无法立即获得所需的锁而挂起，会占用大量计算机资源，造成严重性能问题，甚至拖跨数据库。

我们通过设置合适的锁等待超时阈值，可以避免这种情况发生。

