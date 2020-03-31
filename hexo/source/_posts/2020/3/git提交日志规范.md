---
title: git提交日志规范
date: 2020-03-22
tags: [IO,Java]
categories: [方法论]

---

git commit -m "commit message" 每次提交的时候，总的写点什么，如果团队中每个人按一定的范式来书写提交记录，问题追溯将变的有迹可循；

目前，社区有多种 Commit message 的规范。不过一般采用较多的是Google的AngularJS的规范，有现配套的工具来实现规范化提交。

<!-- more -->  

# 为什么要提交结构化的Commit message？

结构化的commit message ，有3点好处：

* 提供更多的历史信息，方便快速浏览和问题追溯；
  * `git log <last tag> HEAD --pretty=format:%s`
* 可以按类型过滤，便于快速查找信息；
  * `git log <last release> HEAD --grep feature`
* 可以直接根据commit message生成Change log；
  * `conventional-changelog -p angular -i CHANGELOG.md -s -p `

# 怎么写结构化的Commit message？

```bash
<type>(<scope>): <subject>
// 空一行
<body>
// 空一行
<footer>
```

其中，`Header` 是必填，`Body` 和 `Footer` 是选填。

## header
`header` 包括三个字段：`type`（必填）、`scope`（选填）和 `subject`（必填）。

### type
* **feat**：新增feature；
*  **fix**：修复bug；
* **docs**：仅仅修改了文档，如修改了readme.md；
* **style**：仅仅修改了代码格式，未改变代码逻辑；
* **refactor**：代码重构，未新增功能或修复bug；
* **test**：测试用例新增/更新；
* **chore**：改变构建流程、或增加依赖库、工具等；
* **revert**：版本回滚；

如果type 为 `feat `或` fix`，则该 commit 会生成到在 Change log 中。

## 

### scope

scope 用于说明 commit 影响的范围，比如dao、controller、dto等等，视项目情况而定。

### subject

subject 本次commit 的简短描述，不超过`50`个字符。

```
以动词开头，使用第一人称现在时，比如 change，而不是 changed 或 changes
第一个字母小写
结尾不加句号（.）
```

## body

Body 部分是对本次 commit 的更详细的说明文本，建议`72`个字符以内。 

内容包括但不限于:
* 为什么这个变更是必须的? 它可能是用来修复一个bug，增加一个feature，提升性能、可靠性、稳定性等等；
* 如何解决这个问题? 具体描述解决问题的步骤；
* 是否存在副作用、风险? 


## footer

Footer 部分只用于两种情况

* 不兼容变动：如果当前代码与上一个版本不兼容，则 Footer 部分以 `BREAKING CHANGE` 开头，后面是对变动的描述、以及变动理由和迁移方法。
* 关闭Issuce：如果当前 commit 针对某个 issue，那么可以在 Footer 部分关闭这个 issue；
  * `Closes #123, #245, #992`



# 规范化Commit Message的配套工具



# 参考

* [AngularJS Git Commit Message Conventions](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#heading=h.greljkmo14y0) 