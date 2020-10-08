---
title: REST接口定义规范
date: 2020-04-19 20:49:13
tags: [REST]
---

团队REST接口定义规范
<!-- more -->

# REST接口URL定义原则
接口url的定义需遵守如下原则：
* URL中命名必须保持`Camel`风格
  * 由于团队内部的接口dto用java-swagger框架生成，故采用驼峰风格，如果不使用swagger也可采用纯小写+下划线，但需保持使用同一种风格以避免混乱；
* URL中资源（resource）的命名必须是**名词**，并且必须是**复数**形式；
* URL必须是**易读**的；
* URL一定不能暴露后端的架构；

规范：`domain/api/{version}/{resources}/{action}`
示例：服务组分页查询（mlp.com/api/v2/serviceGroups/page）

# Http Method

只使用get和post两种方法使对接变得更简单，不使用put，delete，patch等http method。

* get：简单的只读操作，如通过id查询资源明细；
* post：新增/更新/删除操作，其他复杂只读操作（如分页）；

## URL示例


app资源的crud操作
| operation    | method | url                                   |
| ------------ | ------ | ------------------------------------- |
| app分页查询 | POST   | https://mlp.com/apps/page            |
| app名称的模糊查询 | GET | https://mlp.com/apps/query?appName={appName} |
| app新增     | POST   | https://mlp.com/apps/add             |
| app删除     | POST   | https://mlp.com/apps/{appId}/delete |
| app更新     | POST   | https://mlp.com/apps/{appId}/update |
| app详情查询 | GET    | https://mlp.com/apps/{appId}/get    |

solution的curd操作（app和solution是1:n关系）
| operation    | method | url                                   |
| ------------ | ------ | ------------------------------------- |
| 查询app关联的所有solution | POST | https://mlp.com/app/{appId}/solutions |
| solution新增     | POST   | https://mlp.com/solutions/add             |
| solution删除     | POST   | https://mlp.com/solutions/{solutionId}/delete |
| solution更新     | POST   | https://mlp.com/solutions/update |
| solution详情查询 | GET    | https://mlp.com/solutions/{solutionId}/get    |

# Response
## Response Code

### Http状态码

| 状态码 | 描述                                                 |
| ------ | ---------------------------------------------------- |
| 1xx    | 代表请求已被接受，需要继续处理                       |
| 2xx    | 请求已成功，请求所希望的响应头或数据体将随此响应返回 |
| 3xx    | 重定向                                               |
| 4xx    | 客户端原因引起的错误                                 |
| 5xx    | 服务端原因引起的错误                                 |

> 只有来自客户端的请求被正确的处理后才能返回 `2xx` 的响应，所以当 API 返回 `2xx` 类型的状态码时，前端 `必须` 认定该请求已处理成功。

### 业务错误码

6位数字，如000000

* 前3位表示功能模块，
* 后3位表示错误码序号

注意：需设计通用错误码模块，然后通过具体message进行区别，避免出现太多错误码；

如：100001，PARAMS_CHECK_ERROR，参数校验错误[%s]

## Response Body

数据协议：application/json,charset=utf-8

```json
{
    "success": true,
    "value": {},
    "resultMap": {},
    "message": "",
    "msgCode": ""
}
```
| 字段名    | 必传 | 类型   | <span style="white-space:nowrap">字段说明&nbsp;</span> | 描述                 |
| --------- | ---- | ------ | ------------------------------------------------------ | -------------------- |
| success   | Y    | bool   | 是否成功                                               | true/false           |
| `value`   | Y    | object | 结果数据                                               | **JSON**格式         |
| resultMap | N    | object | 其他结果值Map                                          | 如分页结果数据       |
| msgCode   | N    | String | 错误码                                                 | 见项目的错误码对照表 |
| message   | N    | String | 错误信息                                               |                      |