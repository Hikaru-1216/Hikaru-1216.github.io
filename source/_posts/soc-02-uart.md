---
title: SoC 实验 2：自定义 AXI UART 与 GPIO 扩展
date: 2026-08-15 22:32:00
updated: 2026-08-15 22:32:00
description: 将 UART 收发、FIFO 和波特率生成逻辑封装为 AXI4-Lite IP，并进一步通过 AXI GPIO 控制 LED、开关和七段数码管。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - UART
  - AXI4-Lite
  - GPIO
  - Verilog
cover: /img/post-2.svg
top_img: /img/post-2.svg
---

这一章从“使用现成 IP”转向“设计并封装自定义 AXI IP”。实验 A 完成 UART 收发模块，实验 B 在此基础上加入 AXI GPIO，实现 PC、MicroBlaze 与 FPGA 板级外设之间的数据交互。

## 实验 A：自定义 UART IP

UART IP 由 AXI4-Lite 从接口、接收器、发送器、波特率时钟和 FIFO 组成。软件使用四个 32 位寄存器访问外设：

| 偏移 | 功能 |
|---|---|
| `0x00` | RX FIFO |
| `0x04` | TX FIFO |
| `0x08` | 状态寄存器 |
| `0x0C` | 控制寄存器 / 波特率分频值 |

关键 RTL 包括 `uart_rx.v`、`uart_tx.v`、`clk_gen.v`、AXI wrapper 和 FIFO Generator 配置。完成打包后，将自定义 IP 加入 MicroBlaze 系统，并在 Vitis 中通过内存映射寄存器进行收发测试。

![实验 3A 任务要求](/downloads/soc-interface-design/uart/tasks/lab3a.jpg)

## 实验 B：AXI GPIO 与显示扩展

实验 B 继续设计 AXI GPIO，完成以下功能测试：

- UART 接收 PC 字符并映射到 LED；
- UART 数据显示到七段数码管；
- 读取拨码开关并通过 UART 返回 PC；
- 扩展多字符显示和时间显示模式。

![实验 3B 任务要求（1）](/downloads/soc-interface-design/uart/tasks/lab3b-1.jpg)

![实验 3B 任务要求（2）](/downloads/soc-interface-design/uart/tasks/lab3b-2.jpg)

## 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/uart/uart-custom-ip-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/uart/code" target="_blank" rel="noopener">浏览 UART / GPIO 源码</a>
</div>

公开代码包括 UART 与 AXI GPIO 的 RTL、FIFO `.xci`、IP 打包描述、两套 Block Design/XDC，以及六个 Vitis 功能测试程序。Vivado 自动生成的综合网表和 Vitis BSP 未收录。

> 使用 Vivado 2022.2 重新打包 IP 时，应检查 FIFO Generator 是否需要升级，并确认驱动目录中的 Makefile 能正确收集 `.c` 和 `.h` 文件。

## 实验视频

<div class="resource-note">原始 UART 实验录屏约 202 MB，超过普通 Git 单文件限制。待压缩或迁移外部托管后补充。</div>

## 实验报告

实验报告尚未完成脱敏，本页暂不提供下载。

{% post_link soc-01-hello-world '← 上一章：Hello World' %} · {% post_link soc-03-iic '下一章：IIC →' %}
