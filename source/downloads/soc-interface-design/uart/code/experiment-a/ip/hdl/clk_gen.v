//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// Wang Yubo, wangyubo_vlsi@qq.com
//
//---------------------------------------------------------------------------------

module clk_gen
  (
   input wire 	     clk_in,
   input wire 	     reset_n,
   output reg 	     clk_out,
   input wire [15:0] count
   );
   reg [15:0] 	     cnt;

   always @(posedge clk_in or negedge reset_n)
     begin
        if (!reset_n)
          cnt <= 0;
        else if (cnt == count - 1)
          cnt <= 0;
        else
          cnt <= cnt + 1;
     end

   always @(posedge clk_in or negedge reset_n)
     begin
        if (!reset_n)
          clk_out <= 0;
        else if (cnt == count - 1)
          clk_out <= ~clk_out;
     end

endmodule
