//Subject:     CO project 4 - Sign extend
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:        109700045
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Sign_Extend(
    data_i,
    data_o
    );
               
//I/O ports
input   [16-1:0] data_i;
output  [32-1:0] data_o;

//Internal Signals
reg     [32-1:0] data_o;

//Sign extended
always	@(data_i)begin
	data_o[16-1: 0] <= data_i;
	data_o[32-1:16] <= data_i[15] ? 16'hffff : 16'h0;
end
          
endmodule      
     