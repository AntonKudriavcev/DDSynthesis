
module buffer(

    input wire        CLK,
    input wire        RESET,

    input wire [11:0] BUF_IN,

    output reg [11:0] BUF_OUT);

//--user parameters------------------------------------------------------------
 

//--user variables-------------------------------------------------------------
    reg [11:0] buffer = 12'bz; 
//-----------------------------------------------------------------------------

    initial begin
        BUF_OUT       = 12'bz;
    end

//-----------------------------------------------------------------------------

    always @(posedge CLK) begin
        if (RESET) begin
            BUF_OUT = 12'bz;
			buffer  = 12'bz;
        end else begin
        	BUF_OUT = buffer;
        	buffer  = BUF_IN;
        end
    end

endmodule