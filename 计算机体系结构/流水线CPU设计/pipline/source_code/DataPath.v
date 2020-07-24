`timescale 1ns / 1ps
module Pipeline_CPU(
	input clk,
	input reset,
    input [31:0] data_in,   //从Mem流入的数据, 值为Mem[addr_out]
    input [31:0] inst_in,   //从Mem流入的指令, 值为Mem[PC_out]
    output [31:0] PC_out,   //ID段PC
    output mem_w,           //主存读写使能
    output [31:0] data_out, //写主存时的数据
    output [31:0] addr_out,  //写主存地址
	 output data_stall,
	 output stall
);

//wire stall, data_stall;
//---------------------IF--------------------
wire [1:0] BranchFlag_ID;
reg [1:0] BranchFlag_EXE;
//PC_out -> memory -> inst_in
reg [31:0] PC_in;
REG32 regPC (
    .clk(clk),
    .rst(reset),
    .CE(~stall),
    .D(PC_in),
    .Q(PC_out) 
    );
//TF地址在EXE段确定, 因此只需要检查ID段是否是跳转, 由于control_stall时IF向ID传入nop, EXE为分支跳转时ID必为nop
assign stall = data_stall | |(BranchFlag_ID);

//-------------------IF/ID---------------------------
reg [31:0] inst_ID, PC_ID;
always @(posedge clk or posedge reset) begin
    if(reset == 1) begin
        inst_ID <= 32'b0;
        PC_ID <= 32'b0;
    end
    else if(~data_stall) begin
        inst_ID <= inst_in & {32{~|(BranchFlag_EXE | BranchFlag_ID)}}; //如果ID/EXE有分支指令, 向ID传入nop
        PC_ID <= PC_out + 32'h4;
    end
end

//---------------------ID--------------------------
reg [31:0] wt_data_WB;
reg [4:0] wt_addr_WB, wt_addr_MEM, wt_addr_EXE;
reg RegWrite_WB, RegWrite_EXE, RegWrite_MEM;
//将控制信号传输到控制器
wire [17:0] ctrl_signal;
Controller ctrl(
    .inst_in(inst_ID),
    .ctrl_signal(ctrl_signal)
);

//控制信号列表
 //EXE_forward表示结果能否在EXE段回传
wire [1:0] MemtoReg_ID, rd_addr_valid, RegDst_ID;
wire SignExtend, cond_ID, ALUsrc_B_ID, mem_w_ID, RegWrite_ID, EXE_forward_ID;
wire [3:0] ALU_op_ID;
assign {BranchFlag_ID, MemtoReg_ID, mem_w_ID, cond_ID, ALU_op_ID, RegWrite_ID, rd_addr_valid, EXE_forward_ID, SignExtend, RegDst_ID, ALUsrc_B_ID} = ctrl_signal;

//确定未来在WB段需要写入的地址
reg [4:0] wt_addr_ID;
reg [4:0] shamt_ID;
wire [4:0] rs, rt, rd;
assign rs = inst_ID[25:21];
assign rt = inst_ID[20:16];
assign rd = inst_ID[15:11];

always@(*)begin
	case(RegDst_ID)
		2'b00:wt_addr_ID <= rt; //rt
		2'b01:wt_addr_ID <= rd; //rd
		2'b10:wt_addr_ID <= 5'b11111;    //$ra = 5'b11111, jal使用
		2'b11:wt_addr_ID <= 5'b0;        //未定义
	endcase
	//shift amount
	shamt_ID <= inst_ID[10:6];
end

//扩展立即数
wire [31:0] Imm32_ID;
assign Imm32_ID = SignExtend ? {{16{inst_ID[15]}}, inst_ID[15:0]} : {{16{1'b0}}, inst_ID[15:0]};

//寄存器组
wire [31:0] Reg_A, Reg_B;
regs Regs (
    .clk(clk),
    .rst(reset),
    .L_S(RegWrite_WB),
    .R_addr_A(rs),
    .R_addr_B(rt),
    .Wt_addr(wt_addr_WB),
    .Wt_data(wt_data_WB),
    .rdata_A(Reg_A),
    .rdata_B(Reg_B)
    );

//RAW
//当读写地址有效时, 若读地址与EXE/MEM段指令的写地址一致会发生data hazard
//因此,在RAW中, 出现Stall的条件: 读地址有效, 且与EXE段写地址一致, 并且不能在EXE段回传
reg EXE_forward;
reg [31:0] data_forward_EXE, data_forward_MEM;
wire [1:0] data_hazard; //valid={valid_rs, valid_rt}, data_hazard = {data_hazard_EXE, data_hazard_MEM}
assign data_hazard = {RegWrite_EXE & ((rd_addr_valid[1] & (wt_addr_EXE == rs)) | (rd_addr_valid[0] & (wt_addr_EXE == rt))), 
                           RegWrite_MEM & ((rd_addr_valid[1] & (wt_addr_MEM == rs)) | (rd_addr_valid[0] & (wt_addr_MEM == rt)))};
assign data_stall = data_hazard[1] & ~EXE_forward;

reg [31:0] Reg_A_ID, Reg_B_ID;
//发生forwarding的条件:
//读写地址有效, 且与EXE段写地址一致, 可以回传
//读写地址有效, 且与MEM段写地址一致
always@* begin
    case(data_hazard)
        2'b11: begin 
              //当EXE_forward为0时, 下面的值未定义
              if(wt_addr_EXE == wt_addr_MEM) begin
                    //EXE MEM的forwarding一致, 回传EXE段数据, 另一个数据源一定是regs
                    if (rs == wt_addr_EXE) begin
                        Reg_A_ID <= data_forward_EXE;
                        Reg_B_ID <= Reg_B;
                    end else begin
                        Reg_A_ID <= Reg_A;
                        Reg_B_ID <= data_forward_EXE;
                    end
              end else begin
                    //不一致, ID段指令的两个数据源都需要forwarding
                    if (rs == wt_addr_EXE) begin
                        Reg_A_ID <= data_forward_EXE;
                        Reg_B_ID <= data_forward_MEM;
                    end else begin
                        Reg_A_ID <= data_forward_MEM;
                        Reg_B_ID <= data_forward_EXE;
                    end
              
              end
              
        end
        2'b10: begin 
              //当EXE_forward为0时, 下面的值未定义
              if (rs == wt_addr_EXE) begin
                    Reg_A_ID <= data_forward_EXE;
                    Reg_B_ID <= Reg_B;
              end else begin
                    Reg_A_ID <= Reg_A;
                    Reg_B_ID <= data_forward_EXE;
              end
        end
        2'b01: begin 
              if (rs  == wt_addr_MEM) begin
                    Reg_A_ID <= data_forward_MEM;
                    Reg_B_ID <= Reg_B;
              end else begin
                    Reg_A_ID <= Reg_A;
                    Reg_B_ID <= data_forward_MEM;
              end
        end
        2'b00: begin 
              Reg_A_ID <= Reg_A;
              Reg_B_ID <= Reg_B;
        end
    endcase
end


//-------------------ID/EXE--------------------
//TODO: 确定控制器流向EXE段的控制信号
reg [31:0] Reg_A_EXE, Reg_B_EXE, Imm32_EXE, inst_EXE;
reg [3:0] ALU_op_EXE;
reg [31:0] PC_EXE;
reg [1:0] MemtoReg_EXE;
reg [4:0] shamt_EXE;
reg mem_w_EXE;
reg ALUsrc_B_EXE;
reg cond_EXE;
always@(posedge clk) begin
    Reg_A_EXE <= Reg_A_ID;
    Reg_B_EXE <= Reg_B_ID;
    Imm32_EXE <= Imm32_ID;
    PC_EXE <= PC_ID;
    wt_addr_EXE <= wt_addr_ID;
    inst_EXE <= inst_ID;
    shamt_EXE <= shamt_ID;
    //当发生stall后, ID段向EXE段传入Nop
    //control_stall时, IF向ID传入nop, 因此不需要做任何修改
    //关注data_stall即可
    ALU_op_EXE <= ALU_op_ID;
    RegWrite_EXE <= RegWrite_ID & ~data_stall;
    MemtoReg_EXE <= MemtoReg_ID;
    BranchFlag_EXE <= BranchFlag_ID;
    mem_w_EXE <= mem_w_ID & ~data_stall;
    EXE_forward <= EXE_forward_ID;
    ALUsrc_B_EXE <= ALUsrc_B_ID; 
    cond_EXE <= cond_ID;
end
//--------------------EXE--------------------
//ALU
wire [31:0] ALUout_EXE;
ALU alu (
    .A(Reg_A_EXE),
    .B(ALUsrc_B_EXE?Imm32_EXE:Reg_B_EXE), //ALUsrc_B = 0, use reg_B(R-Type, e.g.); ALUsrc_B = 1, use Imm
    .shamt(shamt_EXE),
    .ALU_operation(ALU_op_EXE),
    .res(ALUout_EXE)
    );
 
//分支/跳转地址计算
//j系列指令在ID段计算后传入EXE段
wire [31:0] branch_PC_EXE, jr_PC_EXE;
wire b_flag;
assign jr_PC_EXE = Reg_A_EXE; //jr 系列指令按照Mem[rs]跳转
Cond c(
    .A(Reg_A_EXE),
    .B(Reg_B_EXE),
    .cond(cond_EXE),
    .res(b_flag)
);
assign branch_PC_EXE = PC_EXE + (b_flag?{Imm32_EXE[29:0], 2'b0}:32'h0); //若满足条件跳转, 否则PC+4
always@(*) begin
    case(BranchFlag_EXE)
        2'b00: begin  PC_in <= PC_out + 32'h4; end                              //无分支, 无延时槽
        2'b01: begin  PC_in <= branch_PC_EXE;  end                              //分支指令
        2'b10: begin  PC_in <= {PC_EXE[31:28], inst_EXE[25:0], 2'b0};       end //j
        2'b11: begin  PC_in <= Reg_A_EXE;      end                              //jr
    endcase
end


//-------------------------EXE/MEM---------------------------
reg mem_w_MEM;
reg [31:0] data_out_MEM, ALUout_MEM, Imm32_MEM, PC_MEM, inst_MEM;
reg [1:0] MemtoReg_MEM;
always@(posedge clk) begin
    ALUout_MEM <= ALUout_EXE;
    inst_MEM <= inst_EXE;
    data_out_MEM <= Reg_B_EXE; //有且仅有SW指令,数据源是rt, 因此是RegB
    Imm32_MEM <= Imm32_EXE;
    PC_MEM <= PC_EXE;
    wt_addr_MEM <= wt_addr_EXE;
    RegWrite_MEM <= RegWrite_EXE;
    MemtoReg_MEM <= MemtoReg_EXE;
    mem_w_MEM <= mem_w_EXE;
end

always@(*)begin
	case(MemtoReg_EXE)
		2'b00: data_forward_EXE <= 32'h0;                    //undefined
		2'b01: data_forward_EXE <= ALUout_EXE;               //ALU型指令, 也在EXE段forwarding
		2'b10: data_forward_EXE <= {Imm32_EXE[15:0], 16'b0};  //Lui, 在EXE段能forwarding
		2'b11: data_forward_EXE <= PC_EXE;                    //链接, 在EXE段forwarding
	endcase
end

//--------------------------MEM-------------------------------
//访问主存: 写相关
assign mem_w = mem_w_MEM;
assign data_out = data_out_MEM;
assign addr_out = ALUout_MEM; //写入地址用ALU计算RegA + Imm32(with sign extend)

//--------------------------MEM/WB----------------------------
reg [31:0] Imm32_WB, ALUout_WB, data_in_WB, PC_WB, inst_WB;
reg [1:0] MemtoReg_WB;
always@(posedge clk) begin
    Imm32_WB <= Imm32_MEM;
    ALUout_WB <= ALUout_MEM;
    data_in_WB <= data_in; //访问主存: 读相关
    PC_WB <= PC_MEM;
    inst_WB <= inst_MEM;
    
    wt_addr_WB <= wt_addr_MEM;
    RegWrite_WB <= RegWrite_MEM;
    MemtoReg_WB <= MemtoReg_MEM;
end

always@(negedge clk)begin
	case(MemtoReg_MEM)
		2'b00: data_forward_MEM <= data_in;                    
		2'b01: data_forward_MEM <= ALUout_MEM;             
		2'b10: data_forward_MEM <= {Imm32_MEM[15:0], 16'b0};
		2'b11: data_forward_MEM <= PC_MEM;                  
	endcase
end

//--------------------------WB--------------------------------
// 确定写入寄存器组的数据
always@(*)begin
	case(MemtoReg_WB)
	    2'b00:wt_data_WB <= data_in_WB;               //LW
		2'b01:wt_data_WB <= ALUout_WB;                //ALU型指令
		2'b10:wt_data_WB <= {Imm32_WB[15:0], 16'b0};  //Lui
		2'b11:wt_data_WB <= PC_WB;                    //链接
	endcase
end
endmodule
