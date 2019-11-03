`default_nettype none

`timescale 1 ns / 1 ps

module pulse_generator #
  (
   parameter integer C_S00_AXI_DATA_WIDTH = 32,
   parameter integer C_S00_AXI_ADDR_WIDTH = 4
   )
   (
    // Users to add ports here
    output wire [31:0] 				addr,
    input wire [31:0] 				din,
    output wire 				en,
    output wire 				Q,
    
    input wire 					s00_axi_aclk,
    input wire 					s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] 	s00_axi_awaddr,
    input wire [2 : 0] 				s00_axi_awprot,
    input wire 					s00_axi_awvalid,
    output wire 				s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] 	s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire 					s00_axi_wvalid,
    output wire 				s00_axi_wready,
    output wire [1 : 0] 			s00_axi_bresp,
    output wire 				s00_axi_bvalid,
    input wire 					s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] 	s00_axi_araddr,
    input wire [2 : 0] 				s00_axi_arprot,
    input wire 					s00_axi_arvalid,
    output wire 				s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] 	s00_axi_rdata,
    output wire [1 : 0] 			s00_axi_rresp,
    output wire 				s00_axi_rvalid,
    input wire 					s00_axi_rready
    );

   wire [31:0] 					slv_reg0_o;
   wire [31:0] 					slv_reg1_i;
   wire [31:0] 					slv_reg2_o;
   wire [31:0] 					slv_reg3_o;

   pulse_generator_S00_AXI #( .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
			      .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
			      ) pulse_generator_S00_AXI_i
     (
      .S_AXI_ACLK(s00_axi_aclk),
      .S_AXI_ARESETN(s00_axi_aresetn),
      .S_AXI_AWADDR(s00_axi_awaddr),
      .S_AXI_AWPROT(s00_axi_awprot),
      .S_AXI_AWVALID(s00_axi_awvalid),
      .S_AXI_AWREADY(s00_axi_awready),
      .S_AXI_WDATA(s00_axi_wdata),
      .S_AXI_WSTRB(s00_axi_wstrb),
      .S_AXI_WVALID(s00_axi_wvalid),
      .S_AXI_WREADY(s00_axi_wready),
      .S_AXI_BRESP(s00_axi_bresp),
      .S_AXI_BVALID(s00_axi_bvalid),
      .S_AXI_BREADY(s00_axi_bready),
      .S_AXI_ARADDR(s00_axi_araddr),
      .S_AXI_ARPROT(s00_axi_arprot),
      .S_AXI_ARVALID(s00_axi_arvalid),
      .S_AXI_ARREADY(s00_axi_arready),
      .S_AXI_RDATA(s00_axi_rdata),
      .S_AXI_RRESP(s00_axi_rresp),
      .S_AXI_RVALID(s00_axi_rvalid),
      .S_AXI_RREADY(s00_axi_rready),

      .slv_reg0_o(slv_reg0_o),
      .slv_reg1_i(slv_reg1_i),
      .slv_reg2_o(slv_reg2_o),
      .slv_reg3_o(slv_reg3_o)      
      );
   
   wire [31:0] periodic_times;
   wire [31:0] bit_cycles;
   wire        kick;
   wire        sw_reset;
   wire        busy;
   wire        clk;
   wire        reset;

   assign clk = s00_axi_aclk;
   assign reset = ~s00_axi_aresetn;
   
   pulse_generator_kernel pulse_generator_kernel_i
     (
      .clk(clk),
      .reset(reset),
      .kick(kick),
      .busy(busy),
      .sw_reset(sw_reset),
      .periodic_times(periodic_times),
      .bit_cycles(bit_cycles),
      .addr(addr),
      .din(din),
      .en(en),
      .Q(Q)
      );
   assign periodic_times = slv_reg2_o;
   assign bit_cycles = slv_reg3_o;

   assign kick = slv_reg0_o[0];
   assign sw_reset = slv_reg0_o[1];

   assign slv_reg1_i[0] = busy;

endmodule

`default_nettype wire
