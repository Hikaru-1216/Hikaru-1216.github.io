//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module spi_fifo
  #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter COUNT = 4
    )(
       input 		    clk,
       input 		    reset_n,

       input [WIDTH-1:0]    din,
       input 		    wr_en,
       input 		    rd_en,
       input 		    clean_fifo,

       output [WIDTH-1:0]   dout,
       output 		    full,
       output 		    empty,
       output reg [COUNT:0] data_count
       );

   reg [WIDTH-1:0] 	    FIFO_MEM[DEPTH-1:0];
   reg [COUNT-1:0] 	    wr_point, rd_point;

   assign dout = FIFO_MEM[rd_point];

   always @(posedge clk or negedge reset_n)
     begin
        if (~reset_n | clean_fifo)
          begin
             data_count  <= 0;
             wr_point <= 1'b0;
             rd_point <= 1'b0;
          end
        else case ({wr_en,rd_en})
	       2'b01:
		 begin
                    rd_point <= rd_point+1;
                    if (data_count == 0) data_count <= DEPTH-1; else
                      data_count <= data_count-1;
		 end
	       2'b10:
		 begin
                    FIFO_MEM[wr_point] <= din;
                    wr_point  <= wr_point+1;
                    if (data_count == DEPTH) data_count <=1; else
                      data_count <= data_count+1;
		 end
	       2'b11:
		 begin
                    FIFO_MEM[wr_point] <= din;
                    wr_point  <= wr_point+1;
                    rd_point <= rd_point+1;
		 end
             endcase
     end

   assign full = (data_count == DEPTH) ? 1 : 0;
   assign empty = data_count ? 0 : 1;

endmodule
