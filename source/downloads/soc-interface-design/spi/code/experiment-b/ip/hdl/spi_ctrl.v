//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module spi_ctrl
  #(
    parameter SPIWIDTH = 8
    )(
      input 		    reset_n,
      input 		    clk,

      input [SPIWIDTH-1:0]  tx_fifo_input,
      input 		    tx_fifo_en,
      input 		    clean_tx_fifo,
      output 		    tx_fifo_full,
      output 		    tx_fifo_empty,

      output [SPIWIDTH-1:0] rx_fifo_output,
      input 		    rx_fifo_en,
      input 		    clean_rx_fifo,
      output 		    rx_fifo_full,
      output 		    rx_fifo_empty,

      output 		    spi_busy,

      input 		    MISO,
      output 		    MOSI,
      output 		    SCK
      );

   wire 		    spi_clk;
   wire 		    MISO_clean;


   reg 			    spi_enable;
   reg [SPIWIDTH-1:0] 	    spi_bitcount;
   reg 			    tx_rd;

   reg [SPIWIDTH-1:0] 	    spi_datain;
   wire [SPIWIDTH-1:0] 	    spi_dataout;
   wire [SPIWIDTH-1:0] 	    tx_data_i;

   reg 			    spi_busy_prev, spi_busy_now;
   wire 		    spi_busy_negedge;

   reg [1:0] 		    spi_state, spi_nextstate;

   parameter  SPI_IDLE = 2'h1;
   parameter  SPI_DATA = 2'h2;
   parameter  SPI_SEND = 2'h3;

   always @(posedge clk or negedge reset_n)
     if (~reset_n) begin
        spi_busy_prev <= 0;
        spi_busy_now <= 0;
     end else begin
        spi_busy_now <= spi_busy;
        spi_busy_prev <= spi_busy_now;
     end

   assign spi_busy_negedge = ~spi_busy_now & spi_busy_prev;

   always @(posedge clk or negedge reset_n)
     if (~reset_n) spi_state <= SPI_IDLE;
     else spi_state <= spi_nextstate;

   always @(*) begin
      spi_nextstate <= SPI_IDLE;
      case (spi_state)
	SPI_IDLE : spi_nextstate <= tx_fifo_empty ? SPI_IDLE : SPI_DATA;
	SPI_DATA : spi_nextstate <= SPI_SEND;
	SPI_SEND : spi_nextstate <= spi_busy_negedge ? SPI_IDLE : SPI_SEND;
      endcase
   end

   always @(posedge clk or negedge reset_n)
     if (~reset_n) begin
	spi_bitcount <= 0;
	spi_enable <= 0;
	tx_rd <= 0;
     end else begin
	tx_rd <= 0;
	spi_enable <= 0;
	case (spi_nextstate)
	  SPI_DATA : begin
	     spi_bitcount <= SPIWIDTH;
	     spi_enable <= 1;
	     tx_rd <= 1;
	     spi_datain <= tx_data_i;
	  end
	  SPI_SEND : spi_enable <= 1;
	endcase
     end

   spi_clkgen u_spi_clkgen_01
     (
      .clk(clk),
      .reset_n(reset_n),
      .clk_div(spi_clk)
      );

   spi_fifo #(.WIDTH(SPIWIDTH), .DEPTH(16), .COUNT(4)) u_tx_fifo_01
     (
      .dout(tx_data_i),
      .data_count(),
      .empty(tx_fifo_empty),
      .full(tx_fifo_full),
      .din(tx_fifo_input),
      .wr_en(tx_fifo_en),
      .rd_en(tx_rd),
      .clean_fifo(clean_tx_fifo),
      .reset_n(reset_n),
      .clk(clk)
      );

   spi_fifo #(.WIDTH(SPIWIDTH), .DEPTH(16), .COUNT(4)) u_rx_fifo_01
     (
      .dout(rx_fifo_output),
      .data_count(),
      .empty(rx_fifo_empty),
      .full(rx_fifo_full),
      .din(spi_dataout),
      .wr_en(spi_busy_negedge),
      .rd_en(rx_fifo_en),
      .clean_fifo(clean_rx_fifo),
      .reset_n(reset_n),
      .clk(clk)
      );

   debounce #(.N(3)) u_debounce_spi_01
     (
      .clk(clk),
      .reset_n(reset_n),
      .datain(MISO),
      .dataout(MISO_clean)
      );

   spi_core #(.SPIWIDTH(SPIWIDTH), .CNT(3)) u_spi_core_01
     (
      .reset_n(reset_n),
      .spi_clk(spi_clk),
      .datain(spi_datain),
      .dataout(spi_dataout),
      .spi_enable(spi_enable),
      .spi_busy(spi_busy),
      .MOSI(MOSI),
      .MISO(MISO_clean),
      .SCK(SCK)
      );

endmodule
