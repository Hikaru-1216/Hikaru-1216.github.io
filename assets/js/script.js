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
  const points = [];
  const mouse = { x: window.innerWidth / 2, y: window.innerHeight / 2, active: false };
  const maxPoints = 120;

  function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resizeCanvas();
  window.addEventListener("resize", resizeCanvas);

  function spawnBurst(x, y) {
    for (let i = 0; i < 4; i++) {
      points.push({
        x: x + (Math.random() - 0.5) * 60,
        y: y + (Math.random() - 0.5) * 60,
        vx: (Math.random() - 0.5) * 0.9,
        vy: (Math.random() - 0.5) * 0.9,
        life: 0,
        maxLife: 90 + Math.random() * 40,
      });
    }

    // 控制数量，避免持续增长
    if (points.length > maxPoints) {
      points.splice(0, points.length - maxPoints);
    }
  }

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // 更新粒子状态
    for (let i = points.length - 1; i >= 0; i--) {
      const p = points[i];
      p.x += p.vx;
      p.y += p.vy;
      p.life += 1;
      if (p.life > p.maxLife) {
        points.splice(i, 1);
      }
    }

    // 绘制粒子
    for (const p of points) {
      const alpha = 1 - p.life / p.maxLife;
      ctx.beginPath();
      ctx.fillStyle = `rgba(132, 150, 255, ${0.6 * alpha})`;
      ctx.shadowColor = "rgba(132, 150, 255, 0.5)";
      ctx.shadowBlur = 12;
      ctx.arc(p.x, p.y, 1.6, 0, Math.PI * 2);
      ctx.fill();
    }

    // 绘制连线
    for (let i = 0; i < points.length; i++) {
      for (let j = i + 1; j < points.length; j++) {
        const p1 = points[i];
        const p2 = points[j];
        const dx = p1.x - p2.x;
        const dy = p1.y - p2.y;
        const dist = Math.hypot(dx, dy);
        if (dist > 140) continue;

        const alpha = (1 - p1.life / p1.maxLife) * (1 - dist / 140);
        if (alpha <= 0) continue;

        ctx.beginPath();
        ctx.moveTo(p1.x, p1.y);
        ctx.lineTo(p2.x, p2.y);
        ctx.strokeStyle = `rgba(146, 169, 255, ${0.55 * alpha})`;
        ctx.lineWidth = 1.4;
        ctx.shadowColor = "rgba(146, 169, 255, 0.45)";
        ctx.shadowBlur = 20;
        ctx.stroke();
      }

      // 与鼠标的连线
      if (mouse.active) {
        const p = points[i];
        const dx = p.x - mouse.x;
        const dy = p.y - mouse.y;
        const dist = Math.hypot(dx, dy);
        if (dist < 160) {
          const alpha = (1 - p.life / p.maxLife) * (1 - dist / 160);
          ctx.beginPath();
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(mouse.x, mouse.y);
          ctx.strokeStyle = `rgba(168, 186, 255, ${0.4 * alpha})`;
          ctx.lineWidth = 1.2;
          ctx.shadowColor = "rgba(168, 186, 255, 0.35)";
          ctx.shadowBlur = 18;
          ctx.stroke();
        }
      }
    }

    requestAnimationFrame(draw);
  }

  window.addEventListener("mousemove", (event) => {
    mouse.x = event.clientX;
    mouse.y = event.clientY;
    mouse.active = true;
    spawnBurst(event.clientX, event.clientY);
  });

  window.addEventListener("mouseleave", () => {
    mouse.active = false;
  });

  draw();
});
