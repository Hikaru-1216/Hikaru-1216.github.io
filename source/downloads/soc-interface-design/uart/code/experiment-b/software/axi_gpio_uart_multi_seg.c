#include "xparameters.h"
#include "xil_io.h"

#define AXI_GPIO_BASEADDR   XPAR_AXI_GPIO_0_S00_AXI_BASEADDR
#define UART_BASEADDR       XPAR_UART_0_S00_AXI_BASEADDR

#define GPIO_LED_REG        0x00U
#define GPIO_SEG_REG        0x04U   // slv_reg1: 保存 4 个 ASCII 字符
#define GPIO_SW_REG         0x08U
#define GPIO_MODE_REG       0x0CU   // slv_reg3: 显示模式

#define UART_RX_FIFO        0x00U
#define UART_TX_FIFO        0x04U
#define UART_STAT_REG       0x08U
#define UART_CTRL_REG       0x0CU

#define UART_RX_READY_MASK  0x01U

#define CPU_CLK             100000000U
#define UART_BAUD_RATE      9600U
#define UART_BAUD_DIV       (CPU_CLK / 2U / UART_BAUD_RATE)

#define SEG_MODE_SINGLE     0x00000000U
#define SEG_MODE_MULTI      0x40000000U   // slv_reg3[31:30] = 01
#define SEG_MODE_TIME       0x80000000U   // slv_reg3[31:30] = 10

static void write_display(unsigned char buf[4])
{
    unsigned int reg_value;

    reg_value = ((unsigned int)buf[0] << 24) |
                ((unsigned int)buf[1] << 16) |
                ((unsigned int)buf[2] << 8)  |
                ((unsigned int)buf[3]);

    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_SEG_REG, reg_value);
}

int main(void)
{
    unsigned int stat;
    unsigned int data;

    unsigned char disp_buf[4] = {' ', ' ', ' ', ' '};

    Xil_Out32(UART_BASEADDR + UART_CTRL_REG, UART_BAUD_DIV);

    // 进入多字符显示模式
    Xil_Out32(AXI_GPIO_BASEADDR + GPIO_MODE_REG, SEG_MODE_MULTI);

    // 初始显示空白
    write_display(disp_buf);

    while (1)
    {
        stat = Xil_In32(UART_BASEADDR + UART_STAT_REG);

        if (stat & UART_RX_READY_MASK)
        {
            data = Xil_In32(UART_BASEADDR + UART_RX_FIFO) & 0xFFU;

            // 忽略回车换行，避免串口助手自动追加 CR/LF 影响显示
            if (data == '\r' || data == '\n')
            {
                continue;
            }

            // 只显示常见可见字符
            if (data >= 0x20U && data <= 0x7EU)
            {
                // 滚动缓存：最新收到的字符放到最右边
                disp_buf[0] = disp_buf[1];
                disp_buf[1] = disp_buf[2];
                disp_buf[2] = disp_buf[3];
                disp_buf[3] = (unsigned char)data;

                // 写入 slv_reg1，让七段码显示最近 4 个字符
                write_display(disp_buf);

                // LED 仍然显示当前字符 ASCII，兼容 B/C 的观察方式
                Xil_Out32(AXI_GPIO_BASEADDR + GPIO_LED_REG, data);

                // 串口回显
                Xil_Out32(UART_BASEADDR + UART_TX_FIFO, data);
            }
        }
    }

    return 0;
}
