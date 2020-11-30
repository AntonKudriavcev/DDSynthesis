
module output_reg(

    input wire CLK,
    input wire RESET,

    input wire [11:0] DATA_FROM_ROM,
    input wire [11:0] DATA_FROM_FIFO,
    input wire        SIGN_LFM_START_CALC,
    input wire        SIGN_PSK_START_CALC,
    input wire        SIGN_NOISE_START_CALC,
    input wire        SIGN_LFM_STOP_CALC,
    input wire        SIGN_PSK_STOP_CALC,
    input wire        SIGN_NOISE_STOP_CALC,

    output reg        READY,
    output reg        FIFO_REQ,
    output reg [11:0] REG_OUT);

//--user parameters------------------------------------------------------------
    parameter _DELAY_START = 5'd 3 + 23 + 1; // the delay that should occur between 
                                    // receiving SIGN_START_CALC and outputting 
                                    // data from the register input to the output

    parameter _DELAY_STOP  = 2'd 3; // the delay that should occur between 
                                    // receiving SIGN_STOP_CALC and
                                    // output of the z-state

    parameter _LFM_SIGNAL_TYPE   =  2'd 1;
    parameter _PSK_SIGNAL_TYPE   =  2'd 2;
    parameter _NOISE_SIGNAL_TYPE =  2'd 3;

//--user variables-------------------------------------------------------------
    reg [4:0] counter_start  = 0; // counter for _DELAY_START
    reg [1:0] counter_stop   = 0; // counter for _DELAY_STOP

    reg       sign_start = 0; // flag which indicates that output reg received 
                              // SIGN_START_CALC 

    reg       sign_stop  = 0; // flag which indicates that output reg received 
                              // SIGN_STOP_CALC 

    reg [1:0] signal_type = 0;
//-----------------------------------------------------------------------------

    initial begin
        REG_OUT  = 12'bz;
        FIFO_REQ = 0;
        READY    = 1;
    end

//-----------------------------------------------------------------------------

    always @(posedge CLK) begin
        if (RESET) begin

            REG_OUT       <= 12'bz;
            READY         <= 1;
            FIFO_REQ      <= 0;
            sign_start    <= 0;
            sign_stop     <= 0;
            signal_type   <= 0;
            counter_start <= 0;
            counter_stop  <= 0;

        end else if((SIGN_LFM_START_CALC || SIGN_PSK_START_CALC || SIGN_NOISE_START_CALC) && !sign_start) begin
            sign_start = 1;
            READY      = 0;
            if (SIGN_LFM_START_CALC) begin
               signal_type = _LFM_SIGNAL_TYPE;
            end else if (SIGN_PSK_START_CALC) begin
                signal_type = _PSK_SIGNAL_TYPE;
            end else if (SIGN_NOISE_START_CALC) begin
                signal_type = _NOISE_SIGNAL_TYPE;
            end

        end else if(sign_start) begin
//-----------------------------------------------------------------------------
            if (counter_start != _DELAY_START) begin
                counter_start = counter_start + 1;

                if((counter_start == _DELAY_START) && (signal_type == _NOISE_SIGNAL_TYPE)) begin
                    FIFO_REQ = 1;
                end

//-----------------------------------------------------------------------------
                if ((SIGN_LFM_STOP_CALC || SIGN_PSK_STOP_CALC || SIGN_NOISE_STOP_CALC) && !sign_stop) begin 
                    sign_stop = 1;
                end else if (sign_stop) begin
                    if (counter_stop != _DELAY_STOP) begin
                        counter_stop = counter_stop + 1;
                    end
                end
//-----------------------------------------------------------------------------

            end else if ((counter_start == _DELAY_START) && (counter_stop != _DELAY_STOP)) begin

                case(signal_type)
                    _LFM_SIGNAL_TYPE  : REG_OUT = DATA_FROM_ROM;
                    _PSK_SIGNAL_TYPE  : REG_OUT = DATA_FROM_ROM;
                    _NOISE_SIGNAL_TYPE: REG_OUT = DATA_FROM_FIFO;
                    default           : REG_OUT = 12'bz;
                endcase

//-----------------------------------------------------------------------------
                if ((SIGN_LFM_STOP_CALC || SIGN_PSK_STOP_CALC || SIGN_NOISE_STOP_CALC) && !sign_stop) begin 
                    sign_stop = 1;
                end else if (sign_stop) begin
                    if (counter_stop != _DELAY_STOP) begin
                        counter_stop = counter_stop + 1;
                    end
                end
//-----------------------------------------------------------------------------

            end else if ((counter_start == _DELAY_START) && (counter_stop == _DELAY_STOP)) begin
                REG_OUT       <= 12'bz;
                READY         <= 1;
                FIFO_REQ      <= 0;
                sign_start    <= 0;
                sign_stop     <= 0;
                signal_type   <= 0;
                counter_start <= 0;
                counter_stop  <= 0;
            end

        end
    end


endmodule

