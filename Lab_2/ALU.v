//Subject:     CO project 2 - ALU
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
module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
//I/O ports
input signed [32-1:0]  src1_i;
input signed [32-1:0]  src2_i;
input  [4-1:0]   ctrl_i;

output reg [32-1:0]	   result_o;
output                  zero_o;

assign zero_o = (result_o == 0); //zero is true if result_o is zero
always @(ctrl_i, src1_i, src2_i) begin //reevaluate if these change
    case(ctrl_i)
        0: result_o <= src1_i & src2_i;
        1: result_o <= src1_i | src2_i;
        2: result_o <= src1_i + src2_i;
        6: result_o <= src1_i - src2_i;
        7: result_o <= src1_i < src2_i ? 1 : 0;
        12: result_o <= !(src1_i | src2_i);
        default: result_o <= 0;
    endcase
end
//Internal signals
//reg    [32-1:0]  result_o;
//wire             zero_o;

//Parameter

//Main function

endmodule





                    
                    