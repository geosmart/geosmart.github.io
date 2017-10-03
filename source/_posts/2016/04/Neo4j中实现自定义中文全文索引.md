title: Neo4j中实现自定义中文全文索引
date: 2016-04-21 21:17:53
tags: [Neo4j,Lucene]
categories: 数据库
---
数据库检索效率时，一般首要优化途径是从索引入手，然后根据需求再考虑更复杂的负载均衡、读写分离和分布式水平/垂直分库/表等手段；
索引通过信息冗余来提高检索效率，其以空间换时间并会降低数据写入的效率；因此对索引字段的选择非常重要。
* Neo4j可对指定Label的Node Create Index，当新增/更新符合条件的Node属性时，Index会自动更新。Neo4j Index默认采用Lucene实现（可定制，如Spatial Index自定义实现的RTree索引），但默认新建的索引只支持精确匹配（get），模糊查询（query）的话需要以全文索引，控制Lucene后台的分词行为。  
* Neo4j全文索引默认的分词器是针对西方语种的，如默认的exact查询采用的是lucene KeywordAnalyzer（关键词分词器）,fulltext查询采用的是 white-space tokenizer（空格分词器），大小写什么的对中文没啥意义；所以针对中文分词需要挂一个中文分词器，如IK Analyzer,Ansj，至于类似梁厂长家的基于深度学习的分词系统pullword，那就更厉害啦。   

本文以常用的IK Analyzer分词器为例，介绍如何在Neo4j中对字段新建全文索引实现模糊查询。
- - -
<!-- more -->

# IKAnalyzer分词器
[IKAnalyzer](https://github.com/wks/ik-analyzer)是一个开源的，基于java语言开发的轻量级的中文分词工具包。
IKAnalyzer3.0特性:
* 采用了特有的“正向迭代最细粒度切分算法“，支持细粒度和最大词长两种切分模式；具有83万字/秒（1600KB/S）的高速处理能力。
* 采用了多子处理器分析模式，支持：英文字母、数字、中文词汇等分词处理，兼容韩文、日文字符优化的词典存储，更小的内存占用。支持用户词典扩展定义
* 针对Lucene全文检索优化的查询分析器IKQueryParser(作者吐血推荐)；引入简单搜索表达式，采用歧义分析算法优化查询关键字的搜索排列组合，能极大的提高Lucene检索的命中率。
IK Analyser目前还没有maven库，还得自己手动下载install到本地库，下次空了自己在github做一个maven私有库，上传这些maven central库里面没有的工具包。

# IKAnalyzer自定义用户词典
* 词典文件
自定义词典后缀名为.dic的词典文件，必须使用无BOM的UTF-8编码保存的文件。  
* 词典配置
词典和IKAnalyzer.cfg.xml配置文件的路径问题，IKAnalyzer.cfg.xml必须在src根目录下。词典可以任意放，但是在IKAnalyzer.cfg.xml里要配置对。如下这种配置，ext.dic和stopword.dic应当在同一目录下。
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>  
<comment>IK Analyzer 扩展配置</comment>

<!--用户可以在这里配置自己的扩展字典 -->
<entry key="ext_dict">/ext.dic;</entry>

<!--用户可以在这里配置自己的扩展停止词字典-->
<entry key="ext_stopwords">/stopword.dic</entry>
</properties>
```

# Neo4j全文索引构建
指定IKAnalyzer作为luncene分词的analyzer，并对所有Node的指定属性新建全文索引
```java
  @Override
  public void createAddressNodeFullTextIndex () {
      try (Transaction tx = graphDBService.beginTx()) {
        IndexManager index = graphDBService.index();
        Index<Node> addressNodeFullTextIndex =
              index.forNodes( "addressNodeFullTextIndex", MapUtil.stringMap(IndexManager.PROVIDER, "lucene", "analyzer", IKAnalyzer.class.getName()));

        ResourceIterator<Node> nodes = graphDBService.findNodes(DynamicLabel.label( "AddressNode"));
        while (nodes.hasNext()) {
            Node node = nodes.next();
            //对text字段新建全文索引
            Object text = node.getProperty( "text", null);
            addressNodeFullTextIndex.add(node, "text", text);
        }
        tx.success();
      }
  }
```
# Neo4j全文索引测试
对关键词（如'有限公司'），多关键词模糊查询（如'苏州 教育 公司'）默认都能检索，且检索结果按关联度已排好序。
``` java
package uadb.tr.neodao.test;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Transaction;
import org.neo4j.graphdb.index.Index;
import org.neo4j.graphdb.index.IndexHits;
import org.neo4j.graphdb.index.IndexManager;
import org.neo4j.helpers.collection.MapUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.wltea.analyzer.lucene.IKAnalyzer;

import com.lt.uadb.tr.entity.adtree.AddressNode;
import com.lt.util.serialize.JsonUtil;

/**
 * AddressNodeNeoDaoTest
 *
 * @author geosmart
 */
@RunWith(SpringJUnit4ClassRunner. class)
@ContextConfiguration(locations = { "classpath:app.neo4j.cfg.xml" })
public class AddressNodeNeoDaoTest {
      @Autowired
      GraphDatabaseService graphDBService;

      @Test
      public void test_selectAddressNodeByFullTextIndex() {
             try (Transaction tx = graphDBService.beginTx()) {
                  IndexManager index = graphDBService.index();
                  Index<Node> addressNodeFullTextIndex = index.forNodes("addressNodeFullTextIndex" ,
                              MapUtil. stringMap(IndexManager.PROVIDER, "lucene", "analyzer" , IKAnalyzer.class.getName()));
                  IndexHits<Node> foundNodes = addressNodeFullTextIndex.query("text" , "苏州 教育 公司" );
                   for (Node node : foundNodes) {
                        AddressNode entity = JsonUtil.ConvertMap2POJO(node.getAllProperties(), AddressNode. class, false, true);
                        System. out.println(entity.getAll地址实全称());
                  }
                  tx.success();
            }
      }
}
```

# CyperQL中使用自定义全文索引查询
## 正则查询
```sql
profile  
match (a:AddressNode{ruleabbr:'TOW',text:'唯亭镇'})<-[r:BELONGTO]-(b:AddressNode{ruleabbr:'STR'})
where b.text=~ '金陵.*'
return a,b
```

## 全文索引查询
```sql
profile
START b=node:addressNodeFullTextIndex("text:金陵*")
match (a:AddressNode{ruleabbr:'TOW',text:'唯亭镇'})<-[r:BELONGTO]-(b:AddressNode)
where b.ruleabbr='STR'
return a,b
```

# LegacyIndex中建立联合exact和fulltext索引
对label为AddressNode的节点，根据节点属性ruleabbr的分类addressnode_fulltext_index（省->市->区县->乡镇街道->街路巷/物业小区）/addressnode_exact_index(门牌号->楼幢号->单元号->层号->户室号)，对属性text分别建不同类型的索引
```sql
profile
START a=node:addressnode_fulltext_index("text:商业街"),b=node:addressnode_exact_index("text:二期19")
match (a:AddressNode{ruleabbr:'STR'})-[r:BELONGTO]-(b:AddressNode{ruleabbr:'TAB'})
return a,b limit 10
```
