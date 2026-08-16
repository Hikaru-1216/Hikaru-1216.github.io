//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module tb_spi_ctrl ();

   reg   	clk;
   reg 		reset_n;
   reg [7:0] 	datain;
   reg 		spi_enable;
   reg          CS_N;

   reg [7:0] 	tx_fifo_input;
   reg 		tx_fifo_en;
   reg 		clean_tx_fifo;

   wire [7:0] 	rx_fifo_output;
   reg 		rx_fifo_en;
   reg 		clean_rx_fifo;

   wire 	tx_fifo_full;
   wire 	tx_fifo_empty;
   wire 	rx_fifo_full;
   wire 	rx_fifo_empty;

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

   spi_ctrl UUT
     (
      .reset_n(reset_n),
      .clk(clk),
      .tx_fifo_input(tx_fifo_input),
      .tx_fifo_en(tx_fifo_en),
      .clean_tx_fifo(clean_tx_fifo),
      .tx_fifo_full(tx_fifo_full),
      .tx_fifo_empty(tx_fifo_empty),
      .rx_fifo_output(rx_fifo_output),
      .rx_fifo_en(rx_fifo_en),
      .clean_rx_fifo(clean_rx_fifo),
      .rx_fifo_full(rx_fifo_full),
      .rx_fifo_empty(rx_fifo_empty),
      .spi_busy(spi_busy),
      .MISO(MISO),
      .MOSI(MOSI),
      .SCK(SCK)
      );

   initial begin
      #0   clk = 0;
      #0   reset_n = 0;
      #0   CS_N = 0;
      #0   clean_tx_fifo = 0;
      #0   clean_rx_fifo = 0;
      #0   rx_fifo_en = 0;
      #0   tx_fifo_en = 0;
      #30  reset_n = 1;
   end

   always  #5 clk = ~clk;

   initial begin
      #15000    tx_fifo_input = 'h06;  CS_N = 0;    tx_fifo_en = 1;
      #10                                           tx_fifo_en = 0;
      #10000                           CS_N = 1;

      #1000     tx_fifo_input = 'h02;  CS_N = 0;    tx_fifo_en = 1;
      #10       tx_fifo_input = 'h10;
      #10       tx_fifo_input = 'h21;
      #10       tx_fifo_input = 'h22;
      #10       tx_fifo_input = 'h23;
      #10       tx_fifo_input = 'h24;
      #10       tx_fifo_input = 'h25;
      #10       tx_fifo_input = 'h26;
      #10                                           tx_fifo_en = 0;
      #900000                          CS_N = 1;
      #10000                           CS_N = 0;

      #10       clean_tx_fifo = 1;     clean_rx_fifo = 1;
      #20       clean_tx_fifo = 0;     clean_rx_fifo = 0;

      #5100000  tx_fifo_input = 'h03;  CS_N = 0;    tx_fifo_en = 1;
      #10       tx_fifo_input = 'h10;
      #10       tx_fifo_input = 'h00;
      #10       tx_fifo_input = 'h00;
      #10       tx_fifo_input = 'h00;
      #10       tx_fifo_input = 'h00;
      #10       tx_fifo_input = 'h00;
      #10       tx_fifo_input = 'h00;
      #10                                            tx_fifo_en = 0;
      #90000                           CS_N = 1;
   end

endmodule
