title: MongoDB空间分析
date: 2015-12-28 21:02:12
tags: [MongoDB]
categories: [存储层]
---

用MongoDB与其他NoSQL数据库之间一个大的差别就是她的空间数据存储，2dsphere空间索引（WGS84），用于通用的空间分析（如缓冲区）会很方便。
- - -
<!-- more -->  

# 新建空间索引
连接到数据库：`/mnt/data/mongodb/bin/mongo uadb`
新建空间索引：`db.AddressNode.ensureIndex( { 空间位置 : "2dsphere" });`
新建空间联合索引：`db.AddressNode.ensureIndex( { 空间位置 : "2dsphere", 规范地址节简称: 1  });`

# 几何查询
MongoDB查询关键词：http://docs.mongodb.org/manual/reference/operator/query-geospatial/
## geoWithin多边形范围查询

```js
{
空间位置: {
        $geoWithin: {
            $geometry: {
                 "type":"Polygon",
                 "coordinates":[[
                    [110,30],
                    [110, 60],
                    [120, 60],
                    [120, 30],
                    [110,30]
                    ]]
            }
        }
    }
}

{
空间位置:{
  $geoWithin:{
  $geometry: {type:'Polygon',coordinates:[[[110,30],[110, 60],[120, 60],[120, 30],[110,30]]]}}},
  规范地址节简称:{$in:["DIS","POI"]
  }
}
```

## geoWithin圆范围查询（距离单位：弧度）
```js
{
空间位置:{
        $geoWithin: {
            $centerSphere: [[119.22426261, 31.61467114],0.0025]
        }
    }
}
联合索引查询
{
空间位置:{
        $geoWithin: {
            $centerSphere: [[119.22426261, 31.61467114],0.0025]
        }
    },
     "规范地址节简称":"POI"
}
```

## 矩形范围查询
$box，针对2d索引，不能针对GeoJson数据进行查询

## nearSphere缓冲区范围查询（距离单位：米）
```js
{
空间位置: {
        $nearSphere: {
            $geometry: {
                 "type":"Point",
                 "coordinates":[119.22426261, 31.61467114]
            },
          $maxDistance : 5000
        }
    }
}
```

## intersect相交查询
```js
{
空间位置: {
        $geoIntersects: {
            $geometry: {
                 "type":"Polygon",
                 "coordinates":[[
                    [110,30],
                    [110, 60],
                    [120, 60],
                    [120, 30],
                    [110,30]
                    ]]
            }
        }
    }
}
```

图解 MongoDB 地理位置索引的实现原理： http://blog.nosqlfan.com/html/1811.html
结合MongoDB开发LBS应用：http://www.infoq.com/cn/articles/depth-study-of-Symfony2
http://docs.mongodb.org/manual/applications/geospatial-indexes/

## MongoDB地理位置索引
MongoDB地理位置索引常用的有两种
	* 2d 平面坐标索引，适用于基于平面的坐标计算。也支持球面距离计算，不过官方推荐使用2dsphere索引。
	* 2dsphere 几何球体索引，适用于球面几何运算
	* 2d空间索引也支持Polygon+属性查询，但在组合索引/查询中为串行过程（低效），而2dsphere空间索引支持高效的组合索引/查询（即真正的GIS查询）

查询方式分三种情况：

	1. Inclusion。范围查询，如百度地图“视野内搜索”。
	2. Inetersection。交集查询。不常用。
	3. Proximity。周边查询，如“附近500内的餐厅”。

MongoDB查询地理位置默认有3种距离单位：

	* 米(meters)
	* 平面单位(flat units，可以理解为经纬度的“一度”)
	* 弧度(radians)。

通过GeoJSON格式查询，单位默认是米，通过其它方式则比较混乱
geoWithin的查询范围：经/纬度范围之和不能大于180
```js
 double[][] geometry = GeoUtil. createRectangle(-20, 90, 160, -90);
{空间位置: {$geoWithin: {$geometry: {type:'Polygon',coordinates:[[[-20.0,90.0],[-20.0,-90.0],[160.0,-90.0],[160.0,90.0],[-20.0,90.0]]]}}},规范地址节简称:'POI',空间优先级:1}
```
