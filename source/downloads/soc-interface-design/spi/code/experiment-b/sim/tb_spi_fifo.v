`timescale 1 ns / 100 ps

module spi_fifo_tb();

   reg [7:0] data_in;
   reg       wr_en;
   reg       rd_en;
   reg       reset_n;
   reg       clk;
   reg 	     clean_fifo;

   wire [7:0] dout;
   wire [4:0] data_count;
   wire       empty;
   wire       full;

   reg [7:0]  test_vec;

   spi_fifo UUT (
                 .dout(dout),
                 .data_count(data_count),
                 .empty(empty),
                 .full(full),
                 .din(data_in),
                 .wr_en(wr_en),
                 .rd_en(rd_en),
		 .clean_fifo(clean_fifo),
                 .reset_n(reset_n),
                 .clk(clk)
                 );

   initial begin
      clk = 1'b 0;
      data_in = 24'b 0;
      wr_en = 1'b 0;
      rd_en = 1'b 0;
      clean_fifo = 1'b0;
      reset_n = 1'b 0;
   end

   always  #10 clk = ~clk;

   always  begin

      #30  reset_n = 1'b 1;

      // write to fifo
      for(test_vec=0; test_vec < 22; test_vec = test_vec + 1)
        begin
           #20  wr_en = 1'b 1;
           data_in = test_vec;
           #20  wr_en = 1'b 0;
        end

      #20 clean_fifo = 1;
      #20 clean_fifo = 0;

      // read from fifo
      for(test_vec=0; test_vec < 22; test_vec = test_vec + 1)
        begin
           #20  rd_en = 1'b 1;
           #20  rd_en = 1'b 0;
        end

      #20 clean_fifo = 1;
      #20 clean_fifo = 0;

      // write to fifo
      for(test_vec=0; test_vec < 15; test_vec = test_vec + 1)
        begin
           #20  wr_en = 1'b 1;
           data_in = test_vec;
           #20  wr_en = 1'b 0;
        end

      // read from fifo
      for(test_vec=0; test_vec < 11; test_vec = test_vec + 1)
        begin
           #20  rd_en = 1'b 1;
           #20  rd_en = 1'b 0;
        end

      // read and write to fifo
      for(test_vec=0; test_vec < 11; test_vec = test_vec + 1)
        begin
           #20  rd_en = 1'b 1;
           wr_en = 1'b 1;
           data_in = test_vec;
           #20 rd_en = 1'b 0;
           wr_en = 1'b 0;
        end

      // read from fifo
      for(test_vec=0; test_vec < 7; test_vec = test_vec + 1)
        begin
           #20  rd_en = 1'b 1;
           #20  rd_en = 1'b 0;
        end

      // write to fifo
      for(test_vec=0; test_vec < 13; test_vec = test_vec + 1)
        begin
           #20  wr_en = 1'b 1;
           data_in = test_vec;
           #20  wr_en = 1'b 0;
        end


   end

endmodule
