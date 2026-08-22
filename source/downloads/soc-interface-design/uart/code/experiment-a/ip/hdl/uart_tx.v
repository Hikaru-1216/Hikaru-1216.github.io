//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// Wang Yubo, wangyubo_vlsi@qq.com
//
//---------------------------------------------------------------------------------

module uart_tx
  (
   input wire 	    clk,
   input wire 	    reset_n,

   input wire [9:0] wdata,
   input wire 	    start,

   output reg 	    txd,
   output wire 	    idle
   );

   parameter IDLE = 1'h0;
   parameter DATA = 1'h1;

   reg 		    state, nest_state;
   reg [3:0] 	    send_cnt;

   always @(posedge clk or negedge reset_n)
     if(reset_n == 0)
       state <= IDLE;
     else
       state <= next_state;

   always @(*)
     begin
        case(state)
          IDLE: next_state <= start == 1 ? DATA : IDLE;
          DATA: next_state <= send_cnt == 10 ? IDLE : DATA;
	  default: next_state <= IDLE;
        endcase
     end

   assign idle = (state == IDLE) ? 1 : 0;

   always @(posedge clk or negedge reset_n)
     begin
        if(reset_n == 0)
          begin
             send_cnt <= 0;
             txd <= 1;
          end
        else
          begin
             case(next_state)
               IDLE:
		 begin
                    send_cnt <= 0;
                    txd <= 1;
		 end
               DATA:
		 begin
                    send_cnt <= send_cnt + 1;
                    txd <= wdata[send_cnt];
		 end
             endcase
          end
     end

endmodule
