#include "xparameters.h"
#include "xil_io.h"

#define AXI_GPIO_BASEADDR   XPAR_AXI_GPIO_0_S00_AXI_BASEADDR
#define UART_BASEADDR       XPAR_UART_0_S00_AXI_BASEADDR

// AXI_GPIO registers
#define GPIO_LED_REG        0x00U   // slv_reg0
#define GPIO_SEG_REG        0x04U   // slv_reg1
#define GPIO_SW_REG         0x08U   // slv_reg2

// UART registers
#define UART_RX_FIFO        0x00U
#define UART_TX_FIFO        0x04U
#define UART_STAT_REG       0x08U
#define UART_CTRL_REG       0x0CU

#define CPU_CLK             100000000U
#define UART_BAUD_RATE      9600U
#define UART_BAUD_DIV       (CPU_CLK / 2U / UART_BAUD_RATE)

static void delay_short(void)
{
    volatile int i;
    for (i = 0; i < 50000; i++);
}

static void uart_putc(char c)
{
    Xil_Out32(UART_BASEADDR + UART_TX_FIFO, (unsigned int)c);
    delay_short();
}

static void uart_puts(const char *s)
{
    while (*s)
    {
        uart_putc(*s++);
    }
}

static char hex_char(unsigned int x)
{
    x &= 0xFU;
    if (x < 10)
        return '0' + x;
    else
        return 'A' + (x - 10);
}

static void uart_put_hex16(unsigned int value)
{
    uart_putc(hex_char(value >> 12));
    uart_putc(hex_char(value >> 8));
    uart_putc(hex_char(value >> 4));
    uart_putc(hex_char(value));
}

int main(void)
{
    unsigned int sw_value;
    unsigned int last_value = 0xFFFFFFFFU;

    // 设置 UART 波特率
    Xil_Out32(UART_BASEADDR + UART_CTRL_REG, UART_BAUD_DIV);

    uart_puts("Switch UART test start\r\n");

    while (1)
    {
        sw_value = Xil_In32(AXI_GPIO_BASEADDR + GPIO_SW_REG) & 0xFFFFU;

        // 只有开关变化时才发送，避免刷屏
        if (sw_value != last_value)
        {
            last_value = sw_value;

            // 可选：LED 同步显示拨码开关值
            Xil_Out32(AXI_GPIO_BASEADDR + GPIO_LED_REG, sw_value);

            // 通过 UART 发送到 PC
            uart_puts("SW = 0x");
            uart_put_hex16(sw_value);
            uart_puts("\r\n");
        }

        delay_short();
    }

    return 0;
}
