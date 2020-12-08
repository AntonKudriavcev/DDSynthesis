
module input_block(

    input wire        CLK,
    input wire        RESET,
     
    output reg        SIGN_START_GENx,
     
    output reg [ 1:0] SIGNAL_TYPEx,
    output reg [31:0] F_CARRIERx,
    output reg [ 9:0] T_IMPULSEx,

    output reg [ 5:0] NUM_OF_IMPx, // from 0 to 63
    output reg        VOBULATIONx,

    output reg [12:0] T_PERIOD_1x,
    output reg [12:0] T_PERIOD_2x,
    output reg [12:0] T_PERIOD_3x,
    output reg [12:0] T_PERIOD_4x,
    output reg [12:0] T_PERIOD_5x,
    output reg [12:0] T_PERIOD_6x,
    output reg [12:0] T_PERIOD_7x,
    output reg [12:0] T_PERIOD_8x,
    output reg [12:0] T_PERIOD_9x,
    output reg [12:0] T_PERIOD_10x,
    output reg [12:0] T_PERIOD_11x,
    output reg [12:0] T_PERIOD_12x,
    output reg [12:0] T_PERIOD_13x,
    output reg [12:0] T_PERIOD_14x,
    output reg [12:0] T_PERIOD_15x,
    output reg [12:0] T_PERIOD_16x,
    output reg [12:0] T_PERIOD_17x,
    output reg [12:0] T_PERIOD_18x,
    output reg [12:0] T_PERIOD_19x,
    output reg [12:0] T_PERIOD_20x,
    output reg [12:0] T_PERIOD_21x,
    output reg [12:0] T_PERIOD_22x,
    output reg [12:0] T_PERIOD_23x,
    output reg [12:0] T_PERIOD_24x,
    output reg [12:0] T_PERIOD_25x,
    output reg [12:0] T_PERIOD_26x,
    output reg [12:0] T_PERIOD_27x,
    output reg [12:0] T_PERIOD_28x,
    output reg [12:0] T_PERIOD_29x,
    output reg [12:0] T_PERIOD_30x,
    output reg [12:0] T_PERIOD_31x,
    output reg [12:0] T_PERIOD_32x,

    output reg [21:0] DEVIATIONx); // inform output reg which calculation of phase stopped

//--user parameters------------------------------------------------------------

//--user variables-------------------------------------------------------------

//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------

    always @(posedge CLK) begin

        if (RESET) begin
            
        end else begin
            
        end
    end

endmodule
