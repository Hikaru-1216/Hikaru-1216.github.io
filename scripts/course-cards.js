'use strict';

// {% course_cards %}：读取 source/_data/courses.yml，渲染课程资源中心卡片。
// not-markdown：让 Redefine 主题的正文排版（下划线、列表圆点、标题字号）跳过卡片内部元素。
const STATUS = {
  ongoing: { text: '更新中', cls: 'ongoing' },
  done: { text: '已完结', cls: 'done' },
  wip: { text: '整理中', cls: 'wip' }
};

const esc = s => String(s == null ? '' : s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

hexo.extend.tag.register('course_cards', function () {
  const data = hexo.locals.get('data') || {};
  const courses = data.courses || [];
  const url = p => hexo.extend.helper.get('url_for').call(hexo, encodeURI(p));

  const cards = courses.map((c, i) => {
    const st = STATUS[c.status] || STATUS.ongoing;
    const [a1, a2] = c.accent || ['#49b1f5', '#30cfd0'];
    const cover = c.cover
      ? `<img class="course-card__img" src="${esc(url(c.cover))}" alt="" loading="lazy">`
      : `<i class="course-card__icon ${esc(c.icon || 'fas fa-book')}" aria-hidden="true"></i>`;
    const total = (c.counts || []).reduce((n, x) => n + (Number(x.num) || 0), 0);
    const counts = (c.counts || []).map(x =>
      `<span class="course-card__count"><b>${esc(x.num)}</b>${esc(x.label)}</span>`).join('');
    const tags = (c.tags || []).map(t => `<li class="not-markdown">${esc(t)}</li>`).join('');
    return `
<a class="course-card not-markdown" href="${esc(url(c.url))}" style="--c1:${esc(a1)};--c2:${esc(a2)}">
  <div class="course-card__cover">
    ${cover}
    <span class="course-card__index">${String(i + 1).padStart(2, '0')}</span>
    <span class="course-card__status course-card__status--${st.cls}">${st.text}</span>
  </div>
  <div class="course-card__body">
    <div class="course-card__semester"><i class="far fa-calendar"></i>${esc(c.semester)}</div>
    <h3 class="course-card__title not-markdown">${esc(c.title)}</h3>
    <p class="course-card__en not-markdown">${esc(c.en)}</p>
    <p class="course-card__summary not-markdown">${esc(c.summary)}</p>
    <ul class="course-card__tags not-markdown">${tags}</ul>
    <div class="course-card__foot">
      <div class="course-card__counts">${counts}</div>
      <span class="course-card__go" aria-hidden="true"><i class="fas fa-arrow-right"></i></span>
    </div>
  </div>
  <span class="sr-only">共 ${total} 项资源</span>
</a>`;
  }).join('');

  const totalRes = courses.reduce((n, c) =>
    n + (c.counts || []).reduce((m, x) => m + (Number(x.num) || 0), 0), 0);

  return `
<div class="course-hub">
  <div class="course-hub__stats">
    <div><b>${courses.length}</b><span>门课程</span></div>
    <div><b>${totalRes}</b><span>份资源</span></div>
    <div><b>${courses.filter(c => c.status !== 'done').length}</b><span>门整理中</span></div>
  </div>
  <div class="course-grid">${cards}</div>
</div>`;
});
