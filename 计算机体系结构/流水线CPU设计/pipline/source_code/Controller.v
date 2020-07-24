module Controller(
    input [31:0] inst_in,
    output reg [17:0] ctrl_signal
);

wire [5:0] opcode;
wire [5:0] func;
assign opcode = inst_in[31:26];
assign func = inst_in[5:0];

// Control Unit
always @* begin
    case(opcode)
    6'h00: begin 
        case(func) 
            6'h24: begin ctrl_signal <= 18'b00_01_0_0_0000_1_11_1_0_01_0; end //0x24 and
            6'h20: begin ctrl_signal <= 18'b00_01_0_0_0010_1_11_1_0_01_0; end //0x20 add
            6'h21: begin ctrl_signal <= 18'b00_01_0_0_0010_1_11_1_0_01_0; end //0x21 addu
            6'h25: begin ctrl_signal <= 18'b00_01_0_0_0001_1_11_1_0_01_0; end //0x25 or
            6'h22: begin ctrl_signal <= 18'b00_01_0_0_0110_1_11_1_0_01_0; end //0x22 sub
            
            6'h23: begin ctrl_signal <= 18'b00_01_0_0_0110_1_11_1_0_01_0; end //0x23 subu
            6'h26: begin ctrl_signal <= 18'b00_01_0_0_0011_1_11_1_0_01_0; end //0x26 xor
            6'h27: begin ctrl_signal <= 18'b00_01_0_0_0100_1_11_1_0_01_0; end //0x27 nor
            6'h2a: begin ctrl_signal <= 18'b00_01_0_0_0111_1_11_1_0_01_0; end //0x2a slt
            6'h2b: begin ctrl_signal <= 18'b00_01_0_0_1111_1_11_1_0_01_0; end //0x2b sltu
            
            6'h04: begin ctrl_signal <= 18'b00_01_0_0_1010_1_11_1_0_01_0; end //0x04 sllv
            6'h06: begin ctrl_signal <= 18'b00_01_0_0_1001_1_11_1_0_01_0; end //0x06 srlv
            6'h07: begin ctrl_signal <= 18'b00_01_0_0_1011_1_11_1_0_01_0; end //0x07 srav
            6'h00: begin 
                if(inst_in != 32'h0)
                    ctrl_signal <= 18'b00_01_0_0_1101_1_01_1_0_01_0; //0x00 sll
                else
                    ctrl_signal <= 18'b00_00_0_0_0000_0_00_0_0_00_0; //0x00 nop
            end 
            6'h02: begin ctrl_signal <= 18'b00_01_0_0_0101_1_01_1_0_01_0; end //0x02 srl
            
            6'h03: begin ctrl_signal <= 18'b00_01_0_0_1000_1_01_1_0_01_0; end //0x03 sra
            6'h08: begin ctrl_signal <= 18'b11_01_0_0_0000_0_10_1_0_01_0; end //0x08 jr
        endcase
    end
    6'h23: begin ctrl_signal <= 18'b00_00_0_0_0010_1_10_0_1_00_1; end //0x23 lw
    6'h2b: begin ctrl_signal <= 18'b00_01_1_0_0010_0_11_0_1_01_1; end //0x2b sw
    6'h04: begin ctrl_signal <= 18'b01_01_0_0_0000_0_11_1_1_01_1; end //0x04 beq
    6'h05: begin ctrl_signal <= 18'b01_01_0_1_0000_0_11_1_1_01_1; end //0x05 bne
    6'h0f: begin ctrl_signal <= 18'b00_10_0_0_0000_1_00_1_1_00_1; end //0x0f lui
    
    6'h08: begin ctrl_signal <= 18'b00_01_0_0_0010_1_10_1_1_00_1; end //0x08 addi
    6'h09: begin ctrl_signal <= 18'b00_01_0_0_0010_1_10_1_1_00_1; end //0x09 addiu
    6'h0d: begin ctrl_signal <= 18'b00_01_0_0_0001_1_10_1_1_00_1; end //0x0d ori
    6'h0e: begin ctrl_signal <= 18'b00_01_0_0_0011_1_10_1_1_00_1; end //0x0e xori
    6'h0a: begin ctrl_signal <= 18'b00_01_0_0_0111_1_10_1_1_00_1; end //0x0a slti
    
    6'h0b: begin ctrl_signal <= 18'b00_01_0_0_1111_1_10_1_0_00_1; end //0x0b sltiu
    6'h0c: begin ctrl_signal <= 18'b00_01_0_0_0000_1_10_1_1_00_1; end //0x0c andi
    6'h02: begin ctrl_signal <= 18'b10_01_0_0_0011_0_00_1_0_00_0; end //0x02 j
    6'h03: begin ctrl_signal <= 18'b10_11_0_0_0011_1_00_1_1_10_1; end //0x03 jal
    endcase
end

endmodule