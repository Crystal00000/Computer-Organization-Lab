//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
`timescale 1ns/1ps
module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i; 

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter
always@(*) begin
    case(ALUOp_i)
        0: //R - type
            case(funct_i)
                6'd32: ALUCtrl_o <= 4'b0010; //add
                6'd34: ALUCtrl_o <= 4'b0110; //sub
                6'd36: ALUCtrl_o <= 4'b0000; //and
                6'd37: ALUCtrl_o <= 4'b0001; //or
                6'd42: ALUCtrl_o <= 4'b0111; //slt
                default: ALUCtrl_o <= 4'b0000;
            endcase
        1: ALUCtrl_o <= 4'b0110; //beq
        2: ALUCtrl_o <= 4'b0010; //addi
        3: ALUCtrl_o <= 4'b0111; //slti
        default: ALUCtrl_o <= 4'b0000;
    endcase 
end
       
//Select exact operation

endmodule     





                    
                    