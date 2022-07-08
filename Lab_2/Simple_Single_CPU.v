//Subject:     CO project 2 - Simple Single CPU
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
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//PC
wire [32-1:0] pc_addr_i;
wire [32-1:0] adder_mux_PC;
//IM
wire [32-1:0] inst;
//adder1
wire [32-1:0] adder1_o;
//IM_mux_RF
wire [5-1:0] IM_mux_RF;
//RF
wire [32-1:0] RF_1_o;
wire [32-1:0] RF_2_o;
//decoder
wire RegDst_o;
wire RegWrite_o;
wire Branch_o;
wire [3-1:0] ALU_op_o;
wire ALUSrc_o;
//Sign_Extend
wire [32-1:0] SE_o;
//shifter
wire [32-1:0] SH_o;
//adder2
wire [32-1:0] adder2_o;
//ALUCtrl
wire [4-1:0] ALUCtrl_o;
//RF_mux_ALU
wire [32-1:0] RF_mux_ALU;
//ALU
wire [32-1:0] ALU_result_o;
wire zero;

wire mux_PC_select;
assign mux_PC_select = zero & Branch_o;
//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(adder_mux_PC) ,   
	    .pc_out_o(pc_addr_i) 
	    );
	
Adder Adder1(
        .src1_i(32'd4),     
	    .src2_i(pc_addr_i),     
	    .sum_o(adder1_o)    
	    );
	    
Instr_Memory IM(
        .pc_addr_i(pc_addr_i),  
	    .instr_o(inst)    
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(inst[20:16]),
        .data1_i(inst[15:11]),
        .select_i(RegDst_o),
        .data_o(IM_mux_RF)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(inst[25:21]) ,  
        .RTaddr_i(inst[20:16]) ,  
        .RDaddr_i(IM_mux_RF) ,  
        .RDdata_i(ALU_result_o) , 
        .RegWrite_i (RegWrite_o),
        .RSdata_o(RF_1_o) ,  
        .RTdata_o(RF_2_o)   
        );
	
Decoder Decoder(
        .instr_op_i(inst[31:26]), 
	    .RegWrite_o(RegWrite_o), 
	    .ALU_op_o(ALU_op_o),   
	    .ALUSrc_o(ALUSrc_o),   
	    .RegDst_o(RegDst_o),   
		.Branch_o(Branch_o)   
	    );

ALU_Ctrl AC(
        .funct_i(inst[5:0]),   
        .ALUOp_i(ALU_op_o),   
        .ALUCtrl_o(ALUCtrl_o) 
        );
	
Sign_Extend SE(
        .data_i(inst[15:0]),
        .data_o(SE_o)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RF_2_o),
        .data1_i(SE_o),
        .select_i(ALUSrc_o),
        .data_o(RF_mux_ALU)
        );	
		
ALU ALU(
        .src1_i(RF_1_o),
	    .src2_i(RF_mux_ALU),
	    .ctrl_i(ALUCtrl_o),
	    .result_o(ALU_result_o),
		.zero_o(zero)
	    );
		
Adder Adder2(
        .src1_i(adder1_o),     
	    .src2_i(SH_o),     
	    .sum_o(adder2_o)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(SE_o),
        .data_o(SH_o)
        ); 		
		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(adder1_o),
        .data1_i(adder2_o),
        .select_i(mux_PC_select),
        .data_o(adder_mux_PC)
        );	

endmodule
		  


