title: SublimeText-Markdown书写利器
date: 2015-09-26 22:53:20
tags: [TextEditor,Markdown]
categories: [工具]
---
一些SublimeText的常用快捷键，以及一个基于SublimeText搭建的Markdown书写工具，包含主题，高亮，快捷键等内容，个人主要用SublimeText-Markdown写技术笔记
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
