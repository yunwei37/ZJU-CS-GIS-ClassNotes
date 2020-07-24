`timescale 1ns / 1ps

module test_CPU(

    );

reg clk, rst;
wire en;
wire [31:0] data_in, inst_in, wt_mem_data;
wire [31:0] data_addr, PC_ID;

Pipeline_CPU pCPU(
    .clk(clk),
    .reset(rst),
    .data_in(data_in),
    .inst_in(inst_in),
    .PC_out(PC_ID),
    .mem_w(en),
    .data_out(wt_mem_data),
    .addr_out(data_addr)    
);

mem d_RAM(
    .addra(data_addr[12:2]),
    .dina(wt_mem_data),
    .addrb(PC_ID[12:2]),
    .wea(en),
    .clka(clk),
	 .clkb(clk),
    .douta(data_in),
    .doutb(inst_in)
);

initial begin clk = 0; rst = 1; end
initial forever #50 clk = ~clk;
initial #500 rst = 0;
endmodule
