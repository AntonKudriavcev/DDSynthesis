module counter(
    input wire       CLK,
    input wire       RESET,
    output reg [3:0] OUT);


    reg [3:0] counter = 0;

    initial begin
	OUT = 0;
    end

    always @(posedge CLK, posedge RESET) begin
        if (RESET) begin
	    counter = 0;
            OUT     = 0;
        end else begin
            counter = counter + 1;
	    OUT     = counter;
        end

    end

endmodule
