//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module tb_spi_core ();

   reg   	spi_clk;
   reg 		reset_n;
   reg [7:0] 	datain;
   reg 		spi_enable;
   reg          CS_N;

   wire 	MOSI,MISO,SCK;

   M25AA010A u_M25AA_01
     (
      .SI(MOSI),
      .SO(MISO),
      .SCK(SCK),
      .CS_N(CS_N),
      .WP_N(1'b1),
      .HOLD_N(1'b1),
      .RESET(~reset_n)
      );

   spi_core #(.WDWIDTH(8), .CNT(3)) UUT
     (
      .reset_n(reset_n),
      .spi_clk(spi_clk),
      .datain(datain),
      .dataout(dataout),
      .spi_enable(spi_enable),
      .spi_busy(spi_busy),
      .MOSI(MOSI),
      .MISO(MISO),
      .SCK(SCK)
      );

   initial begin
      #0   spi_clk = 1'b0;
      #0   reset_n = 1'b0;
      #0   spi_enable = 1'b0;
      #0   CS_N = 1'b0;
      #30  reset_n = 1'b1;
   end

   always  #500 spi_clk = ~spi_clk;

   initial begin
      #15000    datain = 'h06; spi_enable = 1'b1; CS_N = 1'b0;
      #9000                    spi_enable = 1'b0; CS_N = 1'b1;
      #9000     datain = 'h02; spi_enable = 1'b1; CS_N = 1'b0;
      #9000     datain = 'h10;
      #9000     datain = 'h21;
      #9000     datain = 'h22;
      #9000     datain = 'h23;
      #9000     datain = 'h24;
      #9000     datain = 'h25;
      #9000     datain = 'h26;
      #9000                    spi_enable = 1'b0; CS_N = 1'b1;
      #5100000  datain = 'h03; spi_enable = 1'b1; CS_N = 1'b0;
      #9000     datain = 'h10;
      #9000     datain = 'h00;
      #54000                   spi_enable = 1'b0; CS_N = 1'b1;
   end

endmodule
