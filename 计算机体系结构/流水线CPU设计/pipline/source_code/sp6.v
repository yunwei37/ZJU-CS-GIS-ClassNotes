/////////////////////////////////////////////////////////////////////////////
//工程硬件平台： Xilinx Spartan 6 FPGA
//开发套件型号： SF-SP6 特权打造
//版   权  申   明： 本例程由《深入浅出玩转FPGA》作者“特权同学”原创，
//				仅供SF-SP6开发套件学习使用，谢谢支持
//官方淘宝店铺： http://myfpga.taobao.com/
//最新资料下载： 百度网盘 http://pan.baidu.com/s/1jGjAhEm
//公                司： 上海或与电子科技有限公司
///////////////////////////////////////////////////////////////////////////////产生一个每秒递增的16bit数据以16进制方式显示在4位数码管上
module sp6(
			input ext_clk_25m,	//外部输入25MHz时钟信号
			input ext_rst_n,	//外部输入复位信号，低电平有效
			input [3:0] switch,
			output[3:0] dtube_cs_n,	//7段数码管位选信号
			output[7:0] dtube_data,	//7段数码管段选信号（包括小数点为8段）
			output[7:0] led
		);													

//-------------------------------------
//PLL例化
wire clk_12m5;	//PLL输出12.5MHz时钟
wire clk_25m;	//PLL输出25MHz时钟
wire clk_50m;	//PLL输出50MHz时钟
wire clk_100m;	//PLL输出100MHz时钟
wire sys_rst_n;	//PLL输出的locked信号，作为FPGA内部的复位信号，低电平复位，高电平正常工作

  pll_controller uut_pll_controller
   (// Clock in ports
    .CLK_IN1(ext_clk_25m),      // IN
    // Clock out ports
    .CLK_OUT1(clk_12m5),     // OUT
    .CLK_OUT2(clk_25m),     // OUT
    .CLK_OUT3(clk_50m),     // OUT
    .CLK_OUT4(clk_100m),     // OUT
    // Status and control signals
    .RESET(~ext_rst_n),// IN
    .LOCKED(sys_rst_n));      // OUT		
		
/*-----------------------------------------cpu--------------*/		

wire clk, rst;
assign clk = clk_1s;
//assign clk =  ext_clk_25m;

wire clk_1s;
wire en;
wire [31:0] data_in, inst_in, wt_mem_data;
wire [31:0] data_addr, PC_ID;
wire stall,dstall;

assign led[0] = ~clk_1s;
assign led[1] = ~rst;
assign led[2] = ~en;
assign led[3] = ~stall;
assign led[4] = ~dstall;
assign led[7:5] = 3'b111;

assign rst = ~ext_rst_n;

Pipeline_CPU pCPU(
    .clk(clk),
    .reset(rst),
    .data_in(data_in),
    .inst_in(inst_in),
    .PC_out(PC_ID),
    .mem_w(en),
    .data_out(wt_mem_data),
    .addr_out(data_addr),
		.stall(stall),
		.data_stall(dstall)
);

mem d_RAM(
    .addra(data_addr[11:2]),
    .dina(wt_mem_data),
	 .dinb(32'b0),
    .addrb(PC_ID[11:2]),
    .wea(en),
	 .web(1'b0),
    .clka(clk),
	 .clkb(clk),
    .douta(data_in),
    .doutb(inst_in)
);

//-------------------------------------
//25MHz时钟进行分频，产生每秒递增的16位数据
wire[15:0] display_num;	//数码管显示数据，[15:12]--数码管千位，[11:8]--数码管百位，[7:4]--数码管十位，[3:0]--数码管个位

assign display_num = 
							(switch[0] ? 
										(switch[2]? 
											( switch[1]? data_in[31:16] : data_in[15:0] ):		// 数据
											( switch[1]? inst_in[31:16] : inst_in[15:0] )		// 指令
													):
										(switch[2]? 						
											( switch[1]? data_addr[31:16] : data_addr[15:0] ):	// 数据地址
											( switch[1]? PC_ID[31:16] : PC_ID[15:0] )				// 指令地址
													)	
										);
													
counter		uut_counter(
				.clk(clk_25m),		//时钟信号
				.rst_n(sys_rst_n),	//复位信号，低电平有效
				.timer_1s_flag(clk_1s)		//LED指示灯接口	
			);
		
//-------------------------------------
//4位数码管显示驱动															

seg7		uut_seg7(
				.clk(clk_25m),		//时钟信号
				.rst_n(sys_rst_n),	//复位信号，低电平有效
				.display_num(display_num),		//LED指示灯接口	
				.dtube_cs_n(dtube_cs_n),	//7段数码管位选信号
				.dtube_data(dtube_data)		//7段数码管段选信号（包括小数点为8段）
		);

endmodule

