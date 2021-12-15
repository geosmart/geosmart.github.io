#!/bin/bash
set -ex
set +H 
cd /opt/cdh/lib 
shopt -s extglob 
rm -rf !(avro|hadoop|hadoop-0.20-mapreduce|hadoop-hdfs|hadoop-mapreduce|hadoop-yarn|hive|hive-hcatalog|hbase|parquet|sqoop2|sqoop|zookeeper|zookeeper-native|kite|bigtop-utils)