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
npm install hexo-filter-sequence --save 
npm install hexo-filter-flowchart --save 
npm install hexo-related-popular-posts --save
```

# 可选插件
``` bash  
npm un hexo-renderer-marked --save
npm i hexo-renderer-markdown-it --save
```

# next主题的数学公式配置
```yaml
# Math Formulas Render Support
math:
  per_page: false
  mathjax:
    enable: true
    cdn: //cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML
    mhchem: false
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


## sequence插件配置
1. 在 _config.yml 中添加 sequence:相关配置
```yaml
sequence:
  raphael: https://cdn.bootcss.com/raphael/2.2.8/raphael.min.js
  webfont: https://cdn.bootcss.com/webfont/1.6.28/webfontloader.js
  snap: https://cdn.bootcss.com/snap.svg/0.5.1/snap.svg-min.js
  underscore: https://cdn.bootcss.com/underscore.js/1.9.1/underscore-min.js
  sequence: https://cdn.bootcss.com/js-sequence-diagrams/1.0.6/sequence-diagram-min.js
  # css: # optional, the url for css, such as hand drawn theme 
  options: 
    theme: 
    css_class: 
```
2. 修改 node_modules/hexo-filter-sequence/index.js文件，将其彻底清空，然后将以下内容copy进去
```javascript
// index.js
var assign = require('deep-assign');
var renderer = require('./lib/renderer');

hexo.config.sequence = assign({
  webfont: 'https://cdnjs.cloudflare.com/ajax/libs/webfont/1.6.27/webfontloader.js',
  // sequence-diagram 1.x 版本依赖 raphael, 2.x版本依赖 snap
  raphael: 'https://cdnjs.cloudflare.com/ajax/libs/raphael/2.2.7/raphael.min.js',
  snap: 'https://cdnjs.cloudflare.com/ajax/libs/snap.svg/0.4.1/snap.svg-min.js',
  underscore: 'https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js',
  sequence: 'https://cdnjs.cloudflare.com/ajax/libs/js-sequence-diagrams/1.0.6/sequence-diagram-min.js',
  css: '',
  options: {
    theme: 'simple'
  }
}, hexo.config.sequence);

hexo.extend.filter.register('before_post_render', renderer.render, 9);
```
3. 修改 node_modules/hexo-filter-sequence/lib/renderer.js文件，将 26 - 31 行，var config = this.config.flowchart; 及以下的 data.content 等行做如下修改。
```javascript
if (sequences.length) {
      var config = this.config.sequence;
      // resources
      data.content += '<script src="' + config.webfont + '"></script>';
      // sequence-diagram 1.x 版本依赖 raphael, 2.x版本依赖 snap
      data.content += '<script src="' + config.raphael + '"></script>';
      data.content += '<script src="' + config.snap + '"></script>';
      data.content += '<script src="' + config.underscore + '"></script>';
      data.content += '<script src="' + config.sequence + '"></script>';
      ......
}
```
4. 修改完毕后执行 hexo clean，hexo g，hexo s
5. 时序图可以正常显示了
