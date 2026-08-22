//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module debounce
  #(
    parameter N = 8
    )(
      input 	 reset_n, clk, datain,
      output reg dataout
      );

   reg [N-1 : 0] count;
   reg           datain_s0, datain_s1;

   always @(posedge clk)
     if (~reset_n)
       begin
          count <= 0;
          datain_s0 <= 0;
          datain_s1 <= 0;
       end
     else begin
        datain_s0 <= datain;
        datain_s1 <= datain_s0;
        if (datain_s0 != datain_s1)
          count <= 0;
        else if (count[N-1])
          dataout <= datain_s1;
        else
          count <= count + 1;
     end

endmodule
