title: Neo4j常用CypherQL语句
date: 2016-03-30 20:22:09
tags: [Neo4j]
categories: [数据库]
---
记录常用Cypher语句
- - -
<!-- more -->
[官方文档参考](cypher-query-lang)

# create Node
```sql
CREATE (root:User { type:'admin', name: 'root'})
CREATE (u1:User { type:'guest', name : 'user1'})
CREATE (u2:User { type:'guest', name: 'user2'})
CREATE (u3:User { type:'guest', name: 'user3'})
CREATE (u4:User { type:'guest', name: 'user4'})
```
#  Create RelationShip
```sql
MATCH (root{type:'admin' }),(guest{type:'guest'})
CREATE  (root)-[r:knows]->(guest)
RETURN r
```

#  Create  Unique RelationShip
```sql
MATCH (root{type:'admin' })
CREATE UNIQUE (root)-[r:knows]-(u5:User{name:'user5'})
RETURN  u5
```

# match Node
```sql
MATCH (root { name : 'root' })
return root
```

# match relationNode
```sql
MATCH (root{ type:'admin' })-->(user)
RETURN user
```

# match Node and relationNode
```sql
MATCH (root { type:'admin' })-[r]-(user)
RETURN r
```
# match collection
## collection contain string
```sql
match (an)
where all (x IN ['709908DCF9D24734BA8FEF8A831F1BA4'] where x in an.preAddressNodeGUIDs)
return count(an)
```

## collection equal
```sql
match (an{preAddressNodeGUIDs:['709908DCF9D24734BA8FEF8A831F1BA4 ']})
return count(an)
```

# delete relationship
## delete a node with its relationships
```sql
MATCH (n { name:'Andres' })DETACH DELETE n
```
## delete all relationships
```sql
Match (:AddressNode)-[r:parent]->(:AddressNode)
delete r
```
