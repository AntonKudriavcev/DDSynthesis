
module noise_generator(

    input wire        CLK,
    input wire        RESET,

    input wire [ 1:0] SIGNAL_TYPE,
    input wire [ 9:0] T_IMPULSE,

    input wire        SIGN_START_GEN,
    input wire        OUT_REG_READY,

    output reg        SIGN_START_CALC, // inform output reg which calculation of phase started
    output reg        SIGN_STOP_CALC,  // inform output reg which calculation of phase stopped

    output reg [11:0] NOISE_OUT); 

//--user parameters------------------------------------------------------------

    parameter _SAMPLING_FREQ    = 34'd 13_000000000; // 13 GHz

    parameter _M_REQ            = 11'd 2047;   // required mathematical expectation
    parameter _SIGMA_REQ        = 10'd 682;    // required standart deviation
    parameter _M_COMPENS        = 19'd 393222; // mathematical expectation of summation
    parameter _SIGMA_COMPENS    = 16'd 65535;  // standart deviation of summation
    parameter _M_CALC           = 11'd 2045;
    parameter _RND_GEN_BIT_DEPH =  6'd 36;     // the bit depth of a random variable modeled by a congruent generator
    parameter _RND_VAL_BIT_DEPH =  5'd 16;     // required bit depth of a random variable
    parameter _Z_INITIAL        = 14'd 16383;  // initial value of random generator
    parameter _L                =  5'd 31;
    parameter _U                =  1'd 1;

    parameter _NOISE_SIGNAL_TYPE =  2'd 3;

//--user variables-------------------------------------------------------------

    reg        busy            = 0; // flag which indicates that noise_generator 
                                    // received SIGN_START_GEN and output register 
                                    // is ready for work (LFM_phase_accum starts 
                                    // calculate phase of signal from ROM)

    reg [ 9:0] t_impulse       = 0; // from 60 to 650us  (1023us)

    reg [31:0] num_of_samples  = 0; // from 0 to 2627950000 - 1
    reg [31:0] samples_counter = 0; // from 0 to 2627950000 - 1

    reg [35:0] z               = 0; // random value of a congruent generator
    reg [36:0] rnd             = 0; // required random value


//-----------------------------------------------------------------------------
    initial begin
        SIGN_START_CALC = 0;
        SIGN_STOP_CALC  = 0;
        NOISE_OUT       = 12'bz;
    end
//-----------------------------------------------------------------------------

    always @(posedge CLK) begin
        if (RESET) begin
            // reset
            
        end else if (SIGN_START_GEN && !busy && OUT_REG_READY && (SIGNAL_TYPE == _NOISE_SIGNAL_TYPE)) begin

            t_impulse      = T_IMPULSE;  // save parameters
            num_of_samples = t_impulse * (_SAMPLING_FREQ/1000000);

            rnd = _Z_INITIAL;
            z   = _Z_INITIAL;

            SIGN_START_CALC <= 1; // clear flag for output register 
            busy            <= 1; // set flag for next step

        end else if (busy) begin

            if (SIGN_START_CALC) begin
                SIGN_START_CALC <= 0;
            end
            
            if (samples_counter < num_of_samples) begin

                NOISE_OUT       = rnd[11:0];
                samples_counter = samples_counter + 1; // calculate number of the next sample

                if (samples_counter == (num_of_samples)) begin // if the current sample is the last one in the package
                    SIGN_STOP_CALC = 1; // set flag for output register 
                end else begin // if the current sample is not the last one in the package calculate new ROM address

                    rnd = 0;

                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];
                    z   = (_L * z + _U);
                    rnd = rnd + z[35:20];

                    rnd = ((rnd * _SIGMA_REQ)/_SIGMA_COMPENS - _M_CALC);

                end

            end else if (samples_counter == num_of_samples) begin // if this sample is the next one after the last one in the package
                SIGN_STOP_CALC  <= 0; // clear flag for output register 
                samples_counter <= 0; // reset the counter
                busy            <= 0; // clear flag busy of phase accum 

                rnd             <= 0;
                z               <= 0;

                NOISE_OUT       <= 12'bz;
            end             
        end
    end

endmodule