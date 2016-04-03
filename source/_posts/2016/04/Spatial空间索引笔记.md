layout: neo4j
title: Spatial空间索引笔记
date: 2016-04-03 11:18:18
tags: [Neo4j]
categories: [数据库]
---
Neo4j采用Neo4j Spatial插件实现空间索引，Neo4j Spatial可使用API或Cypher执行空间查询操作，另作为插件可部署于GeoServer与uDig；这种结合关系与空间的分析值得尝试！
- - -
<!-- more -->
# 相关资料
[neo4j spatial github官网](http://neo4j-contrib.github.io/spatial/)
[lyonwj博客](http://www.lyonwj.com/)

## Neo4j Spatial简介
Neo4j Spatial is a library of utilities for Neo4j that faciliates the enabling of spatial operations on data.
- Utilities for importing from ESRI Shapefile as well as Open Street Map files
- Support for all the common geometry types
- An RTree index for fast searches on geometries
- Support for topology operations during the search (contains, within, intersects, covers, disjoint, etc.)
- The possibility to enable spatial operations on any graph of data, regardless of the way the spatial data is stored, as long as an adapter is provided to map from the graph to the geometries.
- Ability to split a single layer or dataset into multiple sub-layers or views with pre-configured filters

## Java构建Neo4j 空间索引
[参考distance-queries-with-neo4j-spatial](https://structr.org/blog/distance-queries-with-neo4j-spatial)
[gist代码示例：Neo4j Emberded 嵌入式SpringBean配置](https://gist.github.com/geosmart/0559745a69875e9f8876aeecda10f86b)
[gist代码示例：Java实现Neo4j Spatial新建索引和空间查询测试用例](https://gist.github.com/geosmart/19e6e4cb0c953e1b63e9afe48425de8f)

# neo4j spatial 安装
1. 在[neo4j spatial github maven库](https://github.com/neo4j-contrib/m2/tree/master/releases/org/neo4j/neo4j-spatial)下载最新服务端Neo4j Spatial Server插件，下载后解压到neo4j plugin目录；
2. 验证安装状态：以http://localhost:7474/db/data/ext/SpatialPlugin验证是否成功安装，将返回以下几类graphdb的操作
  - addSimplePointLayer,addEditableLayer,addCQLDynamicLayer,addGeometryWKTToLayer
  - addNodeToLayer,addNodesToLayer,updateGeometryFromWKT
  - getLayer,findClosestGeometries, findGeometriesWithinDistance,findGeometriesInBBox
3. 索引新建
  - Create a Spatial index
  - Create nodes with lat/lon data as properties
  - Add these nodes to the Spatial index
4. RTree关系可视化
![RTree索引](RTreeRelationship.png)
Neo4j Spatial REST服务可参考[Neo4j Spatial v0.12-neo4j-2.0.0-SNAPSHOT文档](http://neo4j-contrib.github.io/spatial/)

# neo4j spatial应用
The technology industry and open source groups are building Spatial tools (“where” analysis) and Graph tools (relationship analysis)
so that businesses can improve their insight on patterns, trends, and (perhaps most importantly) outliers in the networks.

*  [neo4j-spatial-part1-finding-things-close-to-other-thing](http://neo4j.com/blog/neo4j-spatial-part1-finding-things-close-to-other-things/)
* [Mapping the World's Airports With Neo4j Spatial and Openflights](http://www.lyonwj.com/mapping-the-worlds-airports-with-neo4j-spatial-and-openflights-part-1)
* [Geospatial Indexing US Congressional Districts with Neo4j-spatial](http://neo4j.com/blog/geospatial-indexing-us-congress-neo4j/)
* [Webinar: Recommend Restaurants Near Me: Introduction to Neo4j Spatial](http://neo4j.com/news/webinar-recommend-restaurants-intro-neo4j-spatial/)
* [Finding Valuable Outliers and Opportunities Using Graph and Spatial](http://neo4j.com/blog/outliers-opportunities-graph-spatial/)
* [legis-graph-spatial](http://legis-graph.github.io/legis-graph-spatial/)


# neo4j spatial query 示例
[start-node-by-index-query](http://neo4j.com/docs/stable/query-start.html#start-node-by-index-query)
## withinDistance缓存区查询
查询点120.678966,31.300864周边0.1km范围内的Node  
```sql
start n = node:geom('withinDistance:[31.331937,120.638154,0.1]') return n limit 100
```
## bbox矩形查询
查询由点1(120.678966,31.300864)与点2(120.978966,31.330864)构成的矩形范围内的Node  
```sql
start n = node:geom('bbox:[31.300864,120.678966,31.330864,120.978966]') return n limit 100
```
## 空间索引和关系遍历联合查询
联合geom索引图层和match进行查询  
```sql
start n = node:geom('withinDistance:[31.331937,120.638154,0.1]')
match r=(:DIS{text:'工业园区'})-[:BELONGTO ]-(:POI{text:'拙政别墅'})  
return n,r
```
查询结果可视化效果图
![空间索引和关系遍历联合查询](spatialQuery.png)
