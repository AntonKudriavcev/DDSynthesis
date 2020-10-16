
module output_reg(

    input wire CLK,
    input wire RESET,

    input wire [11:0] INPUT,
    input wire        SIGN_START_CALC,
    input wire        SIGN_STOP_CALC,

    output reg        READY,
    output reg [11:0] OUTPUT);

//--user parameters------------------------------------------------------------
    parameter _DELAY_START = 2'd 3; // the delay that should occur between 
                                    // receiving SIGN_START_CALC and outputting 
                                    // data from the register input to the output

    parameter _DELAY_STOP  = 2'd 2; // the delay that should occur between 
                                    // receiving SIGN_STOP_CALC and
                                    // output of the z-state
//--user variables-------------------------------------------------------------
    reg [1:0] counter_start = 0; // counter for _DELAY_START
    reg [1:0] counter_stop  = 0; // counter for _DELAY_STOP
    reg       sign_start    = 0; // flag which indicates that output reg received 
                                 // SIGN_START_CALC 

    reg       sign_stop     = 0; // flag which indicates that output reg received 
                                 // SIGN_STOP_CALC 
//-----------------------------------------------------------------------------

    initial begin
        OUTPUT = 12'bz;
        READY  = 1;
    end

    always @(posedge CLK) begin
        if (RESET) begin
            // reset commands
        end else if(SIGN_START_CALC && !sign_start) begin
            sign_start = 1;
            READY      = 0;
        end else if(sign_start) begin
//-----------------------------------------------------------------------------
            if (counter_start != _DELAY_START) begin
                counter_start = counter_start + 1;

//-----------------------------------------------------------------------------
                if (SIGN_STOP_CALC && !sign_stop) begin 
                    sign_stop = 1;
                end else if (sign_stop) begin
                    if (counter_stop != _DELAY_STOP) begin
                        counter_stop = counter_stop + 1;
                    end
                end
//-----------------------------------------------------------------------------

            end else if ((counter_start == _DELAY_START) && (counter_stop != _DELAY_STOP)) begin
                OUTPUT = INPUT;

//-----------------------------------------------------------------------------
                if (SIGN_STOP_CALC && !sign_stop) begin 
                    sign_stop = 1;
                end else if (sign_stop) begin
                    if (counter_stop != _DELAY_STOP) begin
                        counter_stop = counter_stop + 1;
                    end
                end
//-----------------------------------------------------------------------------

            end else if ((counter_start == _DELAY_START) && (counter_stop == _DELAY_STOP)) begin
                counter_start = 0;
                counter_stop  = 0;
                sign_start    = 0;
                sign_stop     = 0;
                READY         = 1;
                OUTPUT        = 12'bz;
            end

        end
    end


endmodule

