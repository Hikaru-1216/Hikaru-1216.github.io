document.addEventListener('DOMContentLoaded', function () {
  const recentPosts = document.getElementById('recent-posts');

  // 只在首页启用：首页一般会有 recent-posts
  if (!recentPosts) return;

  // 防止重复插入
  if (recentPosts.querySelector('.bubble-layer')) return;

  recentPosts.classList.add('has-bubbles');

  const layer = document.createElement('div');
  layer.className = 'bubble-layer';
  layer.setAttribute('aria-hidden', 'true');

  recentPosts.prepend(layer);

  // 数量少：保持“氛围层”
  const bubbleCount = 16;

  for (let i = 0; i < bubbleCount; i++) {
    const bubble = document.createElement('span');
    bubble.className = 'bubble';

    const size = 16 + Math.random() * 34;       // 16px - 50px
    const left = Math.random() * 100;           // 0% - 100%
    const duration = 11 + Math.random() * 9;    // 11s - 20s
    const delay = Math.random() * 8;            // 0s - 8s
    const drift = (Math.random() * 32 - 16).toFixed(1) + 'px';

    bubble.style.width = `${size}px`;
    bubble.style.height = `${size}px`;
    bubble.style.left = `${left}%`;
    bubble.style.animationDuration = `${duration}s`;
    bubble.style.animationDelay = `${delay}s`;
    bubble.style.setProperty('--drift', drift);

    layer.appendChild(bubble);
  }
});
