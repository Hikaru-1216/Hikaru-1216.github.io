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

  const STAR_COUNT = prefersReduceMotion ? 140 : 240;
  const MIN_RADIUS = 1.1;
  const MAX_RADIUS = 3.3;
  // px / s
  const BASE_SPEED = prefersReduceMotion ? 8 : 12;
  const TWINKLE_SPEED_MIN = 0.0006;
  const TWINKLE_SPEED_RANGE = 0.0018;
  const MOUSE_INFLUENCE_RADIUS = prefersReduceMotion ? 180 : 240;
  const MOUSE_PULL = prefersReduceMotion ? 0.00035 : 0.0006;
  const SPEED_DAMPING = 0.992;
  const EDGE_MARGIN = 28;
  const MAX_FRAME_DELTA_MS = 32; // clamp huge frame gaps to avoid jumpy movement
  const MS_PER_FRAME_60FPS = 16.67;
  const TWINKLE_CYCLE_MS = 60000;
  const MOUSE_EFFECT_PERSIST_DURATION_MS = 420;
  const MIN_DISTANCE_THRESHOLD = 0.001;
  const MAX_PULSE = 1.4;
  const PULSE_INCREASE_RATE = 0.04;
  const PULSE_DECAY_RATE = 8;
  const TWINKLE_MIN = 0.6;
  const TWINKLE_AMPLITUDE = 0.4;
  const TWINKLE_RADIUS_FACTOR = 0.25;
  const PULSE_RADIUS_FACTOR = 0.45;
  const BASE_SHADOW_BLUR = 18;
  const PULSE_SHADOW_MULTIPLIER = 12;
  const TWINKLE_TABLE_SIZE = 1024;
  const TWINKLE_TABLE = Array.from({ length: TWINKLE_TABLE_SIZE }, (_, i) =>
    Math.sin((i / TWINKLE_TABLE_SIZE) * Math.PI * 2)
  );

  function twinkleSin(angle) {
    const normalized = angle % (Math.PI * 2);
    const wrapped = normalized < 0 ? normalized + Math.PI * 2 : normalized;
    const ratio = wrapped / (Math.PI * 2);
    const index = Math.floor(ratio * TWINKLE_TABLE_SIZE) % TWINKLE_TABLE_SIZE;
    return TWINKLE_TABLE[index];
  }

  const mouse = {
    x: window.innerWidth / 2,
    y: window.innerHeight / 2,
    active: false,
    // Negative to ensure lastMove is considered stale until the first move event
    lastMove: -MOUSE_EFFECT_PERSIST_DURATION_MS,
  };

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
    const delta = Math.min(MAX_FRAME_DELTA_MS, now - lastTime);
    lastTime = now;
    const deltaSec = delta / 1000;
    const dampingFactor = SPEED_DAMPING ** (delta / MS_PER_FRAME_60FPS);
    const timeForTwinkle = now % TWINKLE_CYCLE_MS;
    ctx.clearRect(0, 0, canvasWidth, canvasHeight);

    const mouseEngaged = mouse.active || now - mouse.lastMove < MOUSE_EFFECT_PERSIST_DURATION_MS;

    let haloWeight = 0;
    let haloWeightedX = 0;
    let haloWeightedY = 0;

    for (const star of stars) {
      // Gentle drift
      star.x += star.vx * deltaSec;
      star.y += star.vy * deltaSec;
      star.vx *= dampingFactor;
      star.vy *= dampingFactor;

      // Wrap around edges
      if (star.x < -EDGE_MARGIN) star.x = canvasWidth + EDGE_MARGIN;
      if (star.x > canvasWidth + EDGE_MARGIN) star.x = -EDGE_MARGIN;
      if (star.y < -EDGE_MARGIN) star.y = canvasHeight + EDGE_MARGIN;
      if (star.y > canvasHeight + EDGE_MARGIN) star.y = -EDGE_MARGIN;

      // Mouse attraction and local brightening
      let distToMouse = null;
      if (mouseEngaged) {
        const dx = mouse.x - star.x;
        const dy = mouse.y - star.y;
        distToMouse = Math.hypot(dx, dy);
        if (distToMouse < MOUSE_INFLUENCE_RADIUS && distToMouse > MIN_DISTANCE_THRESHOLD) {
          const influence = 1 - distToMouse / MOUSE_INFLUENCE_RADIUS;
          const pull = influence * MOUSE_PULL * deltaSec;
          star.vx += dx * pull;
          star.vy += dy * pull;
          star.pulse = Math.min(MAX_PULSE, star.pulse + influence * PULSE_INCREASE_RATE);
        }
      }

      // Pulse decay
      star.pulse = Math.max(0, star.pulse - PULSE_DECAY_RATE * deltaSec);

      // Twinkling
      const twinklePhase = star.twinkleOffset + timeForTwinkle * star.twinkleSpeed;
      const twinkle = TWINKLE_MIN + TWINKLE_AMPLITUDE * twinkleSin(twinklePhase);
      const brightness = Math.min(1, star.baseAlpha * twinkle + star.pulse);
      const radius = star.radius * (1 + twinkle * TWINKLE_RADIUS_FACTOR + star.pulse * PULSE_RADIUS_FACTOR);

      if (mouseEngaged && distToMouse !== null && distToMouse < MOUSE_INFLUENCE_RADIUS) {
        const contribution = brightness * (1 - distToMouse / MOUSE_INFLUENCE_RADIUS);
        haloWeight += contribution;
        haloWeightedX += star.x * contribution;
        haloWeightedY += star.y * contribution;
      }

      ctx.beginPath();
      ctx.fillStyle = `rgba(220, 233, 255, ${brightness})`;
      if (prefersReduceMotion) {
        ctx.shadowBlur = 0;
      } else {
        ctx.shadowColor = `rgba(149, 186, 255, ${0.35 + brightness * 0.35})`;
        ctx.shadowBlur = BASE_SHADOW_BLUR + star.pulse * PULSE_SHADOW_MULTIPLIER;
      }
      ctx.arc(star.x, star.y, radius, 0, Math.PI * 2);
      ctx.fill();
    }

    if (mouseEngaged && haloWeight > 0.08) {
      const haloCenterX = haloWeightedX / haloWeight;
      const haloCenterY = haloWeightedY / haloWeight;
      const haloStrength = Math.min(1, haloWeight / (STAR_COUNT * 0.15));
      const haloRadius = MOUSE_INFLUENCE_RADIUS * (0.6 + haloStrength * 0.55);
      ctx.save();
      const halo = ctx.createRadialGradient(haloCenterX, haloCenterY, 0, haloCenterX, haloCenterY, haloRadius);
      halo.addColorStop(0, `rgba(255, 241, 224, ${0.22 + haloStrength * 0.38})`);
      halo.addColorStop(0.42, `rgba(164, 199, 255, ${0.16 + haloStrength * 0.26})`);
      halo.addColorStop(1, "rgba(12, 20, 38, 0)");
      ctx.globalCompositeOperation = "screen";
      ctx.fillStyle = halo;
      ctx.fillRect(0, 0, canvasWidth, canvasHeight);
      ctx.restore();
    }

    requestAnimationFrame(draw);
  }

  requestAnimationFrame(draw);
});
