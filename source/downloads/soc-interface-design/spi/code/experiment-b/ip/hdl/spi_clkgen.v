//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module spi_clkgen
  #(
    parameter CntNumber = 50
    )(
      input 	 clk,
      input 	 reset_n,
      output reg clk_div
      );

   reg [15:0] 	 cnt;

   always @(posedge clk or negedge reset_n)
     if (!reset_n)
       cnt = 0;
     else if (cnt == CntNumber - 1)
       cnt <= 0;
     else
       cnt <= cnt + 1;

   always @(posedge clk or negedge reset_n)
     if (!reset_n)
       clk_div <= 0;
     else if (cnt == CntNumber - 1)
       clk_div <= ~clk_div;

endmodule
