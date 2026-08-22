---
title: SoC 大作业：片上强化学习 Flappy Bird
date: 2026-08-15 22:35:00
updated: 2026-08-15 22:35:00
description: 在 Nexys 4 DDR 上实现片上 Q-learning Flappy Bird，并通过 LCD、LED 和七段数码管实时展示学习过程。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - Q-learning
  - Flappy Bird
  - FPGA
  - SystemVerilog
cover: /img/post-1.svg
top_img: /img/post-1.svg
---

课程大作业将前面几章的 AXI、MicroBlaze 和外设设计经验组合起来，在 Nexys 4 DDR 上实现能够自主学习 Flappy Bird 的片上强化学习系统。

## 项目概览

强化学习闭环主要由 RTL 完成：

- Flappy Bird 物理、碰撞与奖励环境；
- 状态离散化和 ε-greedy 动作选择；
- Q 表 BRAM；
- Q16.16 定点 TD 更新；
- LCD 游戏画面与 Q 表热力图实时渲染。

MicroBlaze 负责配置超参数、读取统计并输出串口信息，不参与动作决策或 Q 值更新。七段数码管显示训练轮数，LED 显示历史最高分，ILI9806G LCD 同屏展示游戏画面、统计信息和价值分布。

## 开源仓库

完整 RTL、仿真、软件、构建脚本、约束、验证证据和演示视频统一维护在团队开源仓库中，本博客不再复制一套工程文件。

<div class="pdf-actions">
  <a class="pdf-button" href="https://github.com/BixingWu/FlappyBird_on_Chip" target="_blank" rel="noopener">访问 FlappyBird_on_Chip</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/BixingWu/FlappyBird_on_Chip/blob/main/README.md" target="_blank" rel="noopener">查看复现指南</a>
</div>

项目使用 Vivado 2022.2、Vitis / XSCT 2022.2，目标开发板仍为 Nexys 4 DDR。构建时必须将 MicroBlaze ELF 合并进最终 bitstream，否则片上 BRAM 中没有正确的处理器程序，系统可能出现串口无输出或训练未启动的现象。

## 实验报告

个人实验报告尚未完成脱敏，本页暂不提供下载。项目的技术细节、验证结果与团队成果以开源仓库为准。

{% post_link soc-04-spi '← 上一章：SPI' %} · {% post_link soc-00-course-overview '返回课程索引' %}
