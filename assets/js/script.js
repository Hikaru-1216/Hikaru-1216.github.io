document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("rotating-subtitle");
  if (!el) return;

  const lines = [
    "Suffering is the price of freedom",
    "Code. Learn. Share.",
    "Stay hungry, stay foolish.",
    "向光而行，步履不停。"
  ];

  let i = 0;

  function playLine(text) {
    el.classList.remove("fade-out-right");
    el.textContent = text;
    void el.offsetWidth; // 触发重排，确保动画重复生效
    el.classList.add("fade-in");

    setTimeout(() => {
      el.classList.remove("fade-in");
      el.classList.add("fade-out-right");
    }, 2200);
  }

  function loop() {
    playLine(lines[i]);
    i = (i + 1) % lines.length;
    setTimeout(loop, 3200);
  }

  loop();

  /**
   * 闪烁星光背景：恒星常态微闪动，鼠标移动时附近星光被牵引汇聚、变亮
   */
  const canvas = document.createElement("canvas");
  canvas.className = "interaction-canvas";
  document.body.appendChild(canvas);

  const ctx = canvas.getContext("2d");
  const prefersReduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const mouse = {
    x: window.innerWidth / 2,
    y: window.innerHeight / 2,
    active: false,
    lastMove: 0,
  };

  const STAR_COUNT = prefersReduceMotion ? 140 : 240;
  const MIN_RADIUS = 0.7;
  const MAX_RADIUS = 2.3;
  const BASE_SPEED = prefersReduceMotion ? 0.02 : 0.04;
  const TWINKLE_SPEED_MIN = 0.0006;
  const TWINKLE_SPEED_RANGE = 0.0018;
  const MOUSE_INFLUENCE_RADIUS = prefersReduceMotion ? 180 : 240;
  const MOUSE_PULL = prefersReduceMotion ? 0.00035 : 0.0006;
  const SPEED_DAMPING = 0.992;
  const EDGE_MARGIN = 28;

  let canvasWidth = window.innerWidth;
  let canvasHeight = window.innerHeight;
  const stars = [];

  function resizeCanvas() {
    const dpr = window.devicePixelRatio || 1;
    canvasWidth = window.innerWidth;
    canvasHeight = window.innerHeight;
    canvas.width = Math.round(canvasWidth * dpr);
    canvas.height = Math.round(canvasHeight * dpr);
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  resizeCanvas();
  window.addEventListener("resize", resizeCanvas);

  function createStar(x = Math.random() * canvasWidth, y = Math.random() * canvasHeight) {
    return {
      x,
      y,
      vx: (Math.random() - 0.5) * BASE_SPEED,
      vy: (Math.random() - 0.5) * BASE_SPEED,
      radius: MIN_RADIUS + Math.random() * (MAX_RADIUS - MIN_RADIUS),
      baseAlpha: 0.35 + Math.random() * 0.45,
      twinkleOffset: Math.random() * Math.PI * 2,
      twinkleSpeed: TWINKLE_SPEED_MIN + Math.random() * TWINKLE_SPEED_RANGE,
      pulse: 0,
    };
  }

  function seedStars() {
    stars.length = 0;
    for (let i = 0; i < STAR_COUNT; i++) {
      stars.push(createStar());
    }
  }
  seedStars();

  window.addEventListener("mousemove", (event) => {
    mouse.x = event.clientX;
    mouse.y = event.clientY;
    mouse.active = true;
    mouse.lastMove = performance.now();
  });

  window.addEventListener("mouseleave", () => {
    mouse.active = false;
  });

  let lastTime = performance.now();
  function draw(now) {
    const delta = Math.min(32, now - lastTime);
    lastTime = now;
    ctx.clearRect(0, 0, canvasWidth, canvasHeight);

    const mouseEngaged = mouse.active || now - mouse.lastMove < 420;

    if (mouseEngaged) {
      ctx.save();
      const halo = ctx.createRadialGradient(mouse.x, mouse.y, 0, mouse.x, mouse.y, MOUSE_INFLUENCE_RADIUS);
      halo.addColorStop(0, "rgba(255, 241, 224, 0.22)");
      halo.addColorStop(0.35, "rgba(164, 199, 255, 0.16)");
      halo.addColorStop(1, "rgba(12, 20, 38, 0)");
      ctx.globalCompositeOperation = "screen";
      ctx.fillStyle = halo;
      ctx.fillRect(0, 0, canvasWidth, canvasHeight);
      ctx.restore();
    }

    for (const star of stars) {
      // 轻微漂移
      star.x += star.vx * delta;
      star.y += star.vy * delta;
      star.vx *= SPEED_DAMPING;
      star.vy *= SPEED_DAMPING;

      // 边界回环
      if (star.x < -EDGE_MARGIN) star.x = canvasWidth + EDGE_MARGIN;
      if (star.x > canvasWidth + EDGE_MARGIN) star.x = -EDGE_MARGIN;
      if (star.y < -EDGE_MARGIN) star.y = canvasHeight + EDGE_MARGIN;
      if (star.y > canvasHeight + EDGE_MARGIN) star.y = -EDGE_MARGIN;

      // 鼠标牵引聚光
      if (mouseEngaged) {
        const dx = mouse.x - star.x;
        const dy = mouse.y - star.y;
        const dist = Math.hypot(dx, dy);
        if (dist < MOUSE_INFLUENCE_RADIUS && dist > 0.001) {
          const influence = 1 - dist / MOUSE_INFLUENCE_RADIUS;
          const pull = influence * MOUSE_PULL * delta;
          star.vx += dx * pull;
          star.vy += dy * pull;
          star.pulse = Math.min(1.4, star.pulse + influence * 0.04);
        }
      }

      // 脉冲衰减
      star.pulse = Math.max(0, star.pulse - 0.008 * delta);

      // 闪烁
      const twinkle = 0.6 + 0.4 * Math.sin(star.twinkleOffset + now * star.twinkleSpeed);
      const brightness = Math.min(1, star.baseAlpha * twinkle + star.pulse);
      const radius = star.radius * (1 + twinkle * 0.25 + star.pulse * 0.45);

      ctx.beginPath();
      ctx.fillStyle = `rgba(220, 233, 255, ${brightness})`;
      ctx.shadowColor = `rgba(149, 186, 255, ${0.35 + brightness * 0.35})`;
      ctx.shadowBlur = prefersReduceMotion ? 10 : 14 + star.pulse * 10;
      ctx.arc(star.x, star.y, radius, 0, Math.PI * 2);
      ctx.fill();
    }

    requestAnimationFrame(draw);
  }

  requestAnimationFrame(draw);
});
