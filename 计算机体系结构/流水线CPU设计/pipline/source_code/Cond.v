`timescale 1ns / 1ps

//用于分支指令比较
module Cond(
    input [31:0] A,
    input [31:0] B,
    input cond,
    output res
    );

//cond = 0: beq, cond = 1: bne 
assign res = cond ^ (A == B);
endmodule
