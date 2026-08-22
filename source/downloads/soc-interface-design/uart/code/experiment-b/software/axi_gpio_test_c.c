#include "xparameters.h"
#include "xil_io.h"

#define AXI_GPIO_BASEADDR   XPAR_AXI_GPIO_0_S00_AXI_BASEADDR
#define UART_BASEADDR       XPAR_UART_0_S00_AXI_BASEADDR

// AXI_GPIO registers
#define GPIO_LED_REG        0x00U   // slv_reg0: LED
#define GPIO_SEG_REG        0x04U   // slv_reg1: seven-segment display

// UART registers
#define UART_RX_FIFO        0x00U
#define UART_TX_FIFO        0x04U
#define UART_STAT_REG       0x08U
#define UART_CTRL_REG       0x0CU

#define UART_RX_READY_MASK  0x01U

#define CPU_CLK             100000000U
#define UART_BAUD_RATE      9600U
#define UART_BAUD_DIV       (CPU_CLK / 2U / UART_BAUD_RATE)

int main(void)
{
    unsigned int stat;
    unsigned int data;

    // 设置 UART 波特率：100MHz / 2 / 9600 = 5208
    Xil_Out32(UART_BASEADDR + UART_CTRL_REG, UART_BAUD_DIV);

    // 初始状态：LED 全灭，七段码默认空白或 0，取决于你的硬件译码逻辑
    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_LED_REG, 0x00000000U);
    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_SEG_REG, 0x00000000U);

    while (1)
    {
        stat = Xil_In32(UART_BASEADDR + UART_STAT_REG);

        if (stat & UART_RX_READY_MASK)
        {
            // 读取 UART 接收到的字符 ASCII
            data = Xil_In32(UART_BASEADDR + UART_RX_FIFO) & 0xFFU;

            // slv_reg0：LED 显示 ASCII 二进制值
            Xil_Out32(AXI_GPIO_BASEADDR + GPIO_LED_REG, data);

            // slv_reg1：七段码译码显示字符
            Xil_Out32(AXI_GPIO_BASEADDR + GPIO_SEG_REG, data);

            // 串口回显，方便验证
            Xil_Out32(UART_BASEADDR + UART_TX_FIFO, data);
        }
    }

    return 0;
}
