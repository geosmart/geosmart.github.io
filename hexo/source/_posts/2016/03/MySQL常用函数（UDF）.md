title: MySQL常用函数（UDF）
date: 2016-03-18 21:28:19
tags: [MySQL]
categories: [数据库]
---
数据分析/特定业务逻辑MySQL内置的Function无法满足需求，只能祭出UDF。
- - -
<!-- more -->

# 字符串分割(split_string)

- 函数定义
- CREATE DEFINER = 'ugcdb'@'%'
FUNCTION ugcdb.split_string(
x VARCHAR(255),
delim VARCHAR(12),
pos INT
)
RETURNS varchar(255) CHARSET utf8
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
     LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
     delim, '')
- 函数调用
- `update tableName set 门牌号= SPLIT_STR(门牌号,'号',1) ;`

# 获取行号(get_rownum)

[参考create-a-view-with-column-num-rows-mysql](http://stackoverflow.com/questions/15891993/create-a-view-with-column-num-rows-mysql)

- 函数定义
- CREATE DEFINER=`geocodingdb`@`%` FUNCTION `geocodingdb`.`get_rownum`() RETURNS int(11)
BEGIN
    SET @temp_rowNumber := IFNULL(@temp_rowNumber,0)+1;
    return @temp_rowNumber;
END
- 函数调用
- SET @temp_rowNumber=0;
select fieldA , get_rownum() AS rownum from tableName;
