---
title: SoC 实验 4：AXI Quad SPI 与自定义 SPI IP
date: 2026-08-15 22:34:00
updated: 2026-08-15 22:34:00
description: 使用 AXI Quad SPI 与自定义 AXI SPI 控制器访问 ADXL362，读取器件 ID 和三轴加速度数据。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - SPI
  - AXI4-Lite
  - ADXL362
  - Verilog
cover: /img/post-2.svg
top_img: /img/post-2.svg
---

本章使用 Nexys 4 DDR 板载 ADXL362 加速度计验证 SPI 主机。实验 A 使用 Xilinx AXI Quad SPI；实验 B 用 Verilog 实现 SPI 时钟、控制器、移位核心和 FIFO，并封装为 AXI4-Lite 外设。

## 实验 A：AXI Quad SPI

Vitis 程序直接访问 AXI Quad SPI 寄存器，完成片选、发送和接收操作：

- 读取 `0x00`、`0x01`、`0x02` 器件 ID；
- 配置 ADXL362 测量寄存器；
- 循环读取 `0x08`、`0x09`、`0x0A` 的 X/Y/Z 数据。

<div class="task-image-rotated-frame">
  <img src="/downloads/soc-interface-design/spi/tasks/lab7a.jpg" alt="实验 7A 任务要求">
</div>

## 实验 B：自定义 SPI IP

自定义 SPI IP 由 `spi_clkgen.v`、`spi_core.v`、`spi_ctrl.v`、`spi_fifo.v`、去抖模块和 AXI wrapper 组成。软件通过内存映射寄存器控制片选、写入发送数据并读取返回值。

公开源码同时提供各子模块 testbench 和 `25AA010A.v` 行为模型，便于先独立验证时钟、FIFO、核心与控制状态机，再接入 MicroBlaze 系统。

<div class="task-image-rotated-frame">
  <img src="/downloads/soc-interface-design/spi/tasks/lab7b.jpg" alt="实验 7B 任务要求">
</div>

## 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/spi/spi-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/spi/code" target="_blank" rel="noopener">浏览 SPI 源码</a>
</div>

## 实验视频

<div class="resource-note">SPI 原始录屏约 71 MB，后续将压缩或迁移到视频托管位置后补充。本页暂不放置失效的播放链接。</div>

## 实验报告

实验报告尚未完成脱敏，本页暂不提供下载。

{% post_link soc-03-iic '← 上一章：IIC' %} · {% post_link soc-05-capstone '下一章：大作业 →' %}
