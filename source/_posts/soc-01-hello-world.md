---
title: SoC 实验 1：MicroBlaze Hello World
date: 2026-08-15 22:31:00
updated: 2026-08-15 22:31:00
description: 使用 Vivado 2022.2 和 Vitis 2022.2 在 Nexys 4 DDR 上搭建 MicroBlaze 最小系统并通过串口输出 Hello World。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - MicroBlaze
  - Hello World
  - Vivado
cover: /img/post-1.svg
top_img: /img/post-1.svg
---

本实验是整门课程的起点：在 FPGA 内搭建 MicroBlaze 软核处理器、片上 BRAM、时钟复位和 AXI UARTLite，并在 Vitis 中运行 Hello World 程序。

## 实验目标

- 熟悉 Vivado Block Design 的基本操作；
- 建立可运行 C 程序的 MicroBlaze 最小系统；
- 完成综合、实现、生成 bitstream 与导出 XSA；
- 在 Vitis 中建立 Platform Project 和 Application Project；
- 通过 USB-UART 在串口终端观察程序输出。

## 硬件结构

系统主要包含以下 IP：

- `microblaze_0`：软核处理器；
- AXI BRAM Controller 与 Block Memory Generator：程序和数据存储；
- AXI UARTLite：串口输出；
- Clocking Wizard 与 Processor System Reset：时钟和复位；
- AXI SmartConnect：连接处理器与外设。

约束文件绑定 100 MHz 系统时钟、复位和 USB-UART 收发管脚，顶层端口名称必须与 Block Design wrapper 保持一致。

## 基本流程

1. 在 Vivado 2022.2 中创建工程和 Block Design；
2. 加入 MicroBlaze、BRAM、UARTLite 与时钟 IP；
3. 使用 Block Automation 和 Connection Automation 完成连接；
4. 生成 HDL Wrapper、添加 XDC 并生成 bitstream；
5. 导出包含 bitstream 的 XSA；
6. 在 Vitis 2022.2 中创建平台和 Hello World 应用；
7. 烧录并运行，在串口终端观察输出。

## 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/hello-world/helloworld-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/hello-world/code" target="_blank" rel="noopener">浏览必要源码</a>
</div>

源码目录包含：

- `hardware/design_1.bd`：MicroBlaze Block Design；
- `hardware/nexys4ddr.xdc`：时钟、复位和串口约束；
- `software/helloworld.c`：Vitis 应用入口。

> 当前归档的 `design_1.bd` 最后由 Vivado 2025.2.1 保存，仅建议用作结构参考。若使用课程推荐的 Vivado 2022.2，请按照本章 PPT 重新创建 Block Design；其余 UART、IIC、SPI 归档均为 2022.2 工程文件。

## 实验视频

<div class="resource-note">原始 Hello World 录屏约 158 MB，超过普通 Git 单文件限制。待压缩或迁移外部托管后补充。</div>

## 实验报告

实验报告尚未完成脱敏，本页暂不提供下载。

{% post_link soc-00-course-overview '← 返回课程索引' %} · {% post_link soc-02-uart '下一章：UART →' %}
