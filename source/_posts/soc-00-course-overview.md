---
title: 片上系统接口与模块设计：课程资料整理
date: 2026-08-15 22:30:00
updated: 2026-08-22 12:00:00
description: 基于 MicroBlaze 与 Nexys 4 DDR 的 SoC 实验课程整理，涵盖 Hello World、UART、IIC、SPI 和片上强化学习大作业。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - SoC
  - FPGA
  - MicroBlaze
  - Vivado
  - AXI4-Lite
cover: /img/post-2.svg
top_img: /img/post-2.svg
---

<span id="soc-course-top"></span>

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

<div class="soc-chapter-nav">
  <a href="#hello-world"><span>01</span>Hello World</a>
  <a href="#uart"><span>02</span>UART</a>
  <a href="#iic"><span>03</span>IIC</a>
  <a href="#spi"><span>04</span>SPI</a>
  <a href="#capstone"><span>05</span>大作业</a>
</div>

## 资料说明

各章节采用相同的组织方式：实验目标和任务要求、对应实验 PPT、必要的 Block Design/XDC/RTL/C 程序，以及实验视频和报告的公开状态。

公开源码经过精简，不包含 `.cache`、`.gen`、`.runs`、`.sim`、`.Xil`、BSP、Vitis platform export 等自动生成内容。完整工程应在 Vivado 2022.2 中根据 Block Design、约束和源码重新生成。

四个实验的原始录屏文件均较大，待进一步压缩或迁移到合适的视频托管位置后再补充，当前页面不会放置失效链接。

---

<span id="hello-world" class="soc-section-anchor"></span>

## 01 · Hello World：MicroBlaze 最小系统

本实验是整门课程的起点：在 FPGA 内搭建 MicroBlaze 软核处理器、片上 BRAM、时钟复位和 AXI UARTLite，并在 Vitis 中运行 Hello World 程序。

### 实验目标

- 熟悉 Vivado Block Design 的基本操作；
- 建立可运行 C 程序的 MicroBlaze 最小系统；
- 完成综合、实现、生成 bitstream 与导出 XSA；
- 在 Vitis 中建立 Platform Project 和 Application Project；
- 通过 USB-UART 在串口终端观察程序输出。

### 硬件结构

系统主要包含以下 IP：

- `microblaze_0`：软核处理器；
- AXI BRAM Controller 与 Block Memory Generator：程序和数据存储；
- AXI UARTLite：串口输出；
- Clocking Wizard 与 Processor System Reset：时钟和复位；
- AXI SmartConnect：连接处理器与外设。

约束文件绑定 100 MHz 系统时钟、复位和 USB-UART 收发管脚，顶层端口名称必须与 Block Design wrapper 保持一致。

### 基本流程

1. 在 Vivado 2022.2 中创建工程和 Block Design；
2. 加入 MicroBlaze、BRAM、UARTLite 与时钟 IP；
3. 使用 Block Automation 和 Connection Automation 完成连接；
4. 生成 HDL Wrapper、添加 XDC 并生成 bitstream；
5. 导出包含 bitstream 的 XSA；
6. 在 Vitis 2022.2 中创建平台和 Hello World 应用；
7. 烧录并运行，在串口终端观察输出。

### 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/hello-world/helloworld-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/hello-world/code" target="_blank" rel="noopener">浏览必要源码</a>
</div>

源码目录包含：

- `hardware/design_1.bd`：MicroBlaze Block Design；
- `hardware/nexys4ddr.xdc`：时钟、复位和串口约束；
- `software/helloworld.c`：Vitis 应用入口。

> 当前归档的 `design_1.bd` 最后由 Vivado 2025.2.1 保存，仅建议用作结构参考。若使用课程推荐的 Vivado 2022.2，请按照本章 PPT 重新创建 Block Design；其余 UART、IIC、SPI 归档均为 2022.2 工程文件。

### 实验视频与报告

<div class="resource-note">原始 Hello World 录屏约 158 MB，待压缩或迁移外部托管后补充。实验报告尚未完成脱敏，暂不提供下载。</div>

<p class="soc-back-to-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="uart" class="soc-section-anchor"></span>

## 02 · UART：自定义 AXI UART 与 GPIO 扩展

这一章从“使用现成 IP”转向“设计并封装自定义 AXI IP”。实验 A 完成 UART 收发模块，实验 B 在此基础上加入 AXI GPIO，实现 PC、MicroBlaze 与 FPGA 板级外设之间的数据交互。

### 实验 A：自定义 UART IP

UART IP 由 AXI4-Lite 从接口、接收器、发送器、波特率时钟和 FIFO 组成。软件使用四个 32 位寄存器访问外设：

| 偏移 | 功能 |
|---|---|
| `0x00` | RX FIFO |
| `0x04` | TX FIFO |
| `0x08` | 状态寄存器 |
| `0x0C` | 控制寄存器 / 波特率分频值 |

关键 RTL 包括 `uart_rx.v`、`uart_tx.v`、`clk_gen.v`、AXI wrapper 和 FIFO Generator 配置。完成打包后，将自定义 IP 加入 MicroBlaze 系统，并在 Vitis 中通过内存映射寄存器进行收发测试。

![实验 3A 任务要求](/downloads/soc-interface-design/uart/tasks/lab3a.jpg)

### 实验 B：AXI GPIO 与显示扩展

实验 B 继续设计 AXI GPIO，完成以下功能测试：

- UART 接收 PC 字符并映射到 LED；
- UART 数据显示到七段数码管；
- 读取拨码开关并通过 UART 返回 PC；
- 扩展多字符显示和时间显示模式。

![实验 3B 任务要求（1）](/downloads/soc-interface-design/uart/tasks/lab3b-1.jpg)

![实验 3B 任务要求（2）](/downloads/soc-interface-design/uart/tasks/lab3b-2.jpg)

### 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/uart/uart-custom-ip-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/uart/code" target="_blank" rel="noopener">浏览 UART / GPIO 源码</a>
</div>

公开代码包括 UART 与 AXI GPIO 的 RTL、FIFO `.xci`、IP 打包描述、两套 Block Design/XDC，以及六个 Vitis 功能测试程序。Vivado 自动生成的综合网表和 Vitis BSP 未收录。

> 使用 Vivado 2022.2 重新打包 IP 时，应检查 FIFO Generator 是否需要升级，并确认驱动目录中的 Makefile 能正确收集 `.c` 和 `.h` 文件。

### 实验视频与报告

<div class="resource-note">原始 UART 实验录屏约 202 MB，待压缩或迁移外部托管后补充。实验报告尚未完成脱敏，暂不提供下载。</div>

<p class="soc-back-to-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="iic" class="soc-section-anchor"></span>

## 03 · IIC：AXI IIC 与自定义 IIC IP

本章围绕 IIC（I²C）串行总线展开。实验 A 使用现成 AXI IIC IP 建立温度传感器读取通路；实验 B 将时钟生成、总线核心、控制器与 FIFO 封装成自定义 AXI4-Lite IP。

### 实验 A：AXI IIC 温度读取

MicroBlaze 通过 AXI IIC 的寄存器和 FIFO 发出 START、器件地址、寄存器地址、重复 START 与读命令。示例软件访问地址为 `0x4B` 的温度传感器，读取两个字节并换算温度。

![实验 6A 任务要求](/downloads/soc-interface-design/iic/tasks/lab6a.jpg)

### 实验 B：自定义 IIC IP

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

### 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/iic/iic-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/iic/code" target="_blank" rel="noopener">浏览 IIC 源码</a>
</div>

源码目录同时保留实验 A/B 的 Block Design、XDC、Vitis 应用，以及自定义控制器的两组定向 testbench。工程缓存、仿真输出和已废弃的旧时钟模块未收录。

### 实验视频与报告

<div class="resource-note">原始 IIC 实验录屏约 118 MB，待压缩或迁移外部托管后补充。实验报告尚未完成脱敏，暂不提供下载。</div>

<p class="soc-back-to-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="spi" class="soc-section-anchor"></span>

## 04 · SPI：AXI Quad SPI 与自定义 SPI IP

本章使用 Nexys 4 DDR 板载 ADXL362 加速度计验证 SPI 主机。实验 A 使用 Xilinx AXI Quad SPI；实验 B 用 Verilog 实现 SPI 时钟、控制器、移位核心和 FIFO，并封装为 AXI4-Lite 外设。

### 实验 A：AXI Quad SPI

Vitis 程序直接访问 AXI Quad SPI 寄存器，完成片选、发送和接收操作：

- 读取 `0x00`、`0x01`、`0x02` 器件 ID；
- 配置 ADXL362 测量寄存器；
- 循环读取 `0x08`、`0x09`、`0x0A` 的 X/Y/Z 数据。

<div class="task-image-rotated-frame">
  <img src="/downloads/soc-interface-design/spi/tasks/lab7a.jpg" alt="实验 7A 任务要求">
</div>

### 实验 B：自定义 SPI IP

自定义 SPI IP 由 `spi_clkgen.v`、`spi_core.v`、`spi_ctrl.v`、`spi_fifo.v`、去抖模块和 AXI wrapper 组成。软件通过内存映射寄存器控制片选、写入发送数据并读取返回值。

公开源码同时提供各子模块 testbench 和 `25AA010A.v` 行为模型，便于先独立验证时钟、FIFO、核心与控制状态机，再接入 MicroBlaze 系统。

<div class="task-image-rotated-frame">
  <img src="/downloads/soc-interface-design/spi/tasks/lab7b.jpg" alt="实验 7B 任务要求">
</div>

### 实验资料

<div class="pdf-actions">
  <a class="pdf-button" href="/downloads/soc-interface-design/spi/spi-lab.pptx" download>下载实验 PPT</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/spi/code" target="_blank" rel="noopener">浏览 SPI 源码</a>
</div>

### 实验视频与报告

<div class="resource-note">SPI 原始录屏约 71 MB，后续将压缩或迁移到视频托管位置后补充。实验报告尚未完成脱敏，暂不提供下载。</div>

<p class="soc-back-to-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="capstone" class="soc-section-anchor"></span>

## 05 · 大作业：片上强化学习 Flappy Bird

课程大作业将前面几章的 AXI、MicroBlaze 和外设设计经验组合起来，在 Nexys 4 DDR 上实现能够自主学习 Flappy Bird 的片上强化学习系统。

### 项目概览

强化学习闭环主要由 RTL 完成：

- Flappy Bird 物理、碰撞与奖励环境；
- 状态离散化和 ε-greedy 动作选择；
- Q 表 BRAM；
- Q16.16 定点 TD 更新；
- LCD 游戏画面与 Q 表热力图实时渲染。

MicroBlaze 负责配置超参数、读取统计并输出串口信息，不参与动作决策或 Q 值更新。七段数码管显示训练轮数，LED 显示历史最高分，ILI9806G LCD 同屏展示游戏画面、统计信息和价值分布。

### 开源仓库

完整 RTL、仿真、软件、构建脚本、约束、验证证据和演示视频统一维护在团队开源仓库中，本博客不再复制一套工程文件。

<div class="pdf-actions">
  <a class="pdf-button" href="https://github.com/BixingWu/FlappyBird_on_Chip" target="_blank" rel="noopener">访问 FlappyBird_on_Chip</a>
  <a class="pdf-button pdf-button-download" href="https://github.com/BixingWu/FlappyBird_on_Chip/blob/main/README.md" target="_blank" rel="noopener">查看复现指南</a>
</div>

项目使用 Vivado 2022.2、Vitis / XSCT 2022.2，目标开发板仍为 Nexys 4 DDR。构建时必须将 MicroBlaze ELF 合并进最终 bitstream，否则片上 BRAM 中没有正确的处理器程序，系统可能出现串口无输出或训练未启动的现象。

### 实验报告

个人实验报告尚未完成脱敏，本页暂不提供下载。项目的技术细节、验证结果与团队成果以开源仓库为准。

<p class="soc-back-to-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>
