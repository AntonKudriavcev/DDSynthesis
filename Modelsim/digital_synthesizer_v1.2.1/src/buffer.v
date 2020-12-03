
module buffer(

    input wire        CLK,
    input wire        RESET,

    input wire [11:0] DATA_FROM_NOISE,

    output reg [11:0] BUF_OUT);

//--user parameters------------------------------------------------------------
 

//--user variables-------------------------------------------------------------
    reg [11:0] buf_var_1 = 12'bz; 
    reg [11:0] buf_var_2 = 12'bz; 
//-----------------------------------------------------------------------------

    initial begin
        BUF_OUT       = 12'bz;
    end

//-----------------------------------------------------------------------------

    always @(posedge CLK) begin
        if (RESET) begin
            BUF_OUT    = 12'bz;
			buf_var_1  = 12'bz;
            buf_var_2  = 12'bz;
        end else begin
        	BUF_OUT    = buf_var_2;
        	buf_var_2  = buf_var_1;
            buf_var_1  = DATA_FROM_NOISE;
        end
    end

endmodule