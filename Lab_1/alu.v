`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:15:11 08/18/2013
// Design Name:
// Module Name:    alu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module alu(
           clk,           // system clock              (input)
           rst_n,         // negative reset            (input)
           src1,          // 32 bits source 1          (input)
           src2,          // 32 bits source 2          (input)
           ALU_control,   // 4 bits ALU control input  (input)
           result,        // 32 bits result            (output)
           zero,          // 1 bit when the output is 0, zero must be set (output)
           cout,          // 1 bit carry out           (output)
           overflow       // 1 bit overflow            (output)
           );

input           clk;
input           rst_n;
input signed [32-1:0] src1;
input signed [32-1:0] src2;
input   [4-1:0] ALU_control;

output [32-1:0] result;
output          zero;
output          cout;
output          overflow;

reg    [32-1:0] result;
reg             zero;
reg             cout;
reg             overflow;
/* my design */
wire [31:0] and_rst	= src1 & src2; // combinational circuit (only =)
wire [31:0] or_rst	= src1 | src2;
wire [32:0] add_rst	= src1 + src2;
wire signed [31:0] src2_2c = -src2; // 2's complement
wire [32:0] sub_rst	= src1 + src2_2c;
wire [31:0] nor_rst = ~(or_rst);
wire slt_rst = src1 < src2;

always@( posedge clk or negedge rst_n ) // sequential circuit (only <= (non-blocking assignment))
begin
	if(!rst_n) begin
		result <= 32'd0;
		zero <= 1'b0;
		cout <= 1'b0;
		overflow <= 1'b0;
	end
	else begin
		cout <= 1'b0;
		overflow <= 1'b0;
		case (ALU_control)
			4'b0000 : begin // And
				result <= and_rst;
				zero <= (and_rst == 32'd0);
			end
			4'b0001 : begin // Or
				result <= or_rst;
				zero <= (or_rst == 32'd0);
			end
			4'b0010 : begin // Add
				result <= add_rst[31:0];
				zero <= (add_rst[31:0] == 32'd0);
				cout <= add_rst[32] ^ src1[31] ^ src2[31];
				overflow <= (add_rst[32] ^ add_rst[31]);
			end
			4'b0110 : begin // Sub
				result <= sub_rst[31:0];
				zero <= (sub_rst[31:0] == 32'd0);
				cout <= sub_rst[32] ^ src1[31] ^ src2_2c[31];
				overflow <= (sub_rst[32] ^ sub_rst[31]);
			end
			4'b1100 : begin // Nor
				result <= nor_rst;
				zero <= (nor_rst == 32'd0);
			end
			4'b0111 : begin // Slt
				result <= slt_rst;
				zero <= (slt_rst == 1'b0);
			end
		endcase
	end
end

endmodule
