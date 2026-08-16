`timescale 1ns/1ps

module tb_iic_ctrl_slow;
   reg clk = 1'b0;
   reg reset_n = 1'b0;

   reg [9:0] tx_fifo_input = 10'b0;
   reg tx_fifo_en = 1'b0;
   reg rx_fifo_en = 1'b0;

   wire [7:0] rx_fifo_output;
   wire tx_fifo_full;
   wire tx_fifo_empty;
   wire rx_fifo_full;
   wire rx_fifo_empty;
   wire iic_busy;
   wire iic_ackerror;
   wire iic_arbitlost;
   wire scl_i;
   wire sda_i;
   wire scl_o;
   wire sda_o;
   wire scl_t;
   wire sda_t;
   wire scl;
   wire sda;

   integer timeout;

   always #10 clk = ~clk;

   pullup p1(scl);
   pullup p2(sda);

   assign scl = scl_t ? scl_o : 1'bz;
   assign sda = sda_t ? sda_o : 1'bz;
   assign scl_i = scl;
   assign sda_i = sda;

   M24AA02 eeprom (
      .A0(1'b0),
      .A1(1'b0),
      .A2(1'b0),
      .WP(1'b0),
      .SDA(sda),
      .SCL(scl),
      .RESET(!reset_n)
   );

   iic_ctrl dut (
      .clk(clk),
      .reset_n(reset_n),
      .tx_fifo_input(tx_fifo_input),
      .tx_fifo_en(tx_fifo_en),
      .tx_fifo_full(tx_fifo_full),
      .tx_fifo_empty(tx_fifo_empty),
      .rx_fifo_output(rx_fifo_output),
      .rx_fifo_en(rx_fifo_en),
      .rx_fifo_full(rx_fifo_full),
      .rx_fifo_empty(rx_fifo_empty),
      .iic_busy(iic_busy),
      .iic_ackerror(iic_ackerror),
      .iic_arbitlost(iic_arbitlost),
      .scl_i(scl_i),
      .sda_i(sda_i),
      .scl_o(scl_o),
      .sda_o(sda_o),
      .scl_t(scl_t),
      .sda_t(sda_t)
   );

   task push_tx_gap;
      input [9:0] data;
      input integer gap_cycles;
      integer i;
      begin
         @(posedge clk);
         tx_fifo_input <= data;
         tx_fifo_en <= 1'b1;
         @(posedge clk);
         tx_fifo_en <= 1'b0;
         tx_fifo_input <= 10'b0;
         for (i = 0; i < gap_cycles; i = i + 1) begin
            @(posedge clk);
         end
      end
   endtask

   initial begin
      #200;
      reset_n = 1'b1;

      push_tx_gap(10'h1A0, 500);  // START + EEPROM write address
      push_tx_gap(10'h010, 500);  // memory address
      push_tx_gap(10'h05A, 500);  // payload
      push_tx_gap(10'h200, 500);  // STOP

      #6000000;

      push_tx_gap(10'h1A0, 500);  // START + EEPROM write address
      push_tx_gap(10'h010, 500);  // memory address
      push_tx_gap(10'h1A1, 500);  // repeated START + EEPROM read address
      push_tx_gap(10'h201, 500);  // read one byte, then STOP

      timeout = 20000000;
      while (timeout > 0 && rx_fifo_empty) begin
         @(posedge clk);
         timeout = timeout - 1;
      end

      if (rx_fifo_empty) begin
         $display("FAIL slow rx_fifo_empty ack=%0d arbit=%0d busy=%0d tx_empty=%0d tx_full=%0d",
                  iic_ackerror, iic_arbitlost, iic_busy, tx_fifo_empty, tx_fifo_full);
      end else if (rx_fifo_output != 8'h5A) begin
         $display("FAIL slow rx=0x%02h expected=0x5a ack=%0d arbit=%0d",
                  rx_fifo_output, iic_ackerror, iic_arbitlost);
      end else begin
         $display("PASS slow rx=0x%02h ack=%0d arbit=%0d", rx_fifo_output,
                  iic_ackerror, iic_arbitlost);
      end

      #1000;
      $finish;
   end
endmodule
