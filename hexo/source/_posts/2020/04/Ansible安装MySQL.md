---
title: Ansible安装MySQL
date: 2020-04-25
tags: [Ansible]
---

ansible自动化运维-mysql
<!-- more -->

# role安装
ansible-galaxy install geerlingguy.mysql

# 修改配置
vars/main.yml:
```yml
mysql_root_password: super-secure-password
mysql_databases:
  - name: example_db
    encoding: utf8mb4
    collation: utf8mb4_bin
mysql_users:
  - name: example_user
    host: "%"
    password: similarly-secure-password
    priv: "example_db.*:ALL"
```
## playbook安装
install.yml
```yml
- hosts: dbservers
  become: yes
  vars_files:
    - vars/main.yml
  roles:
    - { role: geerlingguy.mysql }
Inside 
```
执行mysql安装
ansible-playbook install.yml  

# 参考
https://github.com/geerlingguy/ansible-role-mysql