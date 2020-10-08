---
title: VUE基础知识
date: 2020-05-25 13:47:07
tags: [frontend]
---

全栈之路必备springboot+vuejs，点亮vue

<!-- more -->  

# VUE介绍
VUE.js是一套构建用户界面的渐进式框架。目标是通过尽可能简单的 API 实现响应的数据绑定和组合的视图组件。
* 组件系统是 Vue 的另一个重要概念，因为它是一种抽象，允许我们使用小型、独立和通常可复用的组件构建大型应用.


# 示例
在一个大型应用中，有必要将整个应用程序划分为组件，以使开发更易管理
```html
<div id="app">
  <app-nav></app-nav>
  <app-view>
    <app-sidebar></app-sidebar>
    <app-content></app-content>
  </app-view>
</div>
```

# VUE项目的目录结构

```sequence
asd
```

# 参考
* [vue2-guide](https://cn.vuejs.org/v2/guide/index.html)