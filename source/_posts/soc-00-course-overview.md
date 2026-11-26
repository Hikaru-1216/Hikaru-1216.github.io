---
title: 《片上系统接口与模块设计》——2025-2026春夏
date: 2026-08-15 22:30:00

description: 浙江大学 微电子科学与工程专业 大三年级专业选修课：基于 MicroBlaze 与 Nexys 4 DDR 的 SoC 实验课程，涵盖 Hello World、UART、IIC、SPI 和片上强化学习大作业。
categories:
  - 课程资料
  - 片上系统接口与模块设计
tags:
  - SoC
  - FPGA
  - MicroBlaze
  - Vivado
  - AXI4-Lite
cover: /img/soc-cover.jpg
top_img: /img/soc-cover.jpg
---

<link rel="stylesheet" href="/css/soc-course.css">
<span id="soc-course-top" class="soc-anchor"></span>

<div class="soc-hero">
  <p> 浙江大学 微电子科学与工程专业 大三年级专业选修课《片上系统接口与模块设计》课程的实验资料。课程从认识 MicroBlaze 系统开始，逐步完成 Hello World 实验、自定义 UART、IIC（I²C）和 SPI 外设接口设计，最后设计课程大作业。</p>
  <ul class="soc-badges">
    <li><b>EDA工具</b>Vivado / Vitis 2022.2</li>
    <li><b>开发板</b>Digilent Nexys 4 DDR</li>
    <li><b>器件</b>xc7a100tcsg324-1</li>
    <li><b>处理器</b>MicroBlaze</li>
    <li><b>总线</b>AXI4-Lite</li>
  </ul>
  <div class="soc-stats">
    <div><strong>5</strong><span>个章节</span></div>
    <div><strong>3</strong><span>份实验报告</span></div>
    <div><strong>4</strong><span>套自定义 AXI IP</span></div>
    <div><strong>1</strong><span>个开源大作业</span></div>
  </div>
  <p class="soc-hint">实验 PPT 与任务页来自课程教学材料，仅用于课程学习与技术交流。教师上传在学在浙大的视频中使用的是Vivado 2022.2 版本，建议使用完全相同的版本，注意在安装时需要顺带安装 Vitis 。</p>
  <p class="soc-hint">Vivado 2025.1 已经移除了旧版 Vitis Classic IDE，而且新版不仅界面不同，还改变了 BSP 生成机制和部分外设驱动的初始化方式,因此不建议安装最新版。</p>
</div>

## 章节导航

<div class="soc-chapters">
  <a class="soc-chapter" href="#hello-world">
    <span class="soc-chapter-no">01</span>
    <span class="soc-chapter-title">Hello World</span>
    <span class="soc-chapter-sub">认识 MicroBlaze 最小系统与 Vitis 入门</span>
    <span class="soc-chips"><span class="soc-chip ok">PPT</span><span class="soc-chip ok">源码</span><span class="soc-chip ok">视频</span></span>
  </a>
  <a class="soc-chapter" href="#uart">
    <span class="soc-chapter-no">02</span>
    <span class="soc-chapter-title">UART</span>
    <span class="soc-chapter-sub">自定义 AXI UART IP 设计与 GPIO 扩展</span>
    <span class="soc-chips"><span class="soc-chip ok">PPT</span><span class="soc-chip ok">源码</span><span class="soc-chip ok">视频</span><span class="soc-chip ok">报告</span></span>
  </a>
  <a class="soc-chapter" href="#iic">
    <span class="soc-chapter-no">03</span>
    <span class="soc-chapter-title">IIC</span>
    <span class="soc-chapter-sub">AXI IIC 温度读取与自定义 IIC IP 设计</span>
    <span class="soc-chips"><span class="soc-chip ok">PPT</span><span class="soc-chip ok">源码</span><span class="soc-chip ok">视频</span><span class="soc-chip ok">报告</span></span>
  </a>
  <a class="soc-chapter" href="#spi">
    <span class="soc-chapter-no">04</span>
    <span class="soc-chapter-title">SPI</span>
    <span class="soc-chapter-sub">AXI Quad SPI 与自定义 SPI IP 设计</span>
    <span class="soc-chips"><span class="soc-chip ok">PPT</span><span class="soc-chip ok">源码</span><span class="soc-chip ok">视频</span><span class="soc-chip ok">报告</span></span>
  </a>
  <a class="soc-chapter" href="#capstone">
    <span class="soc-chapter-no">05</span>
    <span class="soc-chapter-title">大作业</span>
    <span class="soc-chapter-sub">片上强化学习 Flappy Bird</span>
    <span class="soc-chips"><span class="soc-chip link">开源仓库</span><span class="soc-chip ok">报告</span></span>
  </a>
</div>

## 资料说明

每章都按同样的结构组织：实验目标和任务要求、对应实验 PPT、必要的 Block Design / XDC / RTL / C 程序，以及实验视频和参考实验报告。

公开源码经过AI精简，不包含 `.cache`、`.gen`、`.runs`、`.sim`、`.Xil`、BSP、Vitis platform export 等自动生成内容。完整工程应在 Vivado 2022.2 中根据 Block Design、约束和源码重新生成。实验录屏文件较大，统一托管在仓库的 [GitHub Releases](https://github.com/Hikaru-1216/Hikaru-1216.github.io/releases/tag/soc-videos) 中，点击各章“观看视频”即可在浏览器中播放或下载。

---

<span id="hello-world" class="soc-anchor"></span>

## 01 · Hello World 

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

<div class="soc-resources">
  <div class="soc-res">
    <div class="soc-res-head">实验 PPT<span class="soc-chip ok">可下载</span></div>
    <p>Block Design 搭建与 Vitis 工程创建步骤。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/hello-world/helloworld-lab.pptx" download>下载 PPT</a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">源码<span class="soc-chip ok">可浏览</span></div>
    <p>Block Design、XDC 约束与 Hello World 入口程序。</p>
    <a class="soc-btn alt" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/hello-world/code" target="_blank" rel="noopener"><span>浏览源码</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验视频<span class="soc-chip ok">可观看</span></div>
    <p>Hello World 上板演示录屏，约 158 MB。托管在 GitHub Releases。</p>
    <a class="soc-btn" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/releases/download/soc-videos/helloworld.mp4" target="_blank" rel="noopener"><span>观看视频</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验报告<span class="soc-chip none">无</span></div>
    <p>本实验为入门练习，不需要提交实验报告。</p>
  </div>
</div>

源码目录包含：

- `hardware/design_1.bd`：MicroBlaze Block Design；
- `hardware/nexys4ddr.xdc`：时钟、复位和串口约束；
- `software/helloworld.c`：Vitis 应用入口。

> 当前整理的 `design_1.bd` 最后由 Vivado 2025.2.1 保存，因为一开始没安装2022.2版本，仅建议用作结构参考。若使用课程推荐的 Vivado 2022.2，请按照本章 PPT 重新创建 Block Design；其余 UART、IIC、SPI 归档均为 2022.2 工程文件。



<p class="soc-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="uart" class="soc-anchor"></span>

## 02 · UART

这一章从【使用现成 IP】转向【设计并封装自定义 AXI IP】。实验 A 完成 UART 收发模块，实验 B 在此基础上加入 AXI GPIO，实现 PC、MicroBlaze 与 FPGA 板级外设之间的数据交互。

### 实验 A：自定义 UART IP

UART IP 由 AXI4-Lite 从接口、接收器、发送器、波特率时钟和 FIFO 组成。软件使用四个 32 位寄存器访问外设：

| 偏移 | 功能 |
|---|---|
| `0x00` | RX FIFO |
| `0x04` | TX FIFO |
| `0x08` | 状态寄存器 |
| `0x0C` | 控制寄存器 / 波特率分频值 |

关键 RTL 包括 `uart_rx.v`、`uart_tx.v`、`clk_gen.v`、AXI wrapper 和 FIFO Generator 配置。完成打包后，将自定义 IP 加入 MicroBlaze 系统，并在 Vitis 中通过内存映射寄存器进行收发测试。

<div class="soc-figures">
  <figure>
    <a href="/downloads/soc-interface-design/uart/tasks/lab3a.jpg" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/uart/tasks/lab3a.jpg" alt="实验 3A 任务要求" loading="lazy"></a>
    <figcaption>实验 3A 任务要求</figcaption>
  </figure>
</div>

### 实验 B：AXI GPIO 与显示扩展

实验 B 继续设计 AXI GPIO，完成以下功能测试：

- UART 接收 PC 字符并映射到 LED；
- UART 数据显示到七段数码管；
- 读取拨码开关并通过 UART 返回 PC；
- 扩展多字符显示和时间显示模式。

<div class="soc-figures">
  <figure>
    <a href="/downloads/soc-interface-design/uart/tasks/lab3b-1.jpg" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/uart/tasks/lab3b-1.jpg" alt="实验 3B 任务要求（1）" loading="lazy"></a>
    <figcaption>实验 3B 任务要求（1）</figcaption>
  </figure>
  <figure>
    <a href="/downloads/soc-interface-design/uart/tasks/lab3b-2.jpg" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/uart/tasks/lab3b-2.jpg" alt="实验 3B 任务要求（2）" loading="lazy"></a>
    <figcaption>实验 3B 任务要求（2）</figcaption>
  </figure>
</div>

### 实验资料

<div class="soc-resources">
  <div class="soc-res">
    <div class="soc-res-head">实验 PPT<span class="soc-chip ok">可下载</span></div>
    <p>自定义 UART IP 设计、封装与 GPIO 扩展实验。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/uart/uart-custom-ip-lab.pptx" download>下载 PPT</a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">源码<span class="soc-chip ok">可浏览</span></div>
    <p>UART / AXI GPIO RTL、FIFO 配置、两套 BD/XDC 与六个测试程序。</p>
    <a class="soc-btn alt" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/uart/code" target="_blank" rel="noopener"><span>浏览源码</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验视频<span class="soc-chip ok">可观看</span></div>
    <p>UART / GPIO 实验上板演示录屏，约 202 MB。托管在 GitHub Releases。</p>
    <a class="soc-btn" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/releases/download/soc-videos/uart.IP.mp4" target="_blank" rel="noopener"><span>观看视频</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验报告<span class="soc-chip ok">可下载</span></div>
    <p>已脱敏，含 Module A/B 设计步骤、调试问题与上板结果，共 12 页。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/uart/uart-report.pdf" target="_blank" rel="noopener">查看报告 PDF</a>
  </div>
</div>

公开代码包括 UART 与 AXI GPIO 的 RTL、FIFO `.xci`、IP 打包描述、两套 Block Design/XDC，以及六个 Vitis 功能测试程序。Vivado 自动生成的综合网表和 Vitis BSP 未收录。

> 使用 Vivado 2022.2 重新打包 IP 时，应检查 FIFO Generator 是否需要升级，并确认驱动目录中的 Makefile 能正确收集 `.c` 和 `.h` 文件。



<p class="soc-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="iic" class="soc-anchor"></span>

## 03 · IIC

本章围绕 IIC（I²C）串行总线展开。实验 A 使用现成 AXI IIC IP 建立温度传感器读取通路；实验 B 将时钟生成、总线核心、控制器与 FIFO 封装成自定义 AXI4-Lite IP。

### 实验 A：AXI IIC 温度读取

MicroBlaze 通过 AXI IIC 的寄存器和 FIFO 发出 START、器件地址、寄存器地址、重复 START 与读命令。示例软件访问地址为 `0x4B` 的温度传感器，读取两个字节并换算温度。

<div class="soc-figures">
  <figure>
    <a href="/downloads/soc-interface-design/iic/tasks/lab6a.jpg" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/iic/tasks/lab6a.jpg" alt="实验 6A 任务要求" loading="lazy"></a>
    <figcaption>实验 6A 任务要求</figcaption>
  </figure>
</div>

### 实验 B：自定义 IIC IP

自定义 IP 主要包含：

- `iic_clkgen.v`：生成总线工作节拍；
- `iic_core.v`：SCL/SDA 底层时序；
- `iic_ctrl.v`：命令解析与流程控制；
- `iic_fifo.v`：收发缓冲；
- `IIC_ZJU_SOC_v1_0*.v`：AXI4-Lite 接口与顶层封装。

本实验的系统时钟设置为 50 MHz。重新搭建工程时，RTL 中的寄存器地址、Vitis 软件偏移和 Vivado Address Editor 必须前后一致。

<div class="soc-figures wide">
  <figure>
    <a href="/downloads/soc-interface-design/iic/tasks/lab6b.jpg" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/iic/tasks/lab6b.jpg" alt="实验 6B 任务要求" loading="lazy"></a>
    <figcaption>实验 6B 任务要求</figcaption>
  </figure>
</div>

### 实验资料

<div class="soc-resources">
  <div class="soc-res">
    <div class="soc-res-head">实验 PPT<span class="soc-chip ok">可下载</span></div>
    <p>AXI IIC 使用方法与自定义 IIC IP 设计要求。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/iic/iic-lab.pptx" download>下载 PPT</a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">源码<span class="soc-chip ok">可浏览</span></div>
    <p>实验 A/B 的 BD、XDC、Vitis 应用与两组定向 testbench。</p>
    <a class="soc-btn alt" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/iic/code" target="_blank" rel="noopener"><span>浏览源码</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验视频<span class="soc-chip ok">可观看</span></div>
    <p>IIC 实验上板演示录屏，约 118 MB。托管在 GitHub Releases。</p>
    <a class="soc-btn" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/releases/download/soc-videos/iic.mp4" target="_blank" rel="noopener"><span>观看视频</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验报告<span class="soc-chip ok">可下载</span></div>
    <p>已脱敏，含 AXI IIC 与自定义 IIC IP 的设计、调试与温度测试，共 9 页。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/iic/iic-report.pdf" target="_blank" rel="noopener">查看报告 PDF</a>
  </div>
</div>

源码目录同时保留实验 A/B 的 Block Design、XDC、Vitis 应用，以及自定义控制器的两组定向 testbench。工程缓存、仿真输出和已废弃的旧时钟模块未收录。



<p class="soc-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="spi" class="soc-anchor"></span>

## 04 · SPI

本章使用 Nexys 4 DDR 板载 ADXL362 加速度计验证 SPI 主机。实验 A 使用 Xilinx AXI Quad SPI；实验 B 用 Verilog 实现 SPI 时钟、控制器、移位核心和 FIFO，并封装为 AXI4-Lite 外设。

### 实验 A：AXI Quad SPI

Vitis 程序直接访问 AXI Quad SPI 寄存器，完成片选、发送和接收操作：

- 读取 `0x00`、`0x01`、`0x02` 器件 ID；
- 配置 ADXL362 测量寄存器；
- 循环读取 `0x08`、`0x09`、`0x0A` 的 X/Y/Z 数据。

<div class="soc-figures wide">
  <figure>
    <a href="/downloads/soc-interface-design/spi/tasks/lab7a.jpg" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/spi/tasks/lab7a.jpg" alt="实验 7A 任务要求" loading="lazy"></a>
    <figcaption>实验 7A 任务要求</figcaption>
  </figure>
</div>

### 实验 B：自定义 SPI IP

自定义 SPI IP 由 `spi_clkgen.v`、`spi_core.v`、`spi_ctrl.v`、`spi_fifo.v`、去抖模块和 AXI wrapper 组成。软件通过内存映射寄存器控制片选、写入发送数据并读取返回值。

公开源码同时提供各子模块 testbench 和 `25AA010A.v` 行为模型，便于先独立验证时钟、FIFO、核心与控制状态机，再接入 MicroBlaze 系统。

<div class="soc-figures wide">
  <figure>
    <a href="/downloads/soc-interface-design/spi/tasks/lab7b.jpg" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/spi/tasks/lab7b.jpg" alt="实验 7B 任务要求" loading="lazy"></a>
    <figcaption>实验 7B 任务要求</figcaption>
  </figure>
</div>

### 实验资料

<div class="soc-resources">
  <div class="soc-res">
    <div class="soc-res-head">实验 PPT<span class="soc-chip ok">可下载</span></div>
    <p>ADXL362 访问流程与自定义 SPI IP 设计要求。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/spi/spi-lab.pptx" download>下载 PPT</a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">源码<span class="soc-chip ok">可浏览</span></div>
    <p>SPI 子模块 RTL、各模块 testbench 与 25AA010A 行为模型。</p>
    <a class="soc-btn alt" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/tree/main/source/downloads/soc-interface-design/spi/code" target="_blank" rel="noopener"><span>浏览源码</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验视频<span class="soc-chip ok">可观看</span></div>
    <p>SPI 实验上板演示录屏，约 71 MB。托管在 GitHub Releases。</p>
    <a class="soc-btn" href="https://github.com/Hikaru-1216/Hikaru-1216.github.io/releases/download/soc-videos/spi_demo.mp4" target="_blank" rel="noopener"><span>观看视频</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验报告<span class="soc-chip ok">可下载</span></div>
    <p>已脱敏，含 AXI Quad SPI 与自定义 SPI IP 的设计、调试与 ADXL362 测试，共 9 页。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/spi/spi-report.pdf" target="_blank" rel="noopener">查看报告 PDF</a>
  </div>
</div>



<p class="soc-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>

---

<span id="capstone" class="soc-anchor"></span>

## 05 · 大作业：片上强化学习 Flappy Bird

课程大作业将前面几章的 AXI、MicroBlaze 和外设设计经验组合起来，在 Nexys 4 DDR 上实现能够自主学习 Flappy Bird 的片上强化学习系统。

<div class="soc-capstone">
  <figure>
    <a href="/downloads/soc-interface-design/capstone/lcd-frame.png" target="_blank" rel="noopener" title="查看原图"><img src="/downloads/soc-interface-design/capstone/lcd-frame.png" alt="优化后的 LCD 界面：游戏画面、训练统计与 Q 表热力图" loading="lazy"></a>
    <figcaption>优化后的 LCD 界面（训练第 3169 局）</figcaption>
  </figure>
  <div class="soc-stats">
    <div><strong>702</strong><span>单局最高分（上板训练 3000 局，根管子）</span></div>
    <div><strong>88.57</strong><span>上板第 3000 局时最近 100 局平均分</span></div>
    <div><strong>+0.489 ns</strong><span>时序余量 WNS</span></div>
    <div><strong>7.41%</strong><span>LUT 占用（BRAM 10%）</span></div>
  </div>
</div>

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

<div class="soc-resources">
  <div class="soc-res">
    <div class="soc-res-head">开源仓库<span class="soc-chip link">GitHub</span></div>
    <p>RTL、仿真、软件、构建脚本、约束与验证证据。</p>
    <a class="soc-btn" href="https://github.com/BixingWu/FlappyBird_on_Chip" target="_blank" rel="noopener"><span>访问仓库</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">复现指南<span class="soc-chip link">README</span></div>
    <p>环境准备、纯仿真验证、上板烧录与常见问题。</p>
    <a class="soc-btn alt" href="https://github.com/BixingWu/FlappyBird_on_Chip/blob/main/README.md" target="_blank" rel="noopener"><span>查看指南</span></a>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">演示视频<span class="soc-chip link">仓库内</span></div>
    <p>上板演示视频随开源仓库一起维护。</p>
  </div>
  <div class="soc-res">
    <div class="soc-res-head">实验报告<span class="soc-chip ok">可下载</span></div>
    <p>已脱敏，含原理、RTL 架构、LCD 渲染、验证与上板结果，共 33 页。</p>
    <a class="soc-btn" href="/downloads/soc-interface-design/capstone/capstone-report.pdf" target="_blank" rel="noopener">查看报告 PDF</a>
  </div>
</div>

项目使用 Vivado 2022.2、Vitis / XSCT 2022.2，目标开发板仍为 Nexys 4 DDR。构建时必须将 MicroBlaze ELF 合并进最终 bitstream，否则片上 BRAM 中没有正确的处理器程序，系统可能出现串口无输出或训练未启动的现象。

<p class="soc-top"><a href="#soc-course-top">↑ 返回章节导航</a></p>
