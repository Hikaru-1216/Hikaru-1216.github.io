#include "xparameters.h"
#include "xil_io.h"

#define AXI_GPIO_BASEADDR   XPAR_AXI_GPIO_0_S00_AXI_BASEADDR
#define UART_BASEADDR       XPAR_UART_0_S00_AXI_BASEADDR

#define GPIO_LED_REG        0x00U
#define GPIO_SEG_REG        0x04U   // slv_reg1: HHMM
#define GPIO_SW_REG         0x08U
#define GPIO_MODE_REG       0x0CU   // slv_reg3: bit31 控制时间模式

#define UART_RX_FIFO        0x00U
#define UART_TX_FIFO        0x04U
#define UART_STAT_REG       0x08U
#define UART_CTRL_REG       0x0CU

#define UART_RX_READY_MASK  0x01U

#define CPU_CLK             100000000U
#define UART_BAUD_RATE      9600U
#define UART_BAUD_DIV       (CPU_CLK / 2U / UART_BAUD_RATE)

static void uart_putc(char c)
{
    Xil_Out32(UART_BASEADDR + UART_TX_FIFO, (unsigned int)c);
}

static void uart_puts(const char *s)
{
    while (*s) {
        uart_putc(*s++);
    }
}

int main(void)
{
    unsigned int stat;
    unsigned int data;
    unsigned char buf[4];
    int index = 0;
    unsigned int time_reg;

    Xil_Out32(UART_BASEADDR + UART_CTRL_REG, UART_BAUD_DIV);

    // 进入时间显示模式
    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_MODE_REG, 0x80000000U);

    // 初始显示 00:00
    time_reg = ('0' << 24) | ('0' << 16) | ('0' << 8) | '0';
    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_SEG_REG, time_reg);

    uart_puts("Time display mode start. Send HHMM, for example 1435.\r\n");

    while (1)
    {
        stat = Xil_In32(UART_BASEADDR + UART_STAT_REG);

        if (stat & UART_RX_READY_MASK)
        {
            data = Xil_In32(UART_BASEADDR + UART_RX_FIFO) & 0xFFU;

            // 回显收到的字符
            uart_putc((char)data);

            // 只接收数字，忽略冒号、换行等字符
            if (data >= '0' && data <= '9')
            {
                buf[index] = (unsigned char)data;
                index++;

                if (index == 4)
                {
                    // buf[0]buf[1]: 小时，buf[2]buf[3]: 分钟
                    time_reg = ((unsigned int)buf[0] << 24) |
                               ((unsigned int)buf[1] << 16) |
                               ((unsigned int)buf[2] << 8)  |
                               ((unsigned int)buf[3]);

                    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_SEG_REG, time_reg);
                    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_LED_REG, time_reg & 0xFFFFU);

                    uart_puts("\r\nTime updated: ");
                    uart_putc(buf[0]);
                    uart_putc(buf[1]);
                    uart_putc(':');
                    uart_putc(buf[2]);
                    uart_putc(buf[3]);
                    uart_puts("\r\n");

                    index = 0;
                }
            }
        }
    }

    return 0;
}
