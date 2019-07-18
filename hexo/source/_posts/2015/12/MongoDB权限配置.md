title: MongoDB权限配置
date: 2015-12-28 21:03:12
tags: [MongoDB]
categories: [数据库]
---

- - -
<!-- more -->

# 在未开启auth模式下新建sa用户
//进入admin数据库
mongo admin
//新建sa超级用户
```js
db.createUser(
   {
     user: "sa",
     pwd: "1qaz2wsx",
     roles:
       [
         { db: "uadb", role: "readWrite" },
 { db: "uadb", role: "dbAdmin" },
 { db: "uadb", role: "userAdmin" },
 { db: "uadb", role: "dbOwner" },    
 { db: "uadb_attachment", role: "readWrite" },
 { db: "uadb_attachment", role: "dbAdmin" },
 { db: "uadb_attachment", role: "userAdmin" },
 { db: "uadb_attachment", role: "dbOwner" },     
 { db: "admin", role: "readWrite" },
 { db: "admin", role: "dbAdmin" },
 { db: "admin", role: "userAdmin" },
 { db: "admin", role: "dbOwner" },
 { db: "admin", role: "root" }
       ]
   }
)
```
//sa用户授权测试
db.auth("sa","1qaz2wsx")


# 启用MongoDB权限控制
Windows
卸载现有MongoDB服务   
C:\WINDOWS\system32>sc delete "MongoDB"

启动服务
按照MongoDB服务（设置权限控制）：E:\mongodb\bin\mongod --logpath "E:\mongodb\log\mongo.log" --logappend --dbpath "E:\mongodb\data" --directoryperdb   --auth  --serviceName "MongoDB" --serviceDisplayName "MongoDB" --install

Linux
启动服务
/mnt/data/mongodb/bin/mongod --dbpath /mnt/data/mongodb/data --logpath /mnt/data/mongodb/log/mongodb.log  --auth
# 开启auth后新建用户

```js
//以admin登陆获取权限
use admin
//sa用户授权
db.auth("sa","1qaz2wsx")
//切换到uadb库新建用户uadb
use uadb
db.auth("uadb","1c63129ae9db9c60c3e8aa94d3e00495")
db.dropUser("uadb");
db.createUser( {user: "uadb", pwd: "1c63129ae9db9c60c3e8aa94d3e00495", roles: [   "readWrite" , "dbAdmin" ] })

//切换到uadb库新建用户uadb_attachment
use uadb_attachment
db.dropUser("uadb_attachment");
db.createUser( {user: "uadb_attachment", pwd: "1c63129ae9db9c60c3e8aa94d3e00495", roles: [   "readWrite" , "dbAdmin" ] })
```
