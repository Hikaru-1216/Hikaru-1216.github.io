#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"

#define AXI_GPIO_BASEADDR  XPAR_AXI_GPIO_0_S00_AXI_BASEADDR
#define LED_REG_OFFSET     0x00U

int main(void)
{
    while (1)
    {
        Xil_Out32(AXI_GPIO_BASEADDR + LED_REG_OFFSET, 0x0000FFFF);
        sleep(1);

        Xil_Out32(AXI_GPIO_BASEADDR + LED_REG_OFFSET, 0x00000000);
        sleep(1);

        Xil_Out32(AXI_GPIO_BASEADDR + LED_REG_OFFSET, 0x00005555);
        sleep(1);

        Xil_Out32(AXI_GPIO_BASEADDR + LED_REG_OFFSET, 0x0000AAAA);
        sleep(1);

        for (int i = 0; i < 16; i++) {
            Xil_Out32(AXI_GPIO_BASEADDR + 0x00, 1 << i);
            sleep(1);
        }
    }

    return 0;
}
