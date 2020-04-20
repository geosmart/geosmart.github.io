---
title: Jenkins自动化发布
date: 2020-04-02 14:36:33
tags: [Jenkins,Ansible]
categories: [OPS]
---

Ansible自动化运维工具学习笔记，告别手动发布，保证代码质量。
<!-- more -->


# 安装Gerrit
java -jar gerrit-3.1.4.war  init -d /opt/gerrit/repo

```sql
CREATE DATABASE reviewdb;
ALTER DATABASE reviewdb charset=latin1;
CREATE USER 'gerrit2'@'localhost' IDENTIFIED BY 'gerrit2';
GRANT ALL ON reviewdb.* TO 'gerrit2'@'localhost';
FLUSH PRIVILEGES;
```



# 安装jenkins
配置/root/.ansible/roles/geerlingguy.jenkins/defaults/main.yml中的插件
```yml
# Plugin list can use the plugin name, or a name/version dict.
jenkins_plugins: [jenkins-job-builder,code-coverage-api]

```
安装脚本
vim install_jenkins.yml
```yml
---
- hosts: 127.0.0.1
  connection: local
  vars:
    jenkins_hostname: localhost
  roles:
    - role: geerlingguy.jenkins
      become: yes
```