## Clock signal: 100 MHz onboard clock
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { sys_clock }]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { sys_clock }]

## Reset signal
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { reset }]

## USB-UART Interface
set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports { usb_uart_rxd }]
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports { usb_uart_txd }]

## ADXL362 SPI Interface
## MOSI: Master Out Slave In
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { mosi_0 }]

## MISO: Master In Slave Out
set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports { miso_0 }]

## SCK: SPI Clock
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports { sck_0 }]

## CS: Chip Select, active low
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS33 } [get_ports { cs_0 }]