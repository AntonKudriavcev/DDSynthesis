module ROM_writer(
    input wire        CLK,
    input wire        RESET,
    output reg [11:0] ROM_ADDRESS);
    
    reg [11:0] address = 1;
    
    initial ROM_ADDRESS = 1;
    
    always @(posedge CLK) begin
        address = address + 1;
        ROM_ADDRESS = address;
    end

endmodule
