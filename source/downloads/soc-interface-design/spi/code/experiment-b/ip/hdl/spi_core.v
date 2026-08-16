//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module spi_core
  #(
    parameter SPIWIDTH = 8,
    parameter CNT = 3
    )(
      input                     reset_n,
      input                     spi_clk,

      input [SPIWIDTH-1:0]      datain,
      output reg [SPIWIDTH-1:0] dataout,

      input                     spi_enable,
      output reg                spi_busy,

      input                     MISO,
      output reg                MOSI,
      output                    SCK
      );

   reg [CNT:0]                  spi_bitcnt;

   always @(posedge spi_clk or negedge reset_n)
     if (~reset_n) begin
        spi_bitcnt <= 0;
        spi_busy <= 0;
        MOSI <= 0;
     end else begin
        spi_bitcnt <= 0;
        spi_busy <= 0;
        MOSI <= 0;
        if (spi_enable &(spi_bitcnt < SPIWIDTH))
          begin
             MOSI <= datain[SPIWIDTH-spi_bitcnt-1];
             spi_bitcnt <= spi_bitcnt + 1;
             spi_busy <= 1;
          end
     end

   always @(negedge spi_clk or negedge reset_n)
     if (~reset_n)
       dataout <= 0;
     else if (spi_enable &(spi_bitcnt > 0))
       dataout[SPIWIDTH-spi_bitcnt] <= MISO;

   assign SCK = spi_bitcnt ? ~spi_clk : 0;

endmodule
