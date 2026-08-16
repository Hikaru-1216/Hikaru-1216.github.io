#include "xparameters.h"
#include "xil_io.h"

#define AXI_GPIO_BASEADDR   XPAR_AXI_GPIO_0_S00_AXI_BASEADDR
#define UART_BASEADDR       XPAR_UART_0_S00_AXI_BASEADDR

#define GPIO_LED_REG        0x00U

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

    // 设置 UART 波特率：100MHz / 2 / 9600 = 5208 = 0x1458
    Xil_Out32(UART_BASEADDR + UART_CTRL_REG, UART_BAUD_DIV);

    // 初始 LED 全灭
    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_LED_REG, 0x00000000U);

    while (1)
    {
        stat = Xil_In32(UART_BASEADDR + UART_STAT_REG);

        if (stat & UART_RX_READY_MASK)
        {
            data = Xil_In32(UART_BASEADDR + UART_RX_FIFO) & 0xFFU;

            // LED 显示收到字符的 ASCII 二进制值
            Xil_Out32(AXI_GPIO_BASEADDR + GPIO_LED_REG, data);

            // 原样回显到串口助手，方便确认
            Xil_Out32(UART_BASEADDR + UART_TX_FIFO, data);
        }
    }

    return 0;
}
