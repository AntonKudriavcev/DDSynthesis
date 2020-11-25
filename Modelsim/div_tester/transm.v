
module transm (

    input wire CLK,
    input wire RESET,

    input wire [15:0] quotient,
    input wire [15:0] remain,

    output reg [15:0] denom,
    output reg [15:0] numer);


    reg [15:0] var1 = 1000;
    reg [15:0] var2 = 10;

    reg [15:0] var3 = 0;
    reg [15:0] var4 = 0;


    always @(posedge CLK) begin
        if (RESET) begin
            // reset
            
        end else begin
            var1 <= var1 + 1;
            var2 <= var2 + 1;

            numer = var1;
            denom = var2;

            var3  = quotient;
            var4  = remain;
        end
    end

endmodule

