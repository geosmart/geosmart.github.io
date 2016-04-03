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
* match by property
```sql
MATCH (root { name : 'root' })
return root
```
* match by ID identifier
```sql
MATCH (s)
WHERE ID(s) = 65110
RETURN s
```
* complex query
```sql
MATCH (d:District {state: {state}, district: {district}})
MATCH (d)<-[:REPRESENTS]-(l:Legislator)
MATCH (l)-[:SERVES_ON]->(c:Committee)
MATCH (c)<-[:REFERRED_TO]-(b:Bill)
MATCH (b)-[:DEALS_WITH]->(s:Subject)
WITH l.govtrackID AS govtrackID, l.lastName AS lastName, l.firstName AS firstName, l.currentParty AS party, s.title AS subject, count(*) AS strength, collect(DISTINCT c.name) AS committees ORDER BY strength DESC LIMIT 10
WITH {lastName: lastName, firstName: firstName, govtrackID: govtrackID, party: party, committees: committees} AS legislator, collect({subject: subject, strength: strength}) AS subjects
RETURN {legislator: legislator, subjects: subjects} AS r
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
# start
The START clause should only be used when accessing legacy indexes [Legacy Indexing](http://neo4j.com/docs/stable/indexing.html).In all other cases, use MATCH instead (see Section 11.1, “Match”).
In Cypher, every query describes a pattern, and in that pattern one can have multiple starting points. A starting point is a relationship or a node where a pattern is anchored. Using START you can only introduce starting points by legacy index seeks. Note that trying to use a legacy index that doesn’t exist will generate an error.

# create index
CREATE INDEX ON :PRO( preAddressNodeGUIDs)
