title: SublimeText-Markdown书写利器
date: 2015-09-26 22:53:20
tags: [TextEditor,Markdown]
categories: [工具]
---

曾尝试寻找在线平台写博客

* segmentfault：专栏文章模块markdown编写可检测剪贴板图片，且需要审核；但是笔记模块不支持
* csdn：改版的markdown编辑器很好，但是不支持粘帖图片，且存在删文风险 

几经周折，最终还是选择了自己搭建写作环境：`sumblime配置markdown写作环境 + evernote笔记检索+hexo博客框架 + github.io发布  `；
以sublimeText编辑器作为写作环境（markdown语法高亮/预览），以sublime-evernote发布到evernote，hexo搭建博客框架定期发布到github.io，
谨记编辑器够用就好，内容应始终放在第一位。

- - -
<!-- more -->

# 安装Package Control

使用Ctrl+`快捷键或者通过View->Show Console菜单打开命令行，粘贴如下代码：

`import urllib.request,os; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); open(os.path.join(ipp, pf), 'wb').write(urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ','%20')).read())`

# SublimeText快捷键

- 命令面板：Ctrl+Shift+P'
- 列选择：Shirft+右键
- 行选择：Ctrl+L
- 全屏书写：Shirft + F11

# SublimeText 用户配置

主题：Material-Theme

```json
{
    "color_scheme": "Packages/Monokai Extended/Monokai Extended Bright.tmTheme",
    "draw_centered": false,
    "font_face": "Consolas",
    "font_size": 9,
    "gutter": true,
    "ignored_packages":
    [
        "Markdown",
        "Vintage"
    ],
    "index_exclude_patterns":
    [
      "*.log",
      "*.gitignore"
    ],
    "line_numbers": true,
    "line_padding_bottom": 1,
    "line_padding_top": 1,
    "scroll_past_end": true,
    "tab_size": 2,
    "theme": "Material-Theme.sublime-theme",  
    "translate_tabs_to_spaces": false,
    "word_wrap": true
}
```

# Markdown插件

## Markdown语法高亮：Monokai

语法高亮：Monokai Extended<br>[Github地址](https://github.com/jonschlinkert/sublime-monokai-extended) ![效果图](sublimetext.png)

## Markdown编辑：MarkdownEditing
设置为MarkdownEditing>MultiMarkDown
[官方文档](https://github.com/SublimeText-Markdown/MarkdownEditing#key-bindings)

- 选择内容设为链接：Ctrl + Win + V  
- 粘贴板内容设为链接：Ctrl + Win + R
- 插入链接：Ctrl + Win + K
- 插入图片：Shift + Win + K
- 加粗：Ctrl + Shift + B
- 斜体：Ctrl + Shift + I
- 标题：Ctrl + 1/2/3/4/5/6
- 显示Markdown文件标题：Ctrl + Shift + R

## Markdown预览：OmniMarkupPreviewer

- Ctrl + Alt + O: 在浏览器中预览(实时无需刷新的哦)
- Ctrl + Alt + X: 导出HTML
- Ctrl + Alt + C: HTML标记拷贝至剪贴板

## markdown样式

next主题修改：`/next/source/css/_variables/base.styl`文件中的`$font-family-chinese`、`$font-size-base`等属性定制

```css
body {
  position: relative;
  color: #333;
  background: #fff;
  font-size: 14.5px;
  line-height: 1.8;
  font-family: Consolas, monaco, "Helvetica Neue", Helvetica, Arial, "Hiragino Sans GB", "Microsoft YaHei", STHeiti, "WenQuanYi Micro Hei", sans-serif;
}
```

# sublime配置笔记同步到evernote
[参考配置sublime-evernote](http://www.jianshu.com/p/f5118d466f81/comments/2422205)

Evernote 的快捷键在 Key Bindings——User配置

```json
[
{ "keys": ["super+e"], "command": "show_overlay", "args": {"overlay": "command_palette", "text": "Evernote: "} },
{ "keys": ["ctrl+e", "ctrl+s"], "command": "send_to_evernote" },
{ "keys": ["ctrl+e", "ctrl+o"], "command": "open_evernote_note" },
{ "keys": ["ctrl+e", "ctrl+u"], "command": "save_evernote_note" },
] 
```
如新增笔记：["ctrl+e", "ctrl+s"] 就是先按完ctrl + e 后再按 ctrl + s ；

sublime-evernote配置

```json
 {
  "code_friendly": true,
  "code_highlighting_style": "github",
  "extensions":
  [
    "md"
  ],
  "noteStoreUrl": "https://www.evernote.com/shard/s56/notestore",
  "show_stacks": true,
  "token": "S=s56:U=63871d:E=15c7d92376e:C=15525e109a8:P=1cd:A=en-devtoken:V=2:H=b30896c360f9be6886b610bbb7dc7df3",
  "update_on_save": true
}
```

 
## 问题记录
## markdown笔记与evernote保留字冲突问题  
* 问题描述：Evernote complained:The contents of the note are not valid. The inline HTML tag 'String' is not allowed in Evernote notes.Retry?    
* 问题解决：List<String>改为List< String>接警

