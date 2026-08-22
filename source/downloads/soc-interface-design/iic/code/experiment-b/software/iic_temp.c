#include "iic_temp.h"

static void print_iic_debug(const char *tag)
{
    u32 sr = Xil_In32(IIC_BASEADDR + SR);
    u32 dbg = Xil_In32(IIC_BASEADDR + DEBUG_REG);
    u32 last_tx = Xil_In32(IIC_BASEADDR + TX_FIFO);

    xil_printf("%s SR=0x%08x DBG=0x%08x LASTTX=0x%08x\r\n",
               tag, sr, dbg, last_tx);
}

static int iic_read_byte(u8 *data)
{
    int timeout = IIC_TIMEOUT;
    u32 sr;

    while (timeout--) {
        sr = Xil_In32(IIC_BASEADDR + SR);

        if ((sr & SR_RX_FIFO_EMPTY) == 0) {
            *data = (u8)(Xil_In32(IIC_BASEADDR + RX_FIFO) & 0xFF);
            return 0;
        }
    }

    print_iic_debug("RX timeout");
    return -1;
}

static void iic_drain_rx_fifo(void)
{
    int guard = 16;

    while (guard-- && ((Xil_In32(IIC_BASEADDR + SR) & SR_RX_FIFO_EMPTY) == 0)) {
        (void)Xil_In32(IIC_BASEADDR + RX_FIFO);
    }
}

static int convert_temp_x100(u8 msb, u8 lsb)
{
    int raw = (((int)msb << 8) | lsb) >> 3;
    int scaled;

    if (raw & 0x1000) {
        raw -= 8192;
    }

    scaled = raw * 625;
    return (scaled >= 0) ? ((scaled + 50) / 100) : ((scaled - 50) / 100);
}

static void print_temp(u8 msb, u8 lsb, int temp_x100)
{
    if (temp_x100 < 0) {
        int abs_temp = -temp_x100;
        xil_printf("MSB=0x%02x LSB=0x%02x Temp=-%d.%02d C\r\n",
                   msb, lsb, abs_temp / 100, abs_temp % 100);
    } else {
        xil_printf("MSB=0x%02x LSB=0x%02x Temp=%d.%02d C\r\n",
                   msb, lsb, temp_x100 / 100, temp_x100 % 100);
    }
}

int main(void)
{
    u8 msb, lsb;
    int temp_x100;
    u32 sr;

    xil_printf("Lab6B Custom AXI IIC Test\r\n");

    while (1) {
        iic_drain_rx_fifo();
        Xil_Out32(IIC_BASEADDR + DEBUG_REG, 1U);

        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x100 | (IIC_ADDR << 1));      // START + write address 0x96
        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x00);                        // temperature register 0x00
        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x101 | (IIC_ADDR << 1));      // repeated START + read address 0x97
        Xil_Out32(IIC_BASEADDR + TX_FIFO, 0x200 + RX_SIZE);             // STOP after reading RX_SIZE bytes

        if (iic_read_byte(&msb) != 0 || iic_read_byte(&lsb) != 0) {
            sleep(1);
            continue;
        }

        sr = Xil_In32(IIC_BASEADDR + SR);
        if (sr & SR_ERROR) {
            xil_printf("IIC error, SR=0x%08x\r\n", sr);
        }

        temp_x100 = convert_temp_x100(msb, lsb);
        print_temp(msb, lsb, temp_x100);

        sleep(1);
    }

    return 0;
}
