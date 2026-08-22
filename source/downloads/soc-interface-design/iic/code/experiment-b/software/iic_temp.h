#ifndef IIC_TEMP_H
#define IIC_TEMP_H

#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define IIC_BASEADDR  XPAR_IIC_ZJU_SOC_0_S00_AXI_BASEADDR

#define TX_FIFO  0x00U
#define RX_FIFO  0x04U
#define SR       0x08U
#define DEBUG_REG 0x0CU

#define SR_TX_FIFO_EMPTY 0x80U
#define SR_RX_FIFO_EMPTY 0x40U
#define SR_ERROR         0x01U

#define IIC_ADDR 0x4BU
#define RX_SIZE  2U

#define IIC_TIMEOUT 10000000

#endif
