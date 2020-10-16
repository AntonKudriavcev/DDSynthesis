`timescale 10ns/1ps

module test_tb;

//-----------------------------------------------------------------------------

    reg         clk;
    reg         reset;

    wire        [3:0] counter_to_reg;
    wire        [3:0] reg_to_buf;
    wire        [3:0] buf_to_reg;
    wire        [3:0] out;

    counter    counter_1   (.CLK    (clk), 
                            .RESET  (reset), 
                            .OUT    (counter_to_reg));

    regg       input_reg   (.CLK    (clk), 
                            .RESET  (reset), 
                            .INPUT  (counter_to_reg), 
                            .OUT    (reg_to_buf));

    buff       buff1       (.DATA   (reg_to_buf),
                            .OUT    (buf_to_reg));

    regg       output_reg  (.CLK    (clk), 
                            .RESET  (reset), 
                            .INPUT  (buf_to_reg), 
                            .OUT    (out));

    initial begin 
        clk = 0;
        reset = 0;
    end 

    always begin
        #1 clk = ~ clk;
    end

endmodule