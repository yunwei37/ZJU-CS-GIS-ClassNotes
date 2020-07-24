/////////////////////////////////////////////////////////////////////////////
//工程硬件平台： Xilinx Spartan 6 FPGA
//开发套件型号： SF-SP6 特权打造
//版   权  申   明： 本例程由《深入浅出玩转FPGA》作者“特权同学”原创，
//				仅供SF-SP6开发套件学习使用，谢谢支持
//官方淘宝店铺： http://myfpga.taobao.com/
//最新资料下载： 百度网盘 http://pan.baidu.com/s/1jGjAhEm
//公                司： 上海或与电子科技有限公司
/////////////////////////////////////////////////////////////////////////////
module seg7(
			input clk,		//时钟信号，25MHz
			input rst_n,	//复位信号，低电平有效
			input[15:0] display_num,	//数码管显示数据，[15:12]--数码管千位，[11:8]--数码管百位，[7:4]--数码管十位，[3:0]--数码管个位
			output reg[3:0] dtube_cs_n,	//7段数码管位选信号
			output reg[7:0] dtube_data	//7段数码管段选信号（包括小数点为8段）
		);

//-------------------------------------------------
//参数定义

//数码管显示 0~F 对应段选输出
parameter 	NUM0 	= 8'h3f,//c0,
			NUM1 	= 8'h06,//f9,
			NUM2 	= 8'h5b,//a4,
			NUM3 	= 8'h4f,//b0,
			NUM4 	= 8'h66,//99,
			NUM5 	= 8'h6d,//92,
			NUM6 	= 8'h7d,//82,
			NUM7 	= 8'h07,//F8,
			NUM8 	= 8'h7f,//80,
			NUM9 	= 8'h6f,//90,
			NUMA 	= 8'h77,//88,
			NUMB 	= 8'h7c,//83,
			NUMC 	= 8'h39,//c6,
			NUMD 	= 8'h5e,//a1,
			NUME 	= 8'h79,//86,
			NUMF 	= 8'h71,//8e;
			NDOT	= 8'h80;	//小数点显示

//数码管位选 0~3 对应输出
parameter	CSN		= 4'b1111,
			CS0		= 4'b1110,
			CS1		= 4'b1101,
			CS2		= 4'b1011,
			CS3		= 4'b0111;

//-------------------------------------------------
//分时显示数据控制单元
reg[3:0] current_display_num;	//当前显示数据
reg[7:0] div_cnt;	//分时计数器

	//分时计数器
always @(posedge clk or negedge rst_n)
	if(!rst_n) div_cnt <= 8'd0;
	else div_cnt <= div_cnt+1'b1;

	//显示数据
always @(posedge clk or negedge rst_n)
	if(!rst_n) current_display_num <= 4'h0;
	else begin
		case(div_cnt)
			8'hff: current_display_num <= display_num[3:0];
			8'h3f: current_display_num <= display_num[7:4];
			8'h7f: current_display_num <= display_num[11:8];
			8'hbf: current_display_num <= display_num[15:12];
			default: ;
		endcase
	end
		
	//段选数据译码
always @(posedge clk or negedge rst_n)
	if(!rst_n) dtube_data <= NUM0;
	else begin
		case(current_display_num) 
			4'h0: dtube_data <= NUM0;
			4'h1: dtube_data <= NUM1;
			4'h2: dtube_data <= NUM2;
			4'h3: dtube_data <= NUM3;
			4'h4: dtube_data <= NUM4;
			4'h5: dtube_data <= NUM5;
			4'h6: dtube_data <= NUM6;
			4'h7: dtube_data <= NUM7;
			4'h8: dtube_data <= NUM8;
			4'h9: dtube_data <= NUM9;
			4'ha: dtube_data <= NUMA;
			4'hb: dtube_data <= NUMB;
			4'hc: dtube_data <= NUMC;
			4'hd: dtube_data <= NUMD;
			4'he: dtube_data <= NUME;
			4'hf: dtube_data <= NUMF;
			default: ;
		endcase
	end

	//位选译码
always @(posedge clk or negedge rst_n)
	if(!rst_n) dtube_cs_n <= CSN;
	else begin
		case(div_cnt[7:6])
			2'b00: dtube_cs_n <= CS0;
			2'b01: dtube_cs_n <= CS1;
			2'b10: dtube_cs_n <= CS2;
			2'b11: dtube_cs_n <= CS3;
			default:  dtube_cs_n <= CSN;
		endcase
	end
	

endmodule

