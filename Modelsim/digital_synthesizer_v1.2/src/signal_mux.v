
module signal_mux(

    input wire        CLK,
    input wire        RESET,

    input wire [11:0] DATA_FROM_LFM,
    input wire [11:0] DATA_FROM_PSK,
    input wire        SIGN_LFM_START_CALC,
    input wire        SIGN_PSK_START_CALC,
    input wire        SIGN_LFM_STOP_CALC,
    input wire        SIGN_PSK_STOP_CALC,

    output reg [11:0] MUX_OUT);

//--user parameters------------------------------------------------------------


//--user variables-------------------------------------------------------------

    reg sign_LFM_busy = 0;
    reg sign_PSK_busy = 0;
    reg sign_LFM_stop = 0;
    reg sign_PSK_stop = 0;

//-----------------------------------------------------------------------------

    initial begin 
        MUX_OUT = 12'bz;
    end 

//-----------------------------------------------------------------------------

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin

            sign_LFM_busy <= 0; // clear flag
            sign_PSK_busy <= 0; // clear flag
            sign_LFM_stop <= 0; // clear flag
            sign_PSK_stop <= 0; // clear flag

            MUX_OUT       <= 12'bz;
            
        end else begin
            // if SIGN_LFM_START_CALC was received and mux doesnt already work
            if (SIGN_LFM_START_CALC && !sign_LFM_busy && !sign_PSK_busy && !sign_LFM_stop && !sign_PSK_stop) begin 
                sign_LFM_busy = 1; // set flag
            // if SIGN_PSK_START_CALC was received and mux doesnt already work
            end else if (SIGN_PSK_START_CALC && !sign_LFM_busy && !sign_PSK_busy && !sign_LFM_stop && !sign_PSK_stop) begin 
                sign_PSK_busy = 1; // set flag
            end else if (sign_LFM_busy) begin

                MUX_OUT = DATA_FROM_LFM;

                if (SIGN_LFM_STOP_CALC && !sign_LFM_stop) begin // if SIGN_LFM_STOP_CALC was received 
                    sign_LFM_busy <= 0; // clear flag
                    sign_LFM_stop <= 1; // set flag for next step
                end 

            end else if (sign_PSK_busy) begin

                MUX_OUT = DATA_FROM_PSK;

                if (SIGN_PSK_STOP_CALC && !sign_PSK_stop) begin
                    sign_PSK_busy <= 0; // clear flag
                    sign_PSK_stop <= 1; // set flag for next step
                end 

            end else if (sign_LFM_stop || sign_PSK_stop) begin
                sign_LFM_stop <= 0; // clear flag
                sign_PSK_stop <= 0; // clear flag
                MUX_OUT       <= 12'bz; 
            end  
        end
    end

endmodule