//vsim -gui -L altera_mf_ver work.div_tb

`timescale 1ns/1ps

module div_tb;

    reg           clk;
    reg           reset;

    wire [15:0]   denom;
    wire [15:0]   numer;

    wire [15:0]   quotient;
    wire [15:0]   remain;

    div    div   (.clock      (clk),
                  .denom      (denom),
                  .numer      (numer),

                  .quotient   (quotient),
                  .remain     (remain));

    transm transm(.CLK        (clk),
                  .RESET      (reset),
                  .quotient   (quotient),
                  .remain     (remain),

                  .denom      (denom),
                  .numer      (numer));

    //-----------------------------------------------------------------------------
    
    initial begin
        clk     = 0;
        reset   = 0;        
    end

//-----------------------------------------------------------------------------

    always #1 clk = ~clk;
  
endmodule
 