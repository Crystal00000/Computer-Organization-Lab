`timescale 1ns / 1ps
//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:        109700045
//----------------------------------------------
//Date:        
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
/**** IF stage ****/
wire [32-1:0] IF_pc_add4;
wire [32-1:0] IF_branch_rlt;
wire [32-1:0] IF_pc_in;
wire 		  IF_pc_src;
wire [32-1:0] IF_pc_out;
wire [32-1:0] IF_instr;
/**** ID stage ****/
wire [32-1:0] ID_pc_add4;
wire [32-1:0] ID_instr;
wire [32-1:0] ID_ext;
wire [32-1:0] ID_r_data1;
wire [32-1:0] ID_r_data2;
wire [5-1:0]  ID_regw_addr1;
wire [5-1:0]  ID_regw_addr2;

//control signal
wire          ID_reg_w;
wire [3-1:0]  ID_alu_op;
wire          ID_alu_src;
wire          ID_reg_dst;
wire          ID_branch;
wire          ID_mem_r;
wire          ID_mem_w;
wire          ID_mem_to_reg;

/**** EX stage ****/
//wire [5-1:0]  EX_RS;
//wire [5-1:0]  EX_RT;
wire [32-1:0] EX_pc_add4;//32
wire [32-1:0] EX_r_data1;//32
wire [32-1:0] EX_r_data2;//32
wire [32-1:0] EX_ext;//32
wire [5-1:0]  EX_regw_addr1;//5
wire [5-1:0]  EX_regw_addr2;//5
wire [32-1:0] EX_sh_le;
wire [32-1:0] EX_mux_to_alu;
wire [32-1:0] EX_alu_rlt;
wire          EX_alu_zero;
wire [32-1:0] EX_pc_branch;
wire [5-1:0]  EX_regw_addr;
//wire [32-1:0] EX_forward_to_alu;
//wire [32-1:0] EX_forward_to_mux;
//control signal
wire          EX_reg_w;//1
wire [3-1:0]  EX_alu_op;//4
wire          EX_alu_src;//1
wire          EX_reg_dst;//1
wire          EX_branch;//1
wire          EX_mem_r;//1
wire          EX_mem_w;//1
wire          EX_mem_to_reg;//1
wire [5-1:0]  EX_alu_ctrl;

/**** MEM stage ****/
wire [32-1:0] MEM_pc_branch;//32
wire [32-1:0] MEM_alu_rlt;//32
wire [32-1:0] MEM_r_data2;//32
wire [5-1:0]  MEM_regw_addr;//5
wire [32-1:0] MEM_read_data;
//control signal
wire          MEM_reg_w;//1
wire          MEM_branch;//1
wire          MEM_mem_r;//1
wire          MEM_mem_w;//1
wire          MEM_mem_to_reg;//1
wire          MEM_alu_zero;//1

/**** WB stage ****/
wire [5-1:0]  WB_regw_addr;
wire [32-1:0] WB_regw_data;
wire [32-1:0] WB_read_data;
wire [32-1:0] WB_alu_rlt;

//control signal
wire WB_reg_w;
wire WB_mem_to_reg;


//wire [2-1:0]    forwardA;
//wire [2-1:0]    forwardB;
/****************************************
Instantiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux0(
    .data0_i(IF_pc_add4),
	.data1_i(IF_branch_rlt),
	.select_i(IF_pc_src),
	.data_o(IF_pc_in)
);

ProgramCounter PC(
    .clk_i(clk_i),      
	.rst_i(rst_i), 
	.pc_in_i(IF_pc_in),
	.pc_out_o(IF_pc_out)
);

Instruction_Memory IM(
	.addr_i(IF_pc_out),
	.instr_o(IF_instr)
);
			
Adder Add_pc(
	.src1_i(32'd4),
	.src2_i(IF_pc_out),
	.sum_o(IF_pc_add4)  
);

		
Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i({IF_pc_add4,IF_instr}),
	.data_o({ID_pc_add4,ID_instr})
);


//Instantiate the components in ID stage
Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(ID_instr[25:21]),
    .RTaddr_i(ID_instr[20:16]),
    .RDaddr_i(WB_regw_addr),
    .RDdata_i(WB_regw_data),
    .RegWrite_i(WB_reg_w),
    .RSdata_o(ID_r_data1),
    .RTdata_o(ID_r_data2)
);

Decoder Control(
    .instr_op_i(ID_instr[31:26]),
	.RegWrite_o(ID_reg_w),
	.ALU_op_o(ID_alu_op),
	.ALUSrc_o(ID_alu_src),
	.RegDst_o(ID_reg_dst),
	.Branch_o(ID_branch),
	.MemRead_o(ID_mem_r),
	.MemWrite_o(ID_mem_w),
	.MemtoReg_o(ID_mem_to_reg)
);

Sign_Extend Sign_Extend(
	.data_i(ID_instr[15:0]),
	.data_o(ID_ext)
);	

Pipe_Reg #(.size(128+10+10)) ID_EX(
    .clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(
        {
        ID_pc_add4,//32
        ID_reg_w,//1
        ID_alu_op,//4
        ID_alu_src,//1
        ID_reg_dst,//1
        ID_branch,//1
        ID_mem_r,//1
        ID_mem_w,//1
        ID_mem_to_reg,//1
        ID_r_data1,//32
        ID_r_data2,//32
        ID_ext,//32
        ID_regw_addr1,//5
        ID_regw_addr2}),//5
	.data_o(
        {
        EX_pc_add4,
        EX_reg_w,//1
        EX_alu_op,//3
        EX_alu_src,//1
        EX_reg_dst,//1
        EX_branch,//1
        EX_mem_r,//1
        EX_mem_w,//1
        EX_mem_to_reg,//1
        EX_r_data1,//32
        EX_r_data2,//32
        EX_ext,//32
        EX_regw_addr1,//5
        EX_regw_addr2})//5
);

//Instantiate the components in EX stage	   
Shift_Left_Two_32 Shifter(
        .data_i(EX_ext),
        .data_o(EX_sh_le)
);



ALU ALU(
       .src1_i(EX_r_data1),
	   .src2_i(EX_mux_to_alu),
	   .ctrl_i(EX_alu_ctrl),
	   .result_o(EX_alu_rlt),
	   .zero_o(EX_alu_zero)
);
		
ALU_Ctrl ALU_Control(
          .funct_i(EX_ext[5:0]),
          .ALUOp_i(EX_alu_op),
          .ALUCtrl_o(EX_alu_ctrl)
);

//MUX_3to1 #(.size(32)) Mux5(
//    .data0_i(EX_r_data2),
//	.data1_i(MEM_alu_rlt),
//	.data2_i(WB_regw_data),
//	.select_i(forwardB),
//	.data_o(EX_forward_to_mux)
//);

MUX_2to1 #(.size(32)) Mux1(
    .data0_i(EX_r_data2),
	.data1_i(EX_ext),
	.select_i(EX_alu_src),
	.data_o(EX_mux_to_alu)
);
		
MUX_2to1 #(.size(5)) Mux2(
    .data0_i(EX_regw_addr1),
	.data1_i(EX_regw_addr2),
	.select_i(EX_reg_dst),
	.data_o(EX_regw_addr)
);

Adder Add_pc_branch(
    .src1_i(EX_pc_add4),
	.src2_i(EX_sh_le),
	.sum_o(EX_pc_branch)
);

//////////////

//ForwardUnit ForwardUnit(
//	.ID_EX_RegisterRs_i(EX_RS),
//	.ID_EX_RegisterRt_i(EX_RT),
//	.EX_MEM_RegWrite_i(MEM_reg_w),
//	.EX_MEM_RegisterRd_i(MEM_regw_addr),
//	.MEM_WB_RegWrite_i(WB_reg_w),
//      .MEM_WB_RegisterRd_i(WB_regw_addr),
//	.ForwardA_o(forwardA),
//	.ForwardB_o(forwardB)
//);
//////////////

Pipe_Reg #(.size(97+5+5)) EX_MEM(
    .clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(
        {EX_pc_branch,//32
        EX_reg_w,//1
        EX_branch,//1
        EX_mem_r,//1
        EX_mem_w,//1
        EX_mem_to_reg,//1
        EX_alu_zero,
        EX_alu_rlt,//32
        EX_r_data2,//32
        EX_regw_addr}),//5
	.data_o(
        {MEM_pc_branch,//32
        MEM_reg_w,//1
        MEM_branch,//1
        MEM_mem_r,//1
        MEM_mem_w,//1
        MEM_mem_to_reg,//1
        MEM_alu_zero,
        MEM_alu_rlt,//32
        MEM_r_data2,//32
        MEM_regw_addr})//5
);

//Instantiate the components in MEM stage
Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(MEM_alu_rlt),
    .data_i(MEM_r_data2),
    .MemRead_i(MEM_mem_r),
    .MemWrite_i(MEM_mem_w),
    .data_o(MEM_read_data)
);

Pipe_Reg #(.size(64+5+2)) MEM_WB(
    .clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(
        {MEM_reg_w,
        MEM_mem_to_reg,
        MEM_read_data,
        MEM_alu_rlt,
        MEM_regw_addr}),
	.data_o(
        {WB_reg_w,//1
        WB_mem_to_reg,//1
        WB_read_data,//32
        WB_alu_rlt,//32
        WB_regw_addr})//5
);


//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux3(
    .data0_i(WB_alu_rlt),
	.data1_i(WB_read_data),
	.select_i(WB_mem_to_reg),
	.data_o(WB_regw_data)
);



/****************************************
signal assignment
****************************************/

assign ID_regw_addr1 = ID_instr[20:16];
assign ID_regw_addr2 = ID_instr[15:11];
assign IF_pc_src = MEM_branch & MEM_alu_zero;
assign IF_branch_rlt = EX_pc_branch;

endmodule

