//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module iic_clkgen
  (
   input  clk,
   input  reset_n,
   output CLK_100K_SDA,
   output CLK_100K_SCL
   );

   reg 	  CLK_100K_A;
   reg 	  CLK_100K_B;
   reg [15:0] counter;

   always @(posedge clk or negedge reset_n)
     begin
	if (!reset_n) begin counter = 0; CLK_100K_A = 0; CLK_100K_B = 0; end
	else begin
	   counter = counter + 1;
	   if (counter == 225) CLK_100K_A = ~CLK_100K_A;
	   if (counter >= 250) begin CLK_100K_B = ~CLK_100K_B; counter = 0; end
	end
     end

   assign CLK_100K_SDA = CLK_100K_A | CLK_100K_B;
   assign CLK_100K_SCL = CLK_100K_A & CLK_100K_B;

endmodule
