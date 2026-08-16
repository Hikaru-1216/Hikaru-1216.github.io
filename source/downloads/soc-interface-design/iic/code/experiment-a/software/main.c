#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define IIC_BASEADDR  0x40800000U

#define CR        0x100U
#define SR        0x104U
#define TX_FIFO   0x108U
#define RX_FIFO   0x10CU

#define IIC_ADDR  0x4BU
#define RX_SIZE   2U

#define CR_ENABLE        0x01U
#define CR_TX_FIFO_RESET 0x02U

#define SR_RX_FIFO_EMPTY 0x40U
#define SR_BUS_BUSY      0x04U

static u8 iic_read_byte(void)
{
    while (Xil_In32(IIC_BASEADDR + SR) & SR_RX_FIFO_EMPTY) {
        // wait
    }
    return (u8)(Xil_In32(IIC_BASEADDR + RX_FIFO) & 0xFF);
}

static float convert_temp(u8 msb, u8 lsb)
{
    int raw = (((int)msb << 8) | lsb) >> 3;

    // 13-bit two's complement
    if (raw & 0x1000) {
        raw -= 8192;
    }

    return raw * 0.0625f;
}

int main(void)
{
    xil_printf("Lab6A AXI IIC temperature test\r\n");

    // enable AXI IIC and reset TX FIFO
    Xil_Out32(IIC_BASEADDR + CR, CR_TX_FIFO_RESET);
    Xil_Out32(IIC_BASEADDR + CR, CR_ENABLE);

    while (1) {
        u8 msb, lsb;
        float temp;
        int temp_x100;

        // 读取 ADT7420 温度寄存器 0x00 的两个字节
        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x100 | (IIC_ADDR << 1));      // START + write addr 0x96
        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x00);                        // register address 0x00
        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x101 | (IIC_ADDR << 1));      // repeated START + read addr 0x97
        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x200 + RX_SIZE);             // STOP + read 2 bytes

        msb = iic_read_byte();
        lsb = iic_read_byte();

        temp = convert_temp(msb, lsb);
        temp_x100 = (int)(temp * 100);

        xil_printf("MSB=0x%02x LSB=0x%02x Temp=%d.%02d C\r\n",
                   msb, lsb, temp_x100 / 100, temp_x100 % 100);

        sleep(1);
    }

    return 0;
}
