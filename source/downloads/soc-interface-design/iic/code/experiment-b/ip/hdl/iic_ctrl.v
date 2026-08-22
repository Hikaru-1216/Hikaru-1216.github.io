//---------------------------------------------------------------------------------
//
// IMPORTANT: This document is for use only in the <Embedded System Design>
//
// College of Electrical Engineering, Zhejiang University
//
// zhangpy@vlsi.zju.edu.cn
//
//---------------------------------------------------------------------------------

module iic_ctrl
  (
   input        clk,
   input        reset_n,

   input [9:0]  tx_fifo_input,
   input        tx_fifo_en,
   output       tx_fifo_full,
   output       tx_fifo_empty,

   output [7:0] rx_fifo_output,
   input        rx_fifo_en,
   output       rx_fifo_full,
   output       rx_fifo_empty,

   output       iic_busy,
   output       iic_ackerror,
   output       iic_arbitlost,

   output [2:0] debug_state,
   output [7:0] debug_read_count,
   output [9:0] debug_tx_data,
   output [7:0] debug_iic_addr,
   output [7:0] debug_iic_dataout,
   output       debug_iic_enable,
   output       debug_tx_rd,
   output       debug_rx_wr,

   input        scl_i, sda_i,
   output       scl_o, sda_o,
   output       scl_t, sda_t

   );

   wire         CLK_100K_SCL, CLK_100K_SDA;
   wire         scl_i_clean, sda_i_clean;

   reg          iic_busy_i;
   reg          iic_busy_i_prev, iic_busy_i_now;
   wire         iic_busy_i_posedge, iic_busy_i_negedge;

   wire [9:0]   tx_data_i;
   wire [4:0]   tx_fifo_count;
   wire         tx_command_ready;

   reg          tx_rd, rx_wr;
   reg          final_read_started;
   reg [7:0]    read_count;

   reg [7:0]    iic_addr;
   reg [7:0]    iic_datain;
   wire [7:0]   iic_dataout;
   reg          iic_enable;

   parameter   TX_IDLE  = 3'h1;
   parameter   TX_CMD   = 3'h2;
   parameter   TX_DATA0 = 3'h3;
   parameter   TX_DATA1 = 3'h4;
   parameter   TX_WRITE = 3'h5;
   parameter   RX_READ0 = 3'h6;
   parameter   RX_READ1 = 3'h7;

   reg [2:0]    iic_ctrl_state, iic_ctrl_nextstate;

   // START/address commands need the following data/read-count word to be
   // present before the controller consumes either FIFO entry.
   assign tx_command_ready = (tx_fifo_count != 5'd0) &&
                             (!tx_data_i[8] || (tx_fifo_count >= 5'd2));

   always @(negedge CLK_100K_SCL or negedge reset_n)
     if (~reset_n) iic_busy_i <= 0;
     else iic_busy_i <= iic_busy;

   always @(posedge clk or negedge reset_n)
     if (~reset_n) begin
        iic_busy_i_prev <= 0;
        iic_busy_i_now <= 0;
     end else begin
        iic_busy_i_now <= iic_busy_i;
        iic_busy_i_prev <= iic_busy_i_now;
     end

   assign iic_busy_i_negedge = ~iic_busy_i_now & iic_busy_i_prev;
   assign iic_busy_i_posedge = iic_busy_i_now & ~iic_busy_i_prev;

   always @(posedge clk or negedge reset_n)
     if (~reset_n) iic_ctrl_state <= TX_IDLE;
     else iic_ctrl_state <= iic_ctrl_nextstate;

   always @(*) begin
      iic_ctrl_nextstate <= TX_IDLE;
      case (iic_ctrl_state)
        TX_IDLE  : iic_ctrl_nextstate <= tx_command_ready ? TX_CMD : TX_IDLE;

        TX_CMD   : iic_ctrl_nextstate <= tx_data_i[9] ?
                                          RX_READ0 : tx_data_i[8] ? TX_DATA0 : TX_DATA1;

        TX_DATA0 : iic_ctrl_nextstate <= tx_data_i[9] ? RX_READ0 : TX_DATA1;

        TX_DATA1 : iic_ctrl_nextstate <= iic_busy ? TX_WRITE : TX_DATA1;

        TX_WRITE : iic_ctrl_nextstate <= iic_busy ?
                                         TX_WRITE : tx_command_ready ? TX_CMD : TX_IDLE;

        RX_READ0 : iic_ctrl_nextstate <= read_count ?
                                         (iic_busy_i_posedge ? RX_READ1 : RX_READ0) : TX_IDLE;

        RX_READ1 : iic_ctrl_nextstate <= read_count ? RX_READ1 : TX_IDLE;
      endcase
   end

   always @(posedge clk or negedge reset_n)
     if (~reset_n) begin
        tx_rd <= 0; rx_wr <= 0;
     end else begin
        tx_rd <= 0; rx_wr <= 0;
        // tx_rd is registered; the FIFO consumes it on the next clock edge,
        // after TX_CMD/TX_DATA0 have sampled the current dout value.
        case (iic_ctrl_nextstate)
          TX_CMD   : tx_rd <= 1;
          TX_DATA0 : tx_rd <= 1;
          RX_READ1 : rx_wr <= iic_busy_i_negedge ;
        endcase
     end

   always @(posedge clk or negedge reset_n)
     if (~reset_n) begin
        read_count <= 0;
        iic_addr <= 0;
        iic_datain <= 0;
        iic_enable <= 0;
        final_read_started <= 0;
     end else
       case (iic_ctrl_state)
         TX_IDLE  : begin
            iic_enable <= 0;
            final_read_started <= 0;
         end
         TX_CMD   : begin
            read_count <= tx_data_i[9] ? tx_data_i[7:0] : read_count;
            iic_addr   <= tx_data_i[8] ? tx_data_i[7:0] : iic_addr;
            iic_datain <= (~tx_data_i[8] & ~tx_data_i[9]) ? tx_data_i[7:0] : iic_datain;
         end
         TX_DATA0 : begin
            iic_datain <= tx_data_i[7:0];
            read_count <= tx_data_i[9] ? tx_data_i[7:0] : read_count;
         end
         TX_DATA1 : iic_enable <= 1;
         RX_READ0 : begin
            if (read_count == 1 && iic_busy_i_posedge) begin
               iic_enable <= 0;
               final_read_started <= 1;
            end else begin
               iic_enable <= read_count ? 1 : 0;
               final_read_started <= 0;
            end
         end
         RX_READ1 : begin
            if (read_count > 1) begin
               iic_enable <= 1;
               final_read_started <= 0;
            end else if (read_count == 1) begin
               if (iic_busy_i_posedge) begin
                  iic_enable <= 0;
                  final_read_started <= 1;
               end else begin
                  iic_enable <= final_read_started ? 0 : 1;
               end
            end else begin
               iic_enable <= 0;
               final_read_started <= 0;
            end
            read_count <= iic_busy_i_negedge ? (read_count - 1) : read_count;
         end
       endcase

   iic_clkgen u_iic_clkgen_01
     (
      .clk(clk),
      .reset_n(reset_n),
      .CLK_100K_SDA(CLK_100K_SDA),
      .CLK_100K_SCL(CLK_100K_SCL)
      );

   iic_fifo  #( .WIDTH(10), .DEPTH(16), .COUNT(4) ) u_tx_fifo_01
     (
      .dout(tx_data_i),
      .data_count(tx_fifo_count),
      .empty(tx_fifo_empty),
      .full(tx_fifo_full),
      .din(tx_fifo_input),
      .wr_en(tx_fifo_en),
      .rd_en(tx_rd),
      .reset_n(reset_n),
      .clk(clk)
      );

   iic_fifo  #( .WIDTH(8), .DEPTH(16), .COUNT(4) ) u_rx_fifo_01
     (
      .dout(rx_fifo_output),
      .data_count(),
      .empty(rx_fifo_empty),
      .full(rx_fifo_full),
      .din(iic_dataout),
      .wr_en(rx_wr),
      .rd_en(rx_fifo_en),
      .reset_n(reset_n),
      .clk(clk)
      );

   debounce u_debounce_scl_01
     (
      .clk(clk),
      .reset_n(reset_n),
      .datain(scl_i),
      .dataout(scl_i_clean)
      );

   debounce u_debounce_sda_01
     (
      .clk(clk),
      .reset_n(reset_n),
      .datain(sda_i),
      .dataout(sda_i_clean)
      );

   iic_core u_iic_core_01
     (
      .CLK_100K_SDA(CLK_100K_SDA),
      .CLK_100K_SCL(CLK_100K_SCL),
      .reset_n(reset_n),
      .iic_addr(iic_addr),
      .iic_datain(iic_datain),
      .iic_dataout(iic_dataout),
      .iic_enable(iic_enable),
      .iic_busy(iic_busy),
      .iic_ackerror(iic_ackerror),
      .iic_arbitlost(iic_arbitlost),
      .scl_i(scl_i_clean), .scl_o(scl_o), .scl_t(scl_t),
      .sda_i(sda_i_clean), .sda_o(sda_o), .sda_t(sda_t)
      );

   assign debug_state = iic_ctrl_state;
   assign debug_read_count = read_count;
   assign debug_tx_data = tx_data_i;
   assign debug_iic_addr = iic_addr;
   assign debug_iic_dataout = iic_dataout;
   assign debug_iic_enable = iic_enable;
   assign debug_tx_rd = tx_rd;
   assign debug_rx_wr = rx_wr;

endmodule
