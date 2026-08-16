---
title: 片上系统接口与模块设计：课程资料索引
date: 2026-08-15 22:30:00
updated: 2026-08-15 22:30:00
description: 基于 MicroBlaze 与 Nexys 4 DDR 的 SoC 实验课程整理，涵盖 Hello World、UART、IIC、SPI 和片上强化学习大作业。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - SoC
  - FPGA
  - MicroBlaze
  - Vivado
cover: /img/post-2.svg
top_img: /img/post-2.svg
---

这里整理《片上系统接口与模块设计》课程中的实验资料与个人工程记录。课程从 MicroBlaze 最小系统开始，逐步完成 UART、IIC（I²C）和 SPI 外设接口，最后将软核处理器、自定义 AXI IP 与片上强化学习系统组合起来。

> 实验 PPT 与任务页来自课程教学材料，仅用于课程学习与技术交流。实验报告仍在脱敏处理中，本次暂不公开。

## 推荐环境

| 项目 | 版本或型号 |
|---|---|
| Vivado | 2022.2 |
| Vitis / XSCT | 2022.2 |
| FPGA 开发板 | Digilent Nexys 4 DDR |
| FPGA 器件 | Artix-7 XC7A100T（`xc7a100tcsg324-1`） |
| 处理器 | MicroBlaze |

建议使用完全相同的 2022.2 版本。自定义 IP、FIFO Generator、Block Design 和导出的 XSA 都可能受到 Vivado/Vitis 版本差异影响。

## 章节导航

1. {% post_link soc-01-hello-world 'Hello World：搭建 MicroBlaze 最小系统' %}
2. {% post_link soc-02-uart 'UART：自定义 AXI UART 与 GPIO 扩展' %}
3. {% post_link soc-03-iic 'IIC：AXI IIC 与自定义 IIC IP' %}
4. {% post_link soc-04-spi 'SPI：AXI Quad SPI 与自定义 SPI IP' %}
5. {% post_link soc-05-capstone '大作业：片上强化学习 Flappy Bird' %}

## 资料范围

各章节尽量采用相同的组织方式：

- 实验目标和任务要求；
- 对应实验 PPT；
- 必要的 Block Design、XDC、RTL 与 C 程序；
- 实验结果或演示视频；
- 复现时容易踩坑的版本、时钟和地址分配问题。

公开的源码目录经过精简，不包含 `.cache`、`.gen`、`.runs`、`.sim`、`.Xil`、BSP、Vitis platform export 等自动生成内容。完整工程应在 Vivado 2022.2 中根据 Block Design、约束和源码重新生成。

## 视频说明

四个实验的原始录屏文件均较大，待进一步压缩或迁移到合适的视频托管位置后再补充，当前页面不会放置失效链接。

{% post_link soc-01-hello-world '从 Hello World 开始 →' %}
