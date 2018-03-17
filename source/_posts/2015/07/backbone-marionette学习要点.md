title: backbone.marionette学习要点
date: 2015-07-28 13:35:07
tags: [Backbone,Marionette] 
categories: [前端技术] 
---

# Marionette（Backbone的牵线木偶）
提供rendering、template管理、UI对象
# Model
rest数据，event事件
# Collection：List<model>

# View
## ItemView
* Backbone.View的扩展，用于渲染Backbone.Model
* 拥有modelEvents属性，可绑定View方法

## CollectionView
* 用于渲染Backbone.Collection
* 可渲染List<ItemView>
* 拥有collectionEvents/childEvents属性，
* add/remove/reset/etc后自动更新视图
* 支持Filtering（filter方法）、Sorting（comparator属性）
* 支持Pagination

## CompositeView 
* renders a Collection within a template
* ItemView（model）和CollectionView（collection）的组合
* 用于detail/table/nested lists/treeview类型的场景

# View Containers
## Region
View容器，渲染至DOM，DOM和Backbone的桥梁
## LayoutView
* 用于复杂嵌套布局，multi-view组成的widget
* Region容器
* render all in one call

# Application 
initialization初始化和 bootstrapping引导程序
# Module
类似Application，多个Modules组成Application
可控制start/stop模块（及其子模块）
# Controller
组件间的交互，用于复杂业务逻辑的业务场景

layouts/regions：动态create/display/dispose页面dom
# event aggregrator
可bind/trigger事件
module/application级别的事件通道，其他所有模块都可监听，可用于如用户登陆成功的业务场景
# Commands
多处触发，一处处理

# Request/Response
用于提供Application Level Data，如购物车当前状态
提供全局状态，无需所有模块都做处理，但易被滥用，当全局可操作时难预测其影响


appRouter：
