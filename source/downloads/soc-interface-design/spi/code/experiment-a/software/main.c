#include "xil_printf.h"
#include "xil_io.h"

/* 必须和 Vivado Address Editor 中 axi_quad_spi_0 的地址一致 */
#define XPAR_SPI_0_BASEADDR 0x44A00000U

/* AXI Quad SPI register offsets */
#define XSP_DGIER_OFFSET    0x1C
#define XSP_IISR_OFFSET     0x20
#define XSP_IIER_OFFSET     0x28
#define XSP_SRR_OFFSET      0x40
#define XSP_CR_OFFSET       0x60
#define XSP_SR_OFFSET       0x64
#define XSP_DTR_OFFSET      0x68
#define XSP_DRR_OFFSET      0x6C
#define XSP_SSR_OFFSET      0x70
#define XSP_TFO_OFFSET      0x74
#define XSP_RFO_OFFSET      0x78

#define XSpi_WriteReg(BaseAddress, RegOffset, RegisterValue) \
    Xil_Out32((BaseAddress) + (RegOffset), (RegisterValue))

#define XSpi_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

static void delay_loop(unsigned int count)
{
    volatile unsigned int i;
    for (i = 0; i < count; i++) {
        ;
    }
}

unsigned char spi_read_reg(unsigned char addr)
{
    unsigned char data;

    /* 初始化 SPI，并选中从机 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x1C6);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_SSR_OFFSET, 0x1);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x186);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_SSR_OFFSET, 0x0);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x086);

    /* 发送 ADXL362 读寄存器命令 0x0B */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_DTR_OFFSET, 0x0B);
    delay_loop(10000);
    XSpi_ReadReg(XPAR_SPI_0_BASEADDR, XSP_DRR_OFFSET);

    /* 发送寄存器地址 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_DTR_OFFSET, addr);
    delay_loop(10000);
    XSpi_ReadReg(XPAR_SPI_0_BASEADDR, XSP_DRR_OFFSET);

    /* 发送 dummy byte，同时读回数据 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_DTR_OFFSET, 0xFF);
    delay_loop(10000);
    data = (unsigned char)(XSpi_ReadReg(XPAR_SPI_0_BASEADDR, XSP_DRR_OFFSET) & 0xFF);

    /* 释放片选 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_SSR_OFFSET, 0x1);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x186);

    return data;
}

void spi_write_reg(unsigned char addr, unsigned char data)
{
    /* 初始化 SPI，并选中从机 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x1C6);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_SSR_OFFSET, 0x1);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x186);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_SSR_OFFSET, 0x0);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x086);

    /* 发送 ADXL362 写寄存器命令 0x0A */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_DTR_OFFSET, 0x0A);
    delay_loop(10000);
    XSpi_ReadReg(XPAR_SPI_0_BASEADDR, XSP_DRR_OFFSET);

    /* 发送寄存器地址 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_DTR_OFFSET, addr);
    delay_loop(10000);
    XSpi_ReadReg(XPAR_SPI_0_BASEADDR, XSP_DRR_OFFSET);

    /* 发送要写入的数据 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_DTR_OFFSET, data);
    delay_loop(10000);
    XSpi_ReadReg(XPAR_SPI_0_BASEADDR, XSP_DRR_OFFSET);

    /* 释放片选 */
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_SSR_OFFSET, 0x1);
    XSpi_WriteReg(XPAR_SPI_0_BASEADDR, XSP_CR_OFFSET,  0x186);
}

int main()
{
    xil_printf("SPI ADXL362 test start\r\n");

    /* 读取 ADXL362 设备 ID */
    xil_printf("device id 0x00: %x\r\n", spi_read_reg(0x00));
    xil_printf("device id 0x01: %x\r\n", spi_read_reg(0x01));
    xil_printf("device id 0x02: %x\r\n", spi_read_reg(0x02));

    xil_printf("----------------\r\n");

    /* 配置 ADXL362 */
    spi_write_reg(0x23, 0x96);
    spi_write_reg(0x25, 0x03);
    spi_write_reg(0x27, 0x0C);
    spi_write_reg(0x2A, 0x20);
    spi_write_reg(0x2C, 0x83);
    spi_write_reg(0x2D, 0x02);

    xil_printf("Start reading x/y/z data\r\n");
    xil_printf("----------------\r\n");

    while (1) {
        xil_printf("device x: %x\r\n", spi_read_reg(0x08));
        xil_printf("device y: %x\r\n", spi_read_reg(0x09));
        xil_printf("device z: %x\r\n", spi_read_reg(0x0A));
        xil_printf("----------------\r\n");

        delay_loop(5000000);
    }

    return 0;
}
