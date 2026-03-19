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
   * 轻量的鼠标跟随连线效果
   * 会在鼠标经过位置生成一簇微粒，并在相邻粒子/鼠标之间绘制柔和的连线
   */
  const canvas = document.createElement("canvas");
  canvas.className = "interaction-canvas";
  document.body.appendChild(canvas);

  const ctx = canvas.getContext("2d");
  const colorWithAlpha = (base, alpha) => `rgba(${base.join(",")}, ${alpha})`;
  const COLOR_BASES = {
    node: [132, 150, 255],
    lineNear: [146, 169, 255],
    lineMouse: [168, 186, 255],
    glow: [168, 186, 255],
  };
  const enableGlow = !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const points = [];
  const mouse = { x: window.innerWidth / 2, y: window.innerHeight / 2, active: false };
  const MAX_PARTICLE_COUNT = 90;
  const MAX_CONNECTIONS_PER_PARTICLE = 4;
  const MAX_PARTICLE_CONNECTION_DISTANCE = 160;
  const MAX_MOUSE_CONNECTION_DISTANCE = 190;
  const MAX_MOUSE_LINES = 18;
  const PARTICLE_SPAWN_SPREAD = 26;
  const MAX_PARTICLE_VELOCITY = 0.45;
  const DRIFT_NOISE = 0.006;
  const MIN_PARTICLE_LIFE = 420;
  const PARTICLE_LIFE_RANGE = 280;
  const PARTICLE_RADIUS = 1.6;
  const PARTICLE_LINE_WIDTH = 1.4;
  const MOUSE_LINE_WIDTH = 1.1;
  const MOUSE_RELOCATE_THROTTLE_MS = 45;
  const EDGE_RESPAWN_MARGIN = 24;
  let lastRelocateAt = 0;

  function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resizeCanvas();
  window.addEventListener("resize", resizeCanvas);

  function createParticle(x = Math.random() * canvas.width, y = Math.random() * canvas.height) {
    return {
      x,
      y,
      vx: (Math.random() - 0.5) * MAX_PARTICLE_VELOCITY,
      vy: (Math.random() - 0.5) * MAX_PARTICLE_VELOCITY,
      life: Math.random() * MIN_PARTICLE_LIFE * 0.4,
      maxLife: MIN_PARTICLE_LIFE + Math.random() * PARTICLE_LIFE_RANGE,
    };
  }

  function recycleParticle(p, x, y) {
    p.x = x;
    p.y = y;
    p.vx = (Math.random() - 0.5) * MAX_PARTICLE_VELOCITY * 0.85;
    p.vy = (Math.random() - 0.5) * MAX_PARTICLE_VELOCITY * 0.85;
    p.life = 0;
    p.maxLife = MIN_PARTICLE_LIFE + Math.random() * PARTICLE_LIFE_RANGE;
  }

  function seedFloatingParticles() {
    points.length = 0;
    for (let i = 0; i < MAX_PARTICLE_COUNT; i++) {
      points.push(createParticle());
    }
  }
  seedFloatingParticles();

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    let mouseLinesDrawn = 0;

    // 更新粒子状态
    for (let i = points.length - 1; i >= 0; i--) {
      const p = points[i];
      p.vx += (Math.random() - 0.5) * DRIFT_NOISE;
      p.vy += (Math.random() - 0.5) * DRIFT_NOISE;
      p.vx *= 0.995;
      p.vy *= 0.995;
      p.x += p.vx;
      p.y += p.vy;
      p.life += 1;
      if (p.x < -EDGE_RESPAWN_MARGIN) p.x = canvas.width + EDGE_RESPAWN_MARGIN;
      if (p.x > canvas.width + EDGE_RESPAWN_MARGIN) p.x = -EDGE_RESPAWN_MARGIN;
      if (p.y < -EDGE_RESPAWN_MARGIN) p.y = canvas.height + EDGE_RESPAWN_MARGIN;
      if (p.y > canvas.height + EDGE_RESPAWN_MARGIN) p.y = -EDGE_RESPAWN_MARGIN;
      if (p.life > p.maxLife) recycleParticle(p, Math.random() * canvas.width, Math.random() * canvas.height);
    }

    // 绘制粒子
    for (const p of points) {
      const lifeFactor = 1 - p.life / p.maxLife;
      const alpha = Math.max(0, lifeFactor);
      ctx.beginPath();
      ctx.fillStyle = colorWithAlpha(COLOR_BASES.node, 0.55 * (0.7 + 0.3 * alpha));
      if (enableGlow) {
        ctx.shadowColor = colorWithAlpha(COLOR_BASES.glow, 0.35);
        ctx.shadowBlur = 12;
      } else {
        ctx.shadowBlur = 0;
      }
      ctx.arc(p.x, p.y, PARTICLE_RADIUS, 0, Math.PI * 2);
      ctx.fill();
    }

    // 绘制连线
    for (let i = 0; i < points.length; i++) {
      let connections = 0;
      for (let j = i + 1; j < points.length; j++) {
        if (connections >= MAX_CONNECTIONS_PER_PARTICLE) break;
        const p1 = points[i];
        const p2 = points[j];
        const dx = p1.x - p2.x;
        const dy = p1.y - p2.y;
        const dist = Math.hypot(dx, dy);
        if (dist > MAX_PARTICLE_CONNECTION_DISTANCE) continue;

        const alpha = (1 - p1.life / p1.maxLife) * (1 - dist / MAX_PARTICLE_CONNECTION_DISTANCE);
        if (alpha <= 0) continue;

        ctx.beginPath();
        ctx.moveTo(p1.x, p1.y);
        ctx.lineTo(p2.x, p2.y);
        ctx.strokeStyle = colorWithAlpha(COLOR_BASES.lineNear, 0.55 * alpha);
        ctx.lineWidth = PARTICLE_LINE_WIDTH;
        if (enableGlow) {
          ctx.shadowColor = colorWithAlpha(COLOR_BASES.glow, 0.35);
          ctx.shadowBlur = 20;
        } else {
          ctx.shadowBlur = 0;
        }
        ctx.stroke();
        connections += 1;
      }

      // 与鼠标的连线
      if (mouse.active) {
        const p = points[i];
        const dx = p.x - mouse.x;
        const dy = p.y - mouse.y;
        const dist = Math.hypot(dx, dy);
        if (dist < MAX_MOUSE_CONNECTION_DISTANCE && mouseLinesDrawn < MAX_MOUSE_LINES) {
          const alpha = (1 - p.life / p.maxLife) * (1 - dist / MAX_MOUSE_CONNECTION_DISTANCE);
          ctx.beginPath();
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(mouse.x, mouse.y);
          ctx.strokeStyle = colorWithAlpha(COLOR_BASES.lineMouse, 0.4 * alpha);
          ctx.lineWidth = MOUSE_LINE_WIDTH;
          if (enableGlow) {
            ctx.shadowColor = colorWithAlpha(COLOR_BASES.glow, 0.35);
            ctx.shadowBlur = 18;
          } else {
            ctx.shadowBlur = 0;
          }
          ctx.stroke();
          mouseLinesDrawn += 1;
          // 轻微吸附，带出柔和连线效果
          p.vx += (mouse.x - p.x) * 0.0008;
          p.vy += (mouse.y - p.y) * 0.0008;
        }
      }
    }

    requestAnimationFrame(draw);
  }

  window.addEventListener("mousemove", (event) => {
    mouse.x = event.clientX;
    mouse.y = event.clientY;
    mouse.active = true;
    const now = performance.now();
    if (now - lastRelocateAt > MOUSE_RELOCATE_THROTTLE_MS && points.length) {
      const idx = Math.floor(Math.random() * Math.min(points.length, 14));
      recycleParticle(
        points[idx],
        mouse.x + (Math.random() - 0.5) * PARTICLE_SPAWN_SPREAD,
        mouse.y + (Math.random() - 0.5) * PARTICLE_SPAWN_SPREAD
      );
      lastRelocateAt = now;
    }
  });

  window.addEventListener("mouseleave", () => {
    mouse.active = false;
  });

  draw();
});
