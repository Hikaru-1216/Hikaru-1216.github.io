document.addEventListener('DOMContentLoaded', function () {
  const recentPosts = document.getElementById('recent-posts');
  const contentInner = document.getElementById('content-inner');

  // 只在首页启用：首页一般会有 recent-posts
  if (!recentPosts || !contentInner) return;

  // 防止重复插入
  if (contentInner.querySelector('.bubble-layer')) return;

  contentInner.classList.add('has-bubbles');

  const layer = document.createElement('div');
  layer.className = 'bubble-layer';
  layer.setAttribute('aria-hidden', 'true');

  contentInner.prepend(layer);

  // 数量少：保持“氛围层”
  const bubbleCount = 14;

  for (let i = 0; i < bubbleCount; i++) {
    const bubble = document.createElement('span');
    bubble.className = 'bubble';

    const size = 14 + Math.random() * 32;       // 14px - 46px
    const left = Math.random() * 100;           // 0% - 100%
    const duration = 12 + Math.random() * 10;   // 12s - 22s
    const delay = Math.random() * 10;           // 0s - 10s
    const drift = (Math.random() * 28 - 14).toFixed(1) + 'px';

    bubble.style.width = `${size}px`;
    bubble.style.height = `${size}px`;
    bubble.style.left = `${left}%`;
    bubble.style.animationDuration = `${duration}s`;
    bubble.style.animationDelay = `${delay}s`;
    bubble.style.setProperty('--drift', drift);

    layer.appendChild(bubble);
  }
});
