`timescale 1ns / 1ps
//Subject:     CO project 5 - Pipe CPU
//--------------------------------------------------------------------------------
//Version:     
//--------------------------------------------------------------------------------
//Writer:      109700045
//----------------------------------------------
//Date:        2022/6/27
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
    clk_i,
    rst_i
    );
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
wire [32-1:0] IF_pc_out;
wire [32-1:0] IF_pc_add4;
wire [32-1:0] IF_instr;
wire [32-1:0] IF_branch_rlt;
wire [32-1:0] IF_pc_in;
wire [ 5-1:0] IF_ID_Rs;
wire [ 5-1:0] IF_ID_Rt;
wire [ 5-1:0] IF_ID_Rd;
wire 		  IF_pc_src;
wire 		  IF_ID_Write;

wire [ 2-1:0] ID_BranchType_MEM;
wire [ 3-1:0] ID_ALU_op_EX_v;
wire [ 2-1:0] ID_BranchType_MEM_v;
wire [32-1:0] ID_pc_add4;
wire [32-1:0] ID_instr;
wire [32-1:0] ID_RSdata;
wire [32-1:0] ID_RTdata;
wire [32-1:0] ID_extend_out;
wire [ 3-1:0] ID_ALU_op_EX;
wire 		  ID_RegDst_EX;
wire 		  ID_Branch_MEM;
wire 		  ID_ALUSrc_EX;
wire 		  ID_MemWrite_MEM;
wire 		  ID_MemRead_MEM;
wire 		  ID_PC_Write;
wire 		  ID_Ctrl;
wire 		  ID_Branch_MEM_v;
wire 		  ID_MemRead_MEM_v;
wire 		  ID_MemWrite_MEM_v;
wire 		  ID_RegWrite_WB_v;
wire 		  ID_MemtoReg_WB_v;
wire 		  ID_RegWrite_WB;
wire 		  ID_MemtoReg_WB;
wire 		  ID_ALUSrc_EX_v;
wire 		  ID_RegDst_EX_v;
wire		      ID_Flush;
wire [ 5-1:0] ID_EX_Rs;
wire [ 5-1:0] ID_EX_Rt;
wire [ 5-1:0] ID_EX_Rd;

wire [32-1:0] EX_pc_add4;
wire [32-1:0] EX_ext_out;
wire [32-1:0] EX_shift_left;
wire [32-1:0] EX_RSdata;
wire [32-1:0] EX_RTdata;
wire [32-1:0] EX_pc_branch;
wire [32-1:0] EX_pre_ALU_1st;
wire [32-1:0] EX_pre_ALU_2nd;
wire [32-1:0] EX_ALU_2nd;
wire [32-1:0] EX_ALU_result;
wire [ 5-1:0] EX_ALU_ctrl;
wire [ 5-1:0] EX_RDaddr;
wire [ 5-1:0] EX_MEM_Rd;
wire [ 3-1:0] EX_ALU_op;
wire [ 2-1:0] EX_BranchType_MEM;
wire [ 2-1:0] EX_ForwardA;
wire [ 2-1:0] EX_ForwardB;
wire 		  EX_ALUSrc;
wire 		  EX_RegDst;
wire 		  EX_Branch_MEM;
wire 		  EX_RegWrite_WB;
wire 		  EX_MemtoReg_WB;
wire 		  EX_MemRead_MEM;
wire 		  EX_MemWrite_MEM;
wire		      EX_zero;

wire [32-1:0] MEM_pc_branch;
wire [32-1:0] MEM_ALU_rlt;
wire [32-1:0] MEM_RTdata;
wire [32-1:0] MEM_dm_out;
wire [ 5-1:0] MEM_RDaddr;
wire [ 5-1:0] MEM_WB_Rd;
wire [ 2-1:0] MEM_branch_type;
wire 		  MEM_zero;
wire 		  MEM_MemRead;
wire 		  MEM_MemWrite;
wire 		  MEM_RegWrite_WB;
wire 		  MEM_MemtoReg_WB;
wire 		  MEM_Branch;
wire		      MEM_Branch_final;

wire [32-1:0] WB_ALU_result;
wire [32-1:0] WB_dm_out;
wire [32-1:0] WB_RDdata;
wire [ 5-1:0] WB_RDaddr;
wire 		  WB_RegWrite;
wire 		  WB_MemtoReg;

assign IF_ID_Rs = ID_instr[25:21];
assign IF_ID_Rt = ID_instr[20:16];
assign IF_ID_Rd = ID_instr[15:11];

MUX_2to1 #(.size(32)) Mux0(
	.data0_i(IF_pc_add4),
	.data1_i(IF_branch_rlt),
	.select(IF_pc_src),
	.data_o(IF_pc_in)
);

ProgramCounter PC(
    .clk_i(clk_i), 
	.rst_i(rst_i), 
	.PCWrite_i(ID_PC_Write), 
	.pc_in_i(IF_pc_in),
	.pc_out_o(IF_pc_out)
);

Adder Add_pc(
	.src1_i(32'd4),
	.src2_i(IF_pc_out),
	.sum_o(IF_pc_add4)  
);

Instruction_Memory IM(
	.addr_i(IF_pc_out),
	.instr_o(IF_instr)
);
		
Pipe_Reg #(.size(64),.ctrl_size(1)) IF_ID(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.valid_i(IF_ID_Write),
	.flush_i(ID_Flush),
	.data_i({IF_pc_add4,IF_instr}),
	.data_o({ID_pc_add4,ID_instr})
);

Reg_File RF(
	.clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(ID_instr[25:21]),
    .RTaddr_i(ID_instr[20:16]),
    .RDaddr_i(WB_RDaddr),
    .RDdata_i(WB_RDdata),
    .RegWrite_i(WB_RegWrite),
    .RSdata_o(ID_RSdata),
    .RTdata_o(ID_RTdata)
);

Decoder Control(
	.instr_op_i(ID_instr[31:26]),
	.RegWrite_o(ID_RegWrite_WB),
	.ALU_op_o(ID_ALU_op_EX),
	.ALUSrc_o(ID_ALUSrc_EX),
	.RegDst_o(ID_RegDst_EX),
	.Branch_o(ID_Branch_MEM),
	.BranchType_o(ID_BranchType_MEM),
	.MemRead_o(ID_MemRead_MEM),
	.MemWrite_o(ID_MemWrite_MEM),
	.MemtoReg_o(ID_MemtoReg_WB)
);

HazardUnit HU(
	.IF_ID_RegisterRs_i(IF_ID_Rs),
	.IF_ID_RegisterRt_i(IF_ID_Rt),
	.ID_EX_MemRead_i(EX_MemRead_MEM),
	.ID_EX_RegisterRs_i(ID_EX_Rs),
	.ID_EX_RegisterRt_i(ID_EX_Rt),
	.Branch_i(IF_pc_src),
	.PCWrite_o(ID_PC_Write),
	.IF_IDWrite_o(IF_ID_Write),
	.Control_o(ID_Ctrl),
	.Flush_o(ID_Flush)
);

Sign_Extend Sign_Extend(
	.data_i(ID_instr[15:0]),
	.data_o(ID_extend_out)
);

MUX_2to1 #(.size(12)) MuxC(
	.data0_i(12'd0),
	.data1_i({ID_ALU_op_EX,
	         ID_ALUSrc_EX,
	         ID_RegDst_EX,
	         ID_Branch_MEM,
	         ID_BranchType_MEM,
	         ID_MemRead_MEM,
	         ID_MemWrite_MEM,
	         ID_RegWrite_WB,
	         ID_MemtoReg_WB
			 }),
	.select(ID_Ctrl),
	.data_o({ID_ALU_op_EX_v,
	        ID_ALUSrc_EX_v,
	        ID_RegDst_EX_v,
	        ID_Branch_MEM_v,
	        ID_BranchType_MEM_v,
	        ID_MemRead_MEM_v,
	        ID_MemWrite_MEM_v,
	        ID_RegWrite_WB_v,
	        ID_MemtoReg_WB_v
	        })
);

Pipe_Reg #(.size(128+15+12),.ctrl_size(12)) ID_EX(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.valid_i(1'd1),
	.flush_i(ID_Flush),
	.data_i({ID_pc_add4,
			 ID_RSdata,
			 ID_RTdata,
			 ID_extend_out,
			 IF_ID_Rs,
			 IF_ID_Rt,
			 IF_ID_Rd,			 
			 ID_ALU_op_EX_v,
			 ID_ALUSrc_EX_v,
			 ID_RegDst_EX_v,
			 ID_Branch_MEM_v,
			 ID_BranchType_MEM_v,
			 ID_MemRead_MEM_v,
			 ID_MemWrite_MEM_v,
			 ID_RegWrite_WB_v,
			 ID_MemtoReg_WB_v
			 }),
	.data_o({EX_pc_add4,
			 EX_RSdata,
			 EX_RTdata,
			 EX_ext_out,
			 ID_EX_Rs,
			 ID_EX_Rt,
			 ID_EX_Rd,			 
			 EX_ALU_op,
			 EX_ALUSrc,
			 EX_RegDst,
			 EX_Branch_MEM,
			 EX_BranchType_MEM,
			 EX_MemRead_MEM,
			 EX_MemWrite_MEM,
			 EX_RegWrite_WB,
			 EX_MemtoReg_WB
			 })
);
	   
Shift_Left_Two_32 Shifter(
	.data_i(EX_ext_out),
	.data_o(EX_shift_left)
);	

ForwardUnit FU(
	.ID_EX_RegisterRs_i(ID_EX_Rs),
	.ID_EX_RegisterRt_i(ID_EX_Rt),
	.EX_MEM_RegWrite_i(MEM_RegWrite_WB),
	.EX_MEM_RegisterRd_i(EX_MEM_Rd),
	.MEM_WB_RegWrite_i(WB_RegWrite),
    .MEM_WB_RegisterRd_i(MEM_WB_Rd),
	.ForwardA_o(EX_ForwardA),
	.ForwardB_o(EX_ForwardB)
);

MUX_3to1 #(.size(32)) MuxA(
	.data0_i(EX_RSdata),
	.data1_i(MEM_ALU_rlt),
	.data2_i(WB_RDdata),
	.select_i(EX_ForwardA),
	.data_o(EX_pre_ALU_1st)
);

MUX_3to1 #(.size(32)) MuxB(
	.data0_i(EX_RTdata),
	.data1_i(MEM_ALU_rlt),
	.data2_i(WB_RDdata),
	.select_i(EX_ForwardB),
	.data_o(EX_pre_ALU_2nd)
);

MUX_2to1 #(.size(32)) Mux1(
	.data0_i(EX_pre_ALU_2nd),
	.data1_i(EX_ext_out),
	.select(EX_ALUSrc),
	.data_o(EX_ALU_2nd)
);

ALU ALU(
    .src1_i(EX_pre_ALU_1st),
	.src2_i(EX_ALU_2nd),
	.ctrl_i(EX_ALU_ctrl),
	.result_o(EX_ALU_result),
	.zero_o(EX_zero)
);
	
MUX_2to1 #(.size(5)) Mux2(
	.data0_i(ID_EX_Rt),
	.data1_i(ID_EX_Rd),
	.select(EX_RegDst),
	.data_o(EX_RDaddr)
);

ALU_Ctrl ALU_Control(
	.funct_i(EX_ext_out[5:0]),
    .ALUOp_i(EX_ALU_op),
    .ALUCtrl_o(EX_ALU_ctrl)
);

Adder Add_pc_branch(
	.src1_i(EX_pc_add4),
	.src2_i(EX_shift_left),
	.sum_o(EX_pc_branch)
);

Pipe_Reg #(.size(97+5+7),.ctrl_size(7)) EX_MEM(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.valid_i(1'd1),
	.flush_i(ID_Flush),
	.data_i({EX_pc_branch,
			 EX_zero,
			 EX_ALU_result,
			 EX_pre_ALU_2nd,
			 EX_RDaddr,		 
			 EX_Branch_MEM,
			 EX_BranchType_MEM,
			 EX_MemRead_MEM,
			 EX_MemWrite_MEM,
			 EX_RegWrite_WB,
			 EX_MemtoReg_WB
			}),
	.data_o({MEM_pc_branch,
			 MEM_zero,
             MEM_ALU_rlt,
             MEM_RTdata,
			 EX_MEM_Rd,		 
			 MEM_Branch,
			 MEM_branch_type,
			 MEM_MemRead,
			 MEM_MemWrite,
			 MEM_RegWrite_WB,
			 MEM_MemtoReg_WB
			 })
);

MUX_4to1 #(.size(1)) MuxBranch(
	.data0_i(MEM_zero),							
	.data1_i(~MEM_zero),						
	.data2_i(MEM_zero | (MEM_ALU_rlt[31] == 0)),	
	.data3_i(MEM_ALU_rlt[31] == 0),				
	.select_i(MEM_branch_type),
	.data_o(MEM_Branch_final)
);

Data_Memory DM(
	.clk_i(clk_i),
    .addr_i(MEM_ALU_rlt),
    .data_i(MEM_RTdata),
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),
    .data_o(MEM_dm_out)
);

Pipe_Reg #(.size(64+5+5+2),.ctrl_size(2)) MEM_WB(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.valid_i(1'd1),
	.flush_i(1'd0),
	.data_i({MEM_ALU_rlt,
			 MEM_dm_out,
			 MEM_RDaddr,
			 EX_MEM_Rd,
			 MEM_RegWrite_WB,
			 MEM_MemtoReg_WB
			}),
	.data_o({WB_ALU_result,
			 WB_dm_out,
			 WB_RDaddr,
			 MEM_WB_Rd,
			 WB_RegWrite,
			 WB_MemtoReg
			})
);

MUX_2to1 #(.size(32)) Mux3(
	.data0_i(WB_ALU_result),
	.data1_i(WB_dm_out),
	.select(WB_MemtoReg),
	.data_o(WB_RDdata)
);

assign IF_pc_src = MEM_Branch & MEM_Branch_final;
assign IF_branch_rlt = MEM_pc_branch;
assign MEM_RDaddr = EX_MEM_Rd;

endmodule
