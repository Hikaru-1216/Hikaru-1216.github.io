//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

`timescale 1ns / 1ps

module tb_de(
             );

   reg clk, reset_n, datain;

   wire dataout;

   debounce UUT(
                .clk(clk),
                .reset_n(reset_n),
                .datain(datain),
                .dataout(dataout)
                );

   initial begin
      reset_n = 1'b0;
      clk = 1'b0;
      datain = 1'b0;
      #200 reset_n = 1'b1;
   end

   always  #10 clk = ~clk;

   always begin
      #40000 datain = 1'b1;
      #400   datain = 1'b0;
      #800   datain = 1'b1;
      #800   datain = 1'b0;
      #800   datain = 1'b1;
      #40000 datain = 1'b0;
      #4000  datain = 1'b1;
      #40000 datain = 1'b0;
      #400   datain = 1'b1;
      #800   datain = 1'b0;
      #800   datain = 1'b1;
      #800   datain = 1'b0;
      #40000 datain = 1'b1;
      #4000  datain = 1'b0;
   end

endmodule
