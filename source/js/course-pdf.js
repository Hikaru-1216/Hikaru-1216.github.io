/* 课程资料页：PDF 预览懒加载
   - 桌面端：.pdf-embed 进入视口（提前 300px）时才插入 iframe
   - 手机端（≤768px）：不加载 iframe，保留“在新窗口打开”链接 */
(function () {
  var embeds = document.querySelectorAll('.pdf-embed[data-src]');
  if (!embeds.length) return;

  var mobile = window.matchMedia('(max-width: 768px)');

  function load(el) {
    if (el.classList.contains('is-loaded')) return;
    var frame = document.createElement('iframe');
    frame.src = el.getAttribute('data-src');
    frame.title = el.getAttribute('data-title') || 'PDF 预览';
    el.appendChild(frame);
    el.classList.add('is-loaded');
  }

  function start() {
    if (mobile.matches) return;
    if (!('IntersectionObserver' in window)) {
      embeds.forEach(load);
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          load(entry.target);
          io.unobserve(entry.target);
        }
      });
    }, { rootMargin: '300px 0px' });
    embeds.forEach(function (el) { io.observe(el); });
  }

  start();
  // 从手机宽度切到桌面宽度（如旋转平板）时补加载
  if (mobile.addEventListener) {
    mobile.addEventListener('change', function (e) { if (!e.matches) start(); });
  }
})();
