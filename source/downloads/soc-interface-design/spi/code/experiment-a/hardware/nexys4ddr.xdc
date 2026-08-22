## Reset signal
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { reset }]

## Clock signal: 100MHz onboard clock
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { sys_clock }]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { sys_clock }]

## USB-UART Interface
set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports { usb_uart_rxd }]
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports { usb_uart_txd }]

## ADXL362 SPI Interface
## MOSI
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_io0_io }]

## MISO
set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_io1_io }]

## SCLK
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_sck_io }]

## CS / SS
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_ss_io[0] }]