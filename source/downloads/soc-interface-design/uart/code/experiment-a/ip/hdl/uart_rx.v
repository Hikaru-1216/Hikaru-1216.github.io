//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// Wang Yubo, wangyubo_vlsi@qq.com
//
//---------------------------------------------------------------------------------

module uart_rx
  (
   input wire 	    clk,
   input wire 	    reset_n,
   input wire 	    rxd,
   output reg [7:0] rdata,
   output reg 	    ren
   );

   parameter IDLE = 1'h0;
   parameter DATA = 1'h1;

   reg 		    state, next_state;
   reg [3:0] 	    recv_cnt;

   always @(posedge clk or negedge reset_n)
     if(reset_n == 0)
       state <= IDLE;
     else
       state <= next_state;

   always @(*)
     begin
        case(state)
          IDLE: next_state <= rxd == 0 ? DATA : IDLE;
          DATA: next_state <= recv_cnt == 9 ? IDLE : DATA;
          default: next_state <= IDLE;
        endcase
     end

   always @(posedge clk or negedge reset_n)
     begin
        if(reset_n == 0)
          begin
             rdata <= 8'd0;
             ren <= 0;
             recv_cnt <= 0;
          end
        else
          begin
             case(next_state)
               IDLE:
		 begin
                    rdata <= 8'd0;
                    ren <= 0;
                    recv_cnt <= 0;
		 end
               DATA:
		 begin
                    recv_cnt <= recv_cnt + 1;
                    if(recv_cnt >= 1 && recv_cnt <= 8)
                      rdata[recv_cnt-1] = rxd;
                    if(recv_cnt == 8)
                      ren <= 1;
                    else
                      ren <= 0;
		 end
             endcase
          end
     end

endmodule
