//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
`timescale 1ns/1ps
module Decoder(
    instr_op_i, //31:26 bits of an instruction
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o
	);
     
//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output         RegDst_o;
output         Branch_o;
 
//Internal Signals
reg    [3-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg            RegDst_o;
reg            Branch_o;


always@(*) begin
    if(instr_op_i == 0) begin //R - type
        ALU_op_o <= 0;
        ALUSrc_o <= 0;
        RegWrite_o <= 1;
        RegDst_o <= 1;
        Branch_o <= 0;
    end
    else if (instr_op_i == 4)begin //beq (branch)
        ALU_op_o <= 1;
        ALUSrc_o <= 0;
        RegWrite_o <= 0;
        RegDst_o <= 0;
        Branch_o <= 1;
    end
    else if (instr_op_i == 8)begin //addi
        ALU_op_o <= 2;
        ALUSrc_o <= 1;
        RegWrite_o <= 1;
        RegDst_o <= 0;
        Branch_o <= 0;
    end
    else if (instr_op_i == 10) begin //slti
        ALU_op_o <= 3;
        ALUSrc_o <= 1;
        RegWrite_o <= 1;
        RegDst_o <= 0;
        Branch_o <= 0;
    end
end

//Parameter

//Main function

endmodule





                    
                    