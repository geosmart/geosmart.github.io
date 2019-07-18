title: SQLite数据库使用笔记
date: 2015-09-15 10:24:33
tags: [J2EE,SQLite] 
categories: [数据库] 
---

# SQLite特点

SQLite只支持库级锁，同时只能允许一个写操作。但SQLite尽量延迟申请X锁，直到数据块真正写盘时才申请X锁，非常巧妙而有效。
1. SQLite支持3种线程模式:单线程,多线程,串行
2. 可使用WAL（Write-Ahead Logging）模式时，写操作是append到WAL文件，而不直接改动数据库文件，因此数据库文件可以被同时读取。当执行checkpoint操作时，WAL文件的内容会被写回数据库文件。当WAL文件达到SQLITE_DEFAULT_WAL_AUTOCHECKPOINT（默认值是1000）页（默认大小是1KB）时，会自动使用当前COMMIT的线程来执行checkpoint操作。也可以关闭自动checkpoint，改为手动定期
checkpoint。jdbc可通过setJournalMode(JournalMode.WAL)/setJounalSizeLimit实现
3. 事务是和数据库连接相关的，每个数据库连接（使用pager来）维护自己的事务，且同时只能有一个事务（但是可以用SAVEPOINT来实现内嵌事务）。

- - -
<!-- more -->

[官方文档](http://www.sqlite.org/wal.html )  
[sqlite在多线程下的应用](http://www.cnblogs.com/wuhenke/archive/2011/11/20/2256618.html)

## WAL模式
* -shm文件包含-wal文件的数据索引，-shm文件提升-wal文件的读性能
* 如果-shm文件被删除，下次数据库连接时会自动新建一个-shm文件 
* 如果执行了checkpoint命令，-war文件可以删除

## VACUUM命令  
VACUUM命令用于重建数据库文件， 执行VACUUM 时，会拷贝整个数据库到Transient databases临时文件中，然后覆盖写回到原来的数据库文件中。   
写回过程中会创建rollback journal or write-ahead log WAL file以保证transaction atomic。当vacuum执行完毕，临时文件被删除。   

重建数据库文件的原因有以下几点
 
1. 当大量数据被删除后，数据库文件中会有很多空块,空页和碎片，VACUUM rebuild数据库文件，移除这些空块，减少所占的磁盘空间
2. 频繁的inserts, updates, and deletes 导致数据库文件中很多碎片，VACUUM 重建数据库文件使得表，索引连续的存储, 减少空闲页， 减少所占的磁盘空间
3. 当page_size 或用pragma auto_vacuum 命令修改这两个值时， SQLite会自动执行VACUMM
4. VACUUM只对main数据库有效，对ATTACHED数据库无效
5. 如果数据库中还有其他transaction， VACUUM将执行失败
6. 除了使用VACUUM外，还可以使用PRAGMA auto_vacuum控制vacuum的执行
```
PRAGMA auto_vacuum;
PRAGMA auto_vacuum = 0 | NONE | 1 | FULL | 2 | INCREMENTAL;
```

# synchronous参数
```
PRAGMA synchronous = FULL; (2)
PRAGMA synchronous = NORMAL; (1)
PRAGMA synchronous = OFF; (0)
```
##  FULL
当synchronous设置为FULL (2), SQLite数据库引擎在紧急时刻会暂停以确定数据已经写入磁盘。这使系统崩溃或电源出问题时能确保数据库在重起后不会损坏。FULL synchronous很安全但很慢。
##  NORMAL
当synchronous设置为NORMAL, SQLite数据库引擎在大部分紧急时刻会暂停，但不像FULL模式下那么频繁。 NORMAL模式下有很小的几率(但不是不存在)发生电源故障导致数据库损坏的情况。但实际上，在这种情况 下很可能你的硬盘已经不能使用，或者发生了其他的不可恢复的硬件错误。
##  OFF
设置为synchronous OFF (0)时，SQLite在传递数据给系统以后直接继续而不暂停。若运行SQLite的应用程序崩溃， 数据不会损伤，但在系统崩溃或写入数据时意外断电的情况下数据库可能会损坏。另一方面，在synchronous OFF时 一些操作可能会快50倍甚至更多。在SQLite 2中，缺省值为NORMAL.而在3中修改为FULL。  www.2cto.com

建议：
如果有定期备份的机制，而且少量数据丢失可接受，用OFF。


# 问题记录

## 提交-wal修改到数据库main文件
执行`VACUUM`命令即可生成最新的数据库-db文件


## 如何删除使用中的SQLite数据库

[参考](http://stackoverflow.com/questions/991489/i-cant-delete-a-file-in-java)

``` java
// 添加System.gc()和Thread.sleep进行强制删除 
System.gc();
Thread.sleep(1000);
FileDeleteStrategy.FORCE.delete(workFile);
```

## SQLite开启WAL读写模式
``` java
SQLiteConfig config = new SQLiteConfig();
config.setOpenMode(SQLiteOpenMode.READWRITE);
config.setJournalMode(JournalMode.WAL); 
dataSource.setConfig(config);
```


## SQLite批量更新

``` java
  /**
   * 批量更新
   * 
   * @param updateSqlList
   */
  public void batchUpdate(List<String> updateSqlList) {
	if (updateSqlList.size() > 0) {
	  try { 
		Connection conn = dataSource.getConnection();
		Statement statement = conn.createStatement();
		for (String sql : updateSqlList) {
		  statement.addBatch(sql);
		}
		int[] count = statement.executeBatch();
 
		log.info("SQLite-JDBC批量更新{}条", count.length);
	  } catch (SQLException e) {
		e.printStackTrace();
	  }
	}
  }
```


##  sqlite除法运算保留小数问题
```sql
select  distinct 1/100 from 兴趣点
# 结果：0

select  distinct cast(1 as real)/100  from 兴趣点
# 结果：0.01
```

## sqlite存储number型时小于0的值会以0存储

## sqlite3.8-shell连接数据库
`cd /usr/local/sqlite &&  sqlite3 /uadb/data/geocodingdb.db`

## Cannot change read-only flag after establishing a connection
日志：`[org.hibernate.engine.jdbc.spi.SqlExceptionHelper] [ERROR] - Cannot change read-only flag after establishing a connection. Use SQLiteConfig#setReadOnly and SQLiteConfig.createConnection().`
解决：

