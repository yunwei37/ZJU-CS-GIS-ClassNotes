/////////////////////////////////////////////////////////////////////////////
//工程硬件平台： Xilinx Spartan 6 FPGA
//开发套件型号： SF-SP6 特权打造
//版   权  申   明： 本例程由《深入浅出玩转FPGA》作者“特权同学”原创，
//				仅供SF-SP6开发套件学习使用，谢谢支持
//官方淘宝店铺： http://myfpga.taobao.com/
//最新资料下载： 百度网盘 http://pan.baidu.com/s/1jGjAhEm
//公                司： 上海或与电子科技有限公司
/////////////////////////////////////////////////////////////////////////////
module counter(
			input clk,		//时钟信号，25MHz
			input rst_n,	//复位信号，低电平有效
			//output reg[15:0] display_num	//数码管显示数据，[15:12]--数码管千位，[11:8]--数码管百位，[7:4]--数码管十位，[3:0]--数码管个位
			output reg timer_1s_flag
		);

//-------------------------------------------------
//1s定时产生逻辑
reg[24:0] timer_cnt;	//1s计数器，0-24999999

	//1s定时计数
always @(posedge clk or negedge rst_n)
	if(!rst_n) timer_cnt <= 25'd0;
	else if(timer_cnt < 25'd24_999_999) begin
		timer_cnt <= timer_cnt+1'b1;
	end
	else timer_cnt <= 25'd0;



//assign timer_1s_flag = (timer_cnt == 25'd24_999_999);		//1s定时到标志位，高有效一个时钟周期

//-------------------------------------------------
//递增数据产生逻辑

	//显示数据每秒递增
always @(posedge clk or negedge rst_n)
	if(!rst_n) timer_1s_flag <= 1'b0;
	else if(timer_cnt < 25'd12_499_999) timer_1s_flag <= 1'b0;
	else	timer_1s_flag <= 1'b1;
	
endmodule

