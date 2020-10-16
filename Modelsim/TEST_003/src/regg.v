module regg(
    input wire       CLK,
    input wire       RESET,

    input wire [3:0] INPUT,
    output reg [3:0] OUT);

    initial begin
    OUT = 0;
    end

    always @(posedge CLK, posedge RESET) begin
        if (RESET) begin
            OUT     = 0;
        end else begin
            OUT     = INPUT;
        end

    end

endmodule
    