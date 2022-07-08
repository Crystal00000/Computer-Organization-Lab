//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     
//--------------------------------------------------------------------------------
//Writer:     109700045
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	BranchType_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
	);
     
//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output  RegDst_o;
output         Branch_o;
output [2-1:0] BranchType_o;
output 		   Jump_o;
output		   MemRead_o;
output		   MemWrite_o;
output  MemtoReg_o;
 
//Internal Signals
reg    [3-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg	           RegDst_o;
reg    		   Branch_o;
reg    [2-1:0] BranchType_o;
reg 		       Jump_o;
reg			   MemRead_o;
reg			   MemWrite_o;
reg	           MemtoReg_o;

wire		   Rformat_ctrl ;//jr
wire		   lw_ctrl;
wire		   sw_ctrl;
wire		   beq_ctrl;
wire		   bne_ctrl;
wire		   bge_ctrl;
wire		   bgt_ctrl;
wire		   addi_ctrl;
wire		   slti_ctrl;


//R
assign Rformat_ctrl = &(~instr_op_i);
//I
assign lw_ctrl		= (instr_op_i== 6'b100011);
assign sw_ctrl		= (instr_op_i== 6'b101011);
assign addi_ctrl    	= (instr_op_i== 6'd8);
assign slti_ctrl	    = (instr_op_i==6'd10);
//branch
assign beq_ctrl		= (instr_op_i== 6'd4);
assign bne_ctrl		= (instr_op_i== 6'd5);
assign bge_ctrl		= (instr_op_i== 6'd1);
assign bgt_ctrl		= (instr_op_i== 6'd7);

always @(instr_op_i)begin
	ALUSrc_o <= addi_ctrl | slti_ctrl | lw_ctrl | sw_ctrl;
	RegWrite_o <= Rformat_ctrl | addi_ctrl | slti_ctrl | lw_ctrl;
	RegDst_o <= Rformat_ctrl;
	MemRead_o <= lw_ctrl;
	MemWrite_o <= sw_ctrl;
	MemtoReg_o <= lw_ctrl;

	Branch_o <= beq_ctrl | bne_ctrl | bgt_ctrl | bge_ctrl;
	if(lw_ctrl | sw_ctrl)
		ALU_op_o <= 3'd0; //lw or sw
	else if(beq_ctrl | bne_ctrl | bge_ctrl | bgt_ctrl )
		ALU_op_o <= 3'd1; //beq
	else if(Rformat_ctrl)
		ALU_op_o <= 3'd2; //R
	else if(addi_ctrl)
		ALU_op_o <= 3'd3; //addi
	else if(slti_ctrl)
		ALU_op_o <= 3'd4; //slti
	else
		ALU_op_o <= 3'b111;




	case(instr_op_i)
		6'd4:BranchType_o <= 2'd0;		//beq
		6'd5:BranchType_o <= 2'd1;		//bne
		6'd1:BranchType_o <= 2'd2;		//bge
		6'd7:BranchType_o <= 2'd3;		//bgt
		default:BranchType_o <= 2'd0;
	endcase
end


endmodule





                    
                    