---
title: Ansible自动化运维笔记
date: 2020-04-01 14:36:33
tags: [DevOps,Ansible]
categories: [OPS]
---

Ansible自动化运维工具学习笔记，告别乱糟糟的shell脚本
<!-- more -->

# 关于Ansible
Ansilbe是一个部署一群远程主机的工具。远程的主机可以是远程虚拟机或物理机， 也可以是本地主机。
Ansilbe通过SSH协议实现远程节点和管理节点之间的通信。
理论上说，只要管理员通过ssh登录到一台远程主机上能做的操作，Ansible都可以做到。
包括：
* 拷贝文件
* 安装软件包
* 启动服务
* …

# Ansible的安装
centos7环境安装
```
sudo yum install ansible
```

# Ansible的理念
Ansilbe控制节点和远程主机节点通过ssh协议进行通信。
所以Ansible配置的时候只需要保证从Ansible控制节点通过SSH能够连接到被管理的主机节点即可。

## Control node
已安装Ansible的控制节点

## Managed nodes
被管理节点，也成为主机（hosts），主机节点不安装Ansible；
在/etc/ansible/hosts中定义

## Inventory
主机列表,inventory文件也称为hostfile；
如主机节点的ip地址，在/etc/ansible/hosts中定义

## Modules
模块为Ansible执行的代码代码单元，

## Tasks
Ansible的执行动作单元

## Playbooks
Playbooks为有序的tasks列表，以yaml格式编写

# Ansible命令
## 验证安装
ansible all -m ping -u root

## 文件复制
ansible blog -m copy -a "src=/mnt/hgfs/WorkSpace/NoteSpace/geosmart.github.io/hexo/public dest=/home/geosmart.top  owner=root group=root mode=0755"

# Ansible脚本(playbook)
## 文件复制
利用ansible发布博客更新 ：`ansible-playbook  deploy.yml`

deploy.yml内容
```yaml
---
- hosts: blog
  user: root
  tasks:
    - name: clean exist blog files
      shell: rm -rf /home/geosmart.top/*
    - name: copy new blog files
      copy:
        src: /mnt/hgfs/WorkSpace/NoteSpace/geosmart.github.io/hexo/public/
        dest: /home/geosmart.top/
```

# roles
Roles 可以降低 Playbooks 的复杂性，增加 Playbooks 的可用性。
role库地址：[ansible galaxy](https://galaxy.ansible.com/)
## role的结构
```bash
$ tree .
.
└── example_role
    ├── README.md     # 说明文件
    ├── defaults
    │   └── main.yml  # 可被覆写的变数。
    ├── files         # 需复制到 Managed node 的档案。
    ├── handlers
    │   └── main.yml  # 主要的 handler。
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml  # 主要的 task。
    ├── templates     # 集中存放 Jinja2 模板的目录。
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml  # 不该被覆写的变数。

9 directories, 8 files
```

## 下载role
`ansible-galaxy install mdklatt.python3 -p /etc/ansible/roles `

## 安装role
定义install_python3.yml
```yaml
- name: install python3
  hosts: blog
  roles:
    - name: mdklatt.python3
      python3_pyenv: "3.6.4"
      python3_local: "/opt/python3"
```

安装命令： `ansible-playbook install_python3.yml -e "tmpdir_path=/tmp" --verbose`，
默认安装在主机节点的`/root/.pyenv/versions/3.6.4`目录

# template模板(jinja2)
## 以Jinja2定义模板文件
```bash
vi hello_world.txt.j2
Hello "{{ dynamic_word }}"
```
## 在playbook中注入变量默认值
```yaml
- name: test
  hosts: localhost
  vars:
    var1: "World"

  tasks:
    - name: generate hello_world.txt
      template:
         src: hello_world.txt.j2
         dest: /tmp/hello_world.txt
    - name: show file
      command: cat /tmp/hello_world.txt
      register: result    
    - name: print stdout
      debug:
        msg: ""
```
## 运行playbook时设置变量值；
`ansible-playbook template_demo.yml -e "dynamic_word=ansible"`

# 参考
* [yaml格式校验工具](http://www.bejson.com/validators/yaml/)
* [playbook-example](https://github.com/ansible/ansible-examples)
* [ansible-first-book](https://www.gitbook.com/book/ansible-book/ansible-first-book)
* 