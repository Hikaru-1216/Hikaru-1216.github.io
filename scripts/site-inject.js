'use strict';

// 站点自定义样式与脚本。用 Hexo 自带的 injector 注入，和主题无关，
// 且放在 </head> 前，保证在主题样式之后加载、能覆盖主题默认值。
hexo.extend.injector.register('head_end', '<link rel="stylesheet" href="/css/custom.css">');
hexo.extend.injector.register('body_end', '<script src="/js/course-pdf.js" defer></script>');

// 首页摘要：文章写了 description 又没用 <!-- more --> 时，用 description 当摘要，
// 避免把课程页里的按钮、徽章文字直接截断成一段乱序文本。
hexo.extend.filter.register('after_post_render', data => {
  if (data.layout === 'post' && data.description && !data.excerpt) {
    data.excerpt = data.description;
  }
  return data;
}, 20);
