title: Hexo安装
date: 2015-06-30 12:58:32
tags: [博客] 
categories: [工具]
---


# hexo环境搭建
``` bash  
npm install -g hexo-cli
hexo init
npm install
npm install hexo-deployer-git --save
npm install hexo-server --save
npm install hexo-generator-sitemap --save
npm install hexo-generator-feed --save
npm install hexo-toc --save
npm install hexo-html-minifier --save
```

# 可选插件
``` bash  
npm un hexo-renderer-marked --save
npm i hexo-renderer-markdown-it --save
```

# 常用命令
``` bash   
hexo g (generate)
hexo s (server)
hexo clean (clear public)
hexo n  [layout] <title >(new post)
eg:hexo n draft title
hexo publish [layout] <title>
eg:hexo publish draft title
hexo d (deploy)
hexo d -g (generate and deploy)

hexo g
hexo s

```

# 配置评论插件
多说挂了，换gitment,参考
* [Gitment：使用 GitHub Issues 搭建评论系统](https://imsun.net/posts/gitment-introduction/)
* [hexo next主题集成gitment评论系统](http://yangq.me/post/ab9bb85a.html)


# 常见问题
## hexo部署错误
错误日志：Error: spawn git ENOENT  
解决方案：  
方案1）添加环境变量C:\Program Files (x86)\Git\bin;C:\Program Files (x86)\Git\libexec\git-core
方案2）安装github windows>在项目中Open in Gitshell>执行hexo d -g
