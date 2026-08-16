#include "xil_printf.h"
#include "xil_io.h"
#include "xil_types.h"

/*
 * 7B 自定义 SPI_AXI IP
 * 必须和 Vivado Address Editor 中 SPI_AXI_0/S00_AXI 的地址一致
 */
#define SPI_BASEADDR        0x44A00000U

/* 自定义 SPI_AXI 寄存器偏移 */
#define SPI_CS_OFFSET       0x00U
#define SPI_DATA_OFFSET     0x0CU

/* ADXL362 命令 */
#define ADXL362_CMD_WRITE   0x0A
#define ADXL362_CMD_READ    0x0B

/* 片选：ADXL362 的 CS 低有效 */
#define CS_LOW              0x00000000U
#define CS_HIGH             0x00000001U

/* 等待时间，可根据实际情况微调 */
#define SPI_BYTE_WAIT       20000U
#define LOOP_WAIT           5000000U

static void delay_loop(u32 count)
{
    volatile u32 i;
    for (i = 0; i < count; i++) {
        ;
    }
}

static void print_hex8(u8 value)
{
    const char hex[] = "0123456789ABCDEF";
    xil_printf("%c%c", hex[(value >> 4) & 0x0F], hex[value & 0x0F]);
}

static int to_signed8(u8 value)
{
    if (value & 0x80) {
        return (int)value - 256;
    } else {
        return (int)value;
    }
}

static void spi_cs_low(void)
{
    Xil_Out32(SPI_BASEADDR + SPI_CS_OFFSET, CS_LOW);
    delay_loop(1000);
}

static void spi_cs_high(void)
{
    Xil_Out32(SPI_BASEADDR + SPI_CS_OFFSET, CS_HIGH);
    delay_loop(1000);
}

/*
 * 向 TX FIFO 写入一个字节。
 * 注意：硬件中 tx_fifo_input = S_AXI_WDATA[31:24]，
 * 所以软件写入时要把 8 位数据左移 24 位。
 */
static void spi_send_byte(u8 data)
{
    Xil_Out32(SPI_BASEADDR + SPI_DATA_OFFSET, ((u32)data) << 24);
    delay_loop(SPI_BYTE_WAIT);
}

/*
 * 从 RX FIFO 读取一个字节。
 * 注意：硬件中 reg_data_out = {slv_reg3[31:24], rx_fifo_output, slv_reg3[15:0]}，
 * 所以有效接收数据在 [23:16]。
 */
static u8 spi_recv_byte(void)
{
    u32 value;
    value = Xil_In32(SPI_BASEADDR + SPI_DATA_OFFSET);
    delay_loop(1000);
    return (u8)((value >> 16) & 0xFF);
}

static u8 adxl362_read_reg(u8 addr)
{
    u8 dummy0;
    u8 dummy1;
    u8 data;

    spi_cs_low();

    spi_send_byte(ADXL362_CMD_READ);
    spi_send_byte(addr);
    spi_send_byte(0xFF);

    delay_loop(SPI_BYTE_WAIT);

    dummy0 = spi_recv_byte();   /* 对应命令阶段收到的数据，丢弃 */
    dummy1 = spi_recv_byte();   /* 对应地址阶段收到的数据，丢弃 */
    data   = spi_recv_byte();   /* 对应 dummy byte 阶段收到的真实数据 */

    (void)dummy0;
    (void)dummy1;

    spi_cs_high();

    return data;
}

static void adxl362_write_reg(u8 addr, u8 data)
{
    u8 dummy0;
    u8 dummy1;
    u8 dummy2;

    spi_cs_low();

    spi_send_byte(ADXL362_CMD_WRITE);
    spi_send_byte(addr);
    spi_send_byte(data);

    delay_loop(SPI_BYTE_WAIT);

    dummy0 = spi_recv_byte();
    dummy1 = spi_recv_byte();
    dummy2 = spi_recv_byte();

    (void)dummy0;
    (void)dummy1;
    (void)dummy2;

    spi_cs_high();
}

static void adxl362_init(void)
{
    /*
     * 与 7A 中的 ADXL362 配置保持一致
     */
    adxl362_write_reg(0x23, 0x96);
    adxl362_write_reg(0x25, 0x03);
    adxl362_write_reg(0x27, 0x0C);
    adxl362_write_reg(0x2A, 0x20);
    adxl362_write_reg(0x2C, 0x83);
    adxl362_write_reg(0x2D, 0x02);
}

static void print_banner(void)
{
    xil_printf("\r\n");
    xil_printf("========================================\r\n");
    xil_printf("        SPI 7B Custom IP Test\r\n");
    xil_printf("        Device: ADXL362\r\n");
    xil_printf("========================================\r\n");
}

static void print_device_id(void)
{
    u8 devid_ad;
    u8 devid_mst;
    u8 partid;

    devid_ad  = adxl362_read_reg(0x00);
    devid_mst = adxl362_read_reg(0x01);
    partid    = adxl362_read_reg(0x02);

    xil_printf("\r\n");
    xil_printf("[1] Device ID Check\r\n");
    xil_printf("----------------------------------------\r\n");

    xil_printf("DEVID_AD   0x00 = 0x");
    print_hex8(devid_ad);
    xil_printf("\r\n");

    xil_printf("DEVID_MST  0x01 = 0x");
    print_hex8(devid_mst);
    xil_printf("\r\n");

    xil_printf("PARTID     0x02 = 0x");
    print_hex8(partid);
    xil_printf("\r\n");

    xil_printf("----------------------------------------\r\n");

    if (devid_ad == 0xAD && devid_mst == 0x1D && partid == 0xF2) {
        xil_printf("Result: PASS, ADXL362 detected.\r\n");
    } else {
        xil_printf("Result: CHECK NEEDED.\r\n");
        xil_printf("Expected: 0xAD, 0x1D, 0xF2\r\n");
    }

    xil_printf("----------------------------------------\r\n");
}

static void print_xyz_header(void)
{
    xil_printf("\r\n");
    xil_printf("[2] X/Y/Z Data Output\r\n");
    xil_printf("----------------------------------------\r\n");
    xil_printf("Format: raw hex value and signed decimal\r\n");
    xil_printf("----------------------------------------\r\n");
}

static void print_xyz_data(u32 index, u8 x, u8 y, u8 z)
{
    xil_printf("Sample ");
    xil_printf("%d", index);
    xil_printf(" | X = 0x");
    print_hex8(x);
    xil_printf(" (%d)", to_signed8(x));

    xil_printf(" | Y = 0x");
    print_hex8(y);
    xil_printf(" (%d)", to_signed8(y));

    xil_printf(" | Z = 0x");
    print_hex8(z);
    xil_printf(" (%d)", to_signed8(z));

    xil_printf("\r\n");
}

int main(void)
{
    u32 sample_count = 0;
    u8 x_data;
    u8 y_data;
    u8 z_data;

    /*
     * 先释放片选，避免上电后 CS 长时间保持低电平
     */
    spi_cs_high();

    print_banner();

    print_device_id();

    xil_printf("\r\n");
    xil_printf("[Init] Configure ADXL362...\r\n");
    adxl362_init();
    xil_printf("[Init] Done.\r\n");

    print_xyz_header();

    while (1) {
        x_data = adxl362_read_reg(0x08);
        y_data = adxl362_read_reg(0x09);
        z_data = adxl362_read_reg(0x0A);

        print_xyz_data(sample_count, x_data, y_data, z_data);

        sample_count++;

        if ((sample_count % 10) == 0) {
            xil_printf("----------------------------------------\r\n");
        }

        delay_loop(LOOP_WAIT);
    }

    return 0;
}
