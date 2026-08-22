---
title: SoC 实验 3：AXI IIC 与自定义 IIC IP
date: 2026-08-15 22:33:00
updated: 2026-08-15 22:33:00
description: 使用 AXI IIC 和自定义 AXI4-Lite IIC 控制器读取温度传感器，并完成时钟、FIFO、控制器和软件驱动设计。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - IIC
  - I2C
  - AXI4-Lite
  - 传感器
cover: /img/post-1.svg
top_img: /img/post-1.svg
---

本章围绕 IIC（I²C）串行总线展开。实验 A 使用现成 AXI IIC IP 建立温度传感器读取通路；实验 B 将时钟生成、总线核心、控制器与 FIFO 封装成自定义 AXI4-Lite IP。

## 实验 A：AXI IIC 温度读取

MicroBlaze 通过 AXI IIC 的寄存器和 FIFO 发出 START、器件地址、寄存器地址、重复 START 与读命令。示例软件访问地址为 `0x4B` 的温度传感器，读取两个字节并换算温度。

![实验 6A 任务要求](/downloads/soc-interface-design/iic/tasks/lab6a.jpg)

## 实验 B：自定义 IIC IP

自定义 IP 主要包含：

- `iic_clkgen.v`：生成总线工作节拍；
- `iic_core.v`：SCL/SDA 底层时序；
- `iic_ctrl.v`：命令解析与流程控制；
- `iic_fifo.v`：收发缓冲；
- `IIC_ZJU_SOC_v1_0*.v`：AXI4-Lite 接口与顶层封装。

本实验的系统时钟设置为 50 MHz。重新搭建工程时，RTL 中的寄存器地址、Vitis 软件偏移和 Vivado Address Editor 必须前后一致。

<div class="task-image-rotated-frame">
  <img src="/downloads/soc-interface-design/iic/tasks/lab6b.jpg" alt="实验 6B 任务要求">
</div>

## 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/iic/iic-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/iic/code" target="_blank" rel="noopener">浏览 IIC 源码</a>
</div>

源码目录同时保留实验 A/B 的 Block Design、XDC、Vitis 应用，以及自定义控制器的两组定向 testbench。工程缓存、仿真输出和已废弃的旧时钟模块未收录。

## 实验视频

<div class="resource-note">原始 IIC 实验录屏约 118 MB，超过普通 Git 单文件限制。待压缩或迁移外部托管后补充。</div>

## 实验报告

实验报告尚未完成脱敏，本页暂不提供下载。

{% post_link soc-02-uart '← 上一章：UART' %} · {% post_link soc-04-spi '下一章：SPI →' %}
