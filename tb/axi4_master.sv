`timescale 1ns / 1ps

module axi4_master #(
    parameter int DATA_W    = 32,           
    parameter int ADDR_W    = 16,           
    parameter int ID_W      = 8,            
    parameter int STRB_W    = DATA_W/8,     
    parameter int MAX_BEATS = 256           
)
(
    input  wire                 ACLK,
    input  wire                 ARESETn,

    // --- Write address channel ---
    output wire [ID_W-1:0]      AWID,
    output wire [ADDR_W-1:0]    AWADDR,
    output wire [3:0]           AWREGION,
    output wire [7:0]           AWLEN,
    output wire [2:0]           AWSIZE,
    output wire [1:0]           AWBURST,
    output wire                 AWLOCK,
    output wire [3:0]           AWCACHE,
    output wire [2:0]           AWPROT,
    output wire [3:0]           AWQOS,
    output wire                 AWVALID,
    input  wire                 AWREADY,

    // --- Write data channel ---
    output wire [DATA_W-1:0]    WDATA,
    output wire [STRB_W-1:0]    WSTRB,
    output wire                 WLAST,
    output wire                 WVALID,
    input  wire                 WREADY,

    // --- Write response channel ---
    input  wire [ID_W-1:0]      BID,
    input  wire [1:0]           BRESP,
    input  wire                 BVALID,
    output wire                 BREADY,

    // --- Read address channel ---
    output wire [ID_W-1:0]      ARID,
    output wire [ADDR_W-1:0]    ARADDR,
    output wire [3:0]           ARREGION,
    output wire [7:0]           ARLEN,
    output wire [2:0]           ARSIZE,
    output wire [1:0]           ARBURST,
    output wire                 ARLOCK,
    output wire [3:0]           ARCACHE,
    output wire [2:0]           ARPROT,
    output wire [3:0]           ARQOS,
    output wire                 ARVALID,
    input  wire                 ARREADY,

    // --- Read data channel ---
    input  wire [ID_W-1:0]      RID,
    input  wire [DATA_W-1:0]    RDATA,
    input  wire [1:0]           RRESP,
    input  wire                 RLAST,
    input  wire                 RVALID,
    output wire                 RREADY
);

    // Instancja BFM mastera AXI4 z biblioteki Riviera-PRO (Aldec)
    Ax_Axi4MasterBFM #(
        .DATA_BUS_WIDTH (DATA_W),
        .ADDRESS_WIDTH  (ADDR_W),
        .ID_WIDTH       (ID_W)
    ) bfm (
        .ACLK     (ACLK),
        .ARESETn  (ARESETn),
        .AWID     (AWID),      .AWADDR   (AWADDR),   .AWREGION (AWREGION),
        .AWLEN    (AWLEN),     .AWSIZE   (AWSIZE),   .AWBURST  (AWBURST),
        .AWLOCK   (AWLOCK),    .AWCACHE  (AWCACHE),  .AWPROT   (AWPROT),
        .AWQOS    (AWQOS),     .AWVALID  (AWVALID),  .AWREADY  (AWREADY),
        .WDATA    (WDATA),     .WSTRB    (WSTRB),    .WLAST    (WLAST),
        .WVALID   (WVALID),    .WREADY   (WREADY),
        .BID      (BID),       .BRESP    (BRESP),    .BVALID   (BVALID),  .BREADY (BREADY),
        .ARID     (ARID),      .ARADDR   (ARADDR),   .ARREGION (ARREGION),
        .ARLEN    (ARLEN),     .ARSIZE   (ARSIZE),   .ARBURST  (ARBURST),
        .ARLOCK   (ARLOCK),    .ARCACHE  (ARCACHE),  .ARPROT   (ARPROT),
        .ARQOS    (ARQOS),     .ARVALID  (ARVALID),  .ARREADY  (ARREADY),
        .RID      (RID),       .RDATA    (RDATA),    .RRESP    (RRESP),
        .RLAST    (RLAST),     .RVALID   (RVALID),   .RREADY   (RREADY)
    );

    localparam [1:0] BURST_INCR = 2'b01;
    localparam [2:0] BEAT_SIZE  = 3'($clog2(STRB_W));   

    logic [DATA_W-1:0] rbuf [0:MAX_BEATS-1];

    task automatic read_burst (
        input [ADDR_W-1:0] start_addr,
        input int          beats
    );
        logic [ID_W-1:0]   rid;
        logic [1:0]        rresp;
        logic [DATA_W-1:0] rdata;
        logic              rlast;
        logic [0:0]        ruser;
        int                k;
        begin
            bfm.BfmReadAddress('0, start_addr, 4'h0, 8'(beats-1), BEAT_SIZE, BURST_INCR, 1'b0, 4'h0, 3'h0, 4'h0, 1'b0);
            for (k = 0; k < beats; k++) begin
                bfm.BfmWaitForReadResponse(rid, rresp, rdata, rlast, ruser);
                rbuf[k] = rdata;
            end
        end
    endtask

    task automatic write_burst (
        input [ADDR_W-1:0] start_addr,
        input int          beats,
        ref   [DATA_W-1:0] wdata_arr [0:MAX_BEATS-1]
    );
        logic [ID_W-1:0] bid;
        logic [1:0]      bresp;
        logic [0:0]      buser;
        int              k;
        begin
            bfm.BfmWriteAddress('0, start_addr, 4'h0, 8'(beats-1), BEAT_SIZE, BURST_INCR, 1'b0, 4'h0, 3'h0, 4'h0, 1'b0);
            for (k = 0; k < beats; k++) begin
                bfm.BfmWriteData(wdata_arr[k], {STRB_W{1'b1}}, (k == beats-1), 1'b0);
            end
            bfm.BfmWaitForWriteResponse(bid, bresp, buser);
        end
    endtask

endmodule