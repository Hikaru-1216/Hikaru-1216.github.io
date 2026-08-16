//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module tb_iic_clkgen();

   reg   clk;
   reg   reset_n;
   wire  clk_div;

   spi_clkgen UUT (
		   .clk(clk),
		   .reset_n(reset_n),
		   .clk_div(clk_div)
		   );

   initial begin
      #0   clk = 1'b 0;
      #0   reset_n = 1'b 0;
      #30  reset_n = 1'b 1;
   end

   always  #5 clk = ~clk;

endmodule
