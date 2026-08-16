`timescale 1 ns / 1 ps

module IIC_ZJU_SOC_v1_0_S00_AXI #
(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
    // Users to add ports here
    inout wire scl,
    inout wire sda,
    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, accepted by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid.
    input wire  S_AXI_AWVALID,
    // Write address ready.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, accepted by Slave)
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes.
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid.
    input wire  S_AXI_WVALID,
    // Write ready.
    output wire  S_AXI_WREADY,
    // Write response.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid.
    output wire  S_AXI_BVALID,
    // Response ready.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, accepted by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid.
    input wire  S_AXI_ARVALID,
    // Read address ready.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid.
    output wire  S_AXI_RVALID,
    // Read ready.
    input wire  S_AXI_RREADY
);

    // -------------------------------------------------------------------------
    // AXI4-Lite signals
    // -------------------------------------------------------------------------
    reg axi_awready;
    reg axi_wready;
    reg [1:0] axi_bresp;
    reg axi_bvalid;
    reg axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
    reg [1:0] axi_rresp;
    reg axi_rvalid;
    reg aw_en;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1; // 2 for 32-bit data
    localparam integer OPT_MEM_ADDR_BITS = 1;                  // 4 registers

    // Internal 4-register map, following the lab video/PPT:
    // 0x00 -> TX_FIFO, 0x04 -> RX_FIFO, 0x08 -> SR, 0x0C -> debug/CR.
    localparam [1:0] REG_TX_FIFO = 2'h0; // offset 0x00
    localparam [1:0] REG_RX_FIFO = 2'h1; // offset 0x04
    localparam [1:0] REG_SR      = 2'h2; // offset 0x08
    localparam [1:0] REG_CR      = 2'h3; // offset 0x0C, currently reserved

    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0; // CR write shadow, offset 0x0C
    reg [9:0] last_tx_data;              // debug/readback copy of last TX_FIFO write
    reg tx_push_en;
    reg [9:0] tx_push_data;
    reg [10:0] debug_seen;
    reg [7:0] debug_last_iic_addr;
    reg [7:0] debug_last_read_count;
    reg [2:0] debug_last_state;
    integer byte_index;

    wire [1:0] write_addr = S_AXI_AWADDR[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
    wire [1:0] read_addr  = S_AXI_ARADDR[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];

    wire write_fire = (~axi_awready) && S_AXI_AWVALID && S_AXI_WVALID && aw_en;
    wire read_fire  = (~axi_arready) && S_AXI_ARVALID && (~axi_rvalid);

    // -------------------------------------------------------------------------
    // IIC core interface
    // -------------------------------------------------------------------------
    wire [7:0] rx_fifo_output;
    wire tx_fifo_full;
    wire tx_fifo_empty;
    wire rx_fifo_full;
    wire rx_fifo_empty;
    wire iic_busy;
    wire iic_ackerror;
    wire iic_arbitlost;
    wire [2:0] debug_state;
    wire [7:0] debug_read_count;
    wire [9:0] debug_tx_data;
    wire [7:0] debug_iic_addr;
    wire [7:0] debug_iic_dataout;
    wire debug_iic_enable;
    wire debug_tx_rd;
    wire debug_rx_wr;

    wire scl_i;
    wire sda_i;
    wire scl_o;
    wire sda_o;
    wire scl_t;
    wire sda_t;

    wire write_to_tx_fifo = write_fire && (write_addr == REG_TX_FIFO) && !tx_fifo_full;
    wire read_from_rx_fifo = read_fire && (read_addr == REG_RX_FIFO) && !rx_fifo_empty;
    wire debug_clear = write_fire && (write_addr == REG_CR) && S_AXI_WDATA[0];

    // Status register, compatible with the usual AXI-IIC status-bit style used in the lab:
    // bit[7] TX FIFO empty
    // bit[6] RX FIFO empty
    // bit[5] RX FIFO full
    // bit[4] TX FIFO full
    // bit[3] SDA sampled value
    // bit[2] SCL sampled value
    // bit[1] IIC busy
    // bit[0] error = ACK error OR arbitration lost
    wire [C_S_AXI_DATA_WIDTH-1:0] status_reg = {
        {(C_S_AXI_DATA_WIDTH-8){1'b0}},
        tx_fifo_empty,
        rx_fifo_empty,
        rx_fifo_full,
        tx_fifo_full,
        sda_i,
        scl_i,
        iic_busy,
        (iic_ackerror | iic_arbitlost)
    };

    // Debug register at 0x0C:
    // [31:24] last non-idle IIC address, [23:16] last read_count,
    // [15:13] last non-idle controller state, [10:0] sticky event flags:
    // bit0 AXI wrote TX FIFO, bit1 TX FIFO popped, bit2 IIC busy seen,
    // bit3 iic_enable seen, bit4 RX_READ0 seen, bit5 RX_READ1 seen,
    // bit6 RX FIFO write seen, bit7 ACK error seen, bit8 arbitration lost seen,
    // bit9 TX FIFO non-empty seen, bit10 TX FIFO full seen.
    wire [C_S_AXI_DATA_WIDTH-1:0] debug_status_reg = {
        debug_last_iic_addr,
        debug_last_read_count,
        debug_last_state,
        2'b00,
        debug_seen
    };

    // The iic_core in the provided RTL uses scl_t/sda_t = 1 to drive the line,
    // and scl_t/sda_t = 0 to release the line. Xilinx IOBUF uses T=1 for input
    // high-Z and T=0 for output, so T must be inverted here.
    IOBUF #(
        .DRIVE(12),
        .IBUF_LOW_PWR("TRUE"),
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW")
    ) IOBUF_scl_inst (
        .O(scl_i),
        .IO(scl),
        .I(scl_o),
        .T(!scl_t)
    );

    IOBUF #(
        .DRIVE(12),
        .IBUF_LOW_PWR("TRUE"),
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW")
    ) IOBUF_sda_inst (
        .O(sda_i),
        .IO(sda),
        .I(sda_o),
        .T(!sda_t)
    );

    iic_ctrl u_iic_ctrl (
        .clk(S_AXI_ACLK),
        .reset_n(S_AXI_ARESETN),

        .tx_fifo_input(tx_push_data),
        .tx_fifo_en(tx_push_en),
        .tx_fifo_full(tx_fifo_full),
        .tx_fifo_empty(tx_fifo_empty),

        .rx_fifo_output(rx_fifo_output),
        .rx_fifo_en(read_from_rx_fifo),
        .rx_fifo_full(rx_fifo_full),
        .rx_fifo_empty(rx_fifo_empty),

        .iic_busy(iic_busy),
        .iic_ackerror(iic_ackerror),
        .iic_arbitlost(iic_arbitlost),

        .debug_state(debug_state),
        .debug_read_count(debug_read_count),
        .debug_tx_data(debug_tx_data),
        .debug_iic_addr(debug_iic_addr),
        .debug_iic_dataout(debug_iic_dataout),
        .debug_iic_enable(debug_iic_enable),
        .debug_tx_rd(debug_tx_rd),
        .debug_rx_wr(debug_rx_wr),

        .scl_i(scl_i),
        .sda_i(sda_i),
        .scl_o(scl_o),
        .sda_o(sda_o),
        .scl_t(scl_t),
        .sda_t(sda_t)
    );

    // -------------------------------------------------------------------------
    // AXI write address/data handshake
    // -------------------------------------------------------------------------
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awready <= 1'b0;
            axi_wready  <= 1'b0;
            aw_en       <= 1'b1;
        end else begin
            if (write_fire) begin
                axi_awready <= 1'b1;
                axi_wready  <= 1'b1;
                aw_en       <= 1'b0;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_awready <= 1'b0;
                axi_wready  <= 1'b0;
                aw_en       <= 1'b1;
            end else begin
                axi_awready <= 1'b0;
                axi_wready  <= 1'b0;
            end
        end
    end

    // Writable control register. TX_FIFO writes are handled by write_to_tx_fifo.
    // Lab video/PPT map: write offset 0x00 to push TX_FIFO.
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg0 <= {C_S_AXI_DATA_WIDTH{1'b0}};
            last_tx_data <= 10'b0;
            tx_push_en <= 1'b0;
            tx_push_data <= 10'b0;
        end else begin
            tx_push_en <= 1'b0;

            if (write_to_tx_fifo) begin
                last_tx_data <= S_AXI_WDATA[9:0];
                tx_push_data <= S_AXI_WDATA[9:0];
                tx_push_en <= 1'b1;
            end

            if (write_fire && (write_addr == REG_CR)) begin
                for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index + 1) begin
                    if (S_AXI_WSTRB[byte_index] == 1'b1) begin
                        slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                end
            end
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0 || debug_clear) begin
            debug_seen <= 11'b0;
            debug_last_iic_addr <= 8'b0;
            debug_last_read_count <= 8'b0;
            debug_last_state <= 3'b0;
        end else begin
            debug_seen[0] <= debug_seen[0] | tx_push_en;
            debug_seen[1] <= debug_seen[1] | debug_tx_rd;
            debug_seen[2] <= debug_seen[2] | iic_busy;
            debug_seen[3] <= debug_seen[3] | debug_iic_enable;
            debug_seen[4] <= debug_seen[4] | (debug_state == 3'h6);
            debug_seen[5] <= debug_seen[5] | (debug_state == 3'h7);
            debug_seen[6] <= debug_seen[6] | debug_rx_wr;
            debug_seen[7] <= debug_seen[7] | iic_ackerror;
            debug_seen[8] <= debug_seen[8] | iic_arbitlost;
            debug_seen[9] <= debug_seen[9] | !tx_fifo_empty;
            debug_seen[10] <= debug_seen[10] | tx_fifo_full;

            if (debug_state != 3'h1) begin
                debug_last_iic_addr <= debug_iic_addr;
                debug_last_read_count <= debug_read_count;
                debug_last_state <= debug_state;
            end
        end
    end

    // Write response channel
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_bvalid <= 1'b0;
            axi_bresp  <= 2'b00;
        end else begin
            if (write_fire && ~axi_bvalid) begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b00; // OKAY
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // AXI read address/data channel
    // -------------------------------------------------------------------------
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
            axi_rresp   <= 2'b00;
            axi_rdata   <= {C_S_AXI_DATA_WIDTH{1'b0}};
        end else begin
            if (read_fire) begin
                axi_arready <= 1'b1;
                axi_rvalid  <= 1'b1;
                axi_rresp   <= 2'b00; // OKAY

                case (read_addr)
                    REG_CR:      axi_rdata <= debug_status_reg;
                    REG_SR:      axi_rdata <= status_reg;
                    REG_TX_FIFO: axi_rdata <= {22'b0, last_tx_data}; // debug/readback only; TX FIFO is write-only in normal use
                    REG_RX_FIFO: axi_rdata <= {24'b0, rx_fifo_output};
                    default:     axi_rdata <= {C_S_AXI_DATA_WIDTH{1'b0}};
                endcase
            end else begin
                axi_arready <= 1'b0;
                if (axi_rvalid && S_AXI_RREADY) begin
                    axi_rvalid <= 1'b0;
                end
            end
        end
    end

endmodule
