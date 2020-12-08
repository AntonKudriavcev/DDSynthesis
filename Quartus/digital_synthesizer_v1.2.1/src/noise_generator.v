
module noise_generator(

    input wire        CLK,
    input wire        RESET,

    input wire [ 1:0] SIGNAL_TYPE,
    input wire [ 9:0] T_IMPULSE,

    input wire        SIGN_START_GEN,
    input wire        OUT_REG_READY,

    output reg        SIGN_START_CALC, // inform output reg which calculation of phase started
    output reg        SIGN_STOP_CALC,  // inform output reg which calculation of phase stopped

    output reg        SUM_START,
    output reg        SUM_STOP,

    output reg [11:0] RND1,
    output reg [11:0] RND2,
    output reg [11:0] RND3,
    output reg [11:0] RND4,
    output reg [11:0] RND5,
    output reg [11:0] RND6,
    output reg [11:0] RND7,
    output reg [11:0] RND8,
    output reg [11:0] RND9,
    output reg [11:0] RND10,
    output reg [11:0] RND11,
    output reg [11:0] RND12); 

//--user parameters------------------------------------------------------------

    // sampling frequency = 130000 MHz = 1625 << 3 MHz
    parameter _SAMP_FREQ_VALUE2 = 11'd 1625; 
    parameter _SAMP_FREQ_SHIFT2 =  2'd 3;

    // parameter _M_REQ            = 11'd 2047;   // required mathematical expectation
    // parameter _SIGMA_REQ        = 10'd 682;    // required standart deviation
    // parameter _M_COMPENS        = 19'd 393222; // mathematical expectation of summation
    // parameter _SIGMA_COMPENS    = 16'd 65535;  // standart deviation of summation
    // parameter _M_CALC           = 11'd 2045;
    // parameter _RND_GEN_BIT_DEPH =  6'd 36;     // the bit depth of a random variable modeled by a congruent generator
    // parameter _RND_VAL_BIT_DEPH =  5'd 16;     // required bit depth of a random variable
    parameter _L_BIT_RES        =  3'd 5;
    parameter _U                =  1'd 1;

    parameter _Z_INITIAL1  = 14'd 2047;  // initial value of random generator
    parameter _Z_INITIAL2  = 14'd 1023;  // initial value of random generator
    parameter _Z_INITIAL3  = 14'd 511;  // initial value of random generator
    parameter _Z_INITIAL4  = 14'd 255;  // initial value of random generator
    parameter _Z_INITIAL5  = 14'd 127;  // initial value of random generator
    parameter _Z_INITIAL6  = 14'd 63;  // initial value of random generator
    parameter _Z_INITIAL7  = 14'd 31;  // initial value of random generator
    parameter _Z_INITIAL8  = 14'd 15;  // initial value of random generator
    parameter _Z_INITIAL9  = 14'd 7;  // initial value of random generator
    parameter _Z_INITIAL10 = 14'd 3;  // initial value of random generator
    parameter _Z_INITIAL11 = 14'd 1;  // initial value of random generator
    parameter _Z_INITIAL12 = 14'd 0;  // initial value of random generator

    parameter _NOISE_SIGNAL_TYPE =  2'd 3;

//--user variables-------------------------------------------------------------

    reg        busy            = 0; // flag which indicates that noise_generator 
                                    // received SIGN_START_GEN and output register 
                                    // is ready for work (LFM_phase_accum starts 
                                    // calculate phase of signal from ROM)

    reg [31:0] num_of_samples  = 0; // from 0 to 274877906943
    reg [31:0] samples_counter = 0; // from 0 to 274877906943

    reg [35:0] z1              = 0; // random value of a congruent generator
    reg [35:0] z2              = 0; // random value of a congruent generator
    reg [35:0] z3              = 0; // random value of a congruent generator
    reg [35:0] z4              = 0; // random value of a congruent generator
    reg [35:0] z5              = 0; // random value of a congruent generator
    reg [35:0] z6              = 0; // random value of a congruent generator
    reg [35:0] z7              = 0; // random value of a congruent generator
    reg [35:0] z8              = 0; // random value of a congruent generator
    reg [35:0] z9              = 0; // random value of a congruent generator
    reg [35:0] z10             = 0; // random value of a congruent generator
    reg [35:0] z11             = 0; // random value of a congruent generator
    reg [35:0] z12             = 0; // random value of a congruent generator

//-----------------------------------------------------------------------------
    initial begin
        SIGN_START_CALC = 0;
        SIGN_STOP_CALC  = 0;
        SUM_START       = 0;
        SUM_STOP        = 0;

        RND1            = 12'bz;
        RND2            = 12'bz;
        RND3            = 12'bz;
        RND4            = 12'bz;
        RND5            = 12'bz;
        RND6            = 12'bz;
        RND7            = 12'bz;
        RND8            = 12'bz;
        RND9            = 12'bz;
        RND10           = 12'bz;
        RND11           = 12'bz;
        RND12           = 12'bz;
    end
//-----------------------------------------------------------------------------

    always @(posedge CLK) begin
        if (RESET) begin

            SIGN_STOP_CALC  <= 0; // clear flag for output register 
            SIGN_START_CALC <= 0;
            SUM_STOP        <= 0;
            SUM_START       <= 0;
            samples_counter <= 0; // reset the counter
            num_of_samples  <= 0; 
            busy            <= 0; // clear flag busy of phase accum 

            z1              <= 0;
            z2              <= 0;
            z3              <= 0;
            z4              <= 0;
            z5              <= 0;
            z6              <= 0;
            z7              <= 0;
            z8              <= 0;
            z9              <= 0;
            z10             <= 0;
            z11             <= 0;
            z12             <= 0;

            RND1            <= 12'bz;
            RND2            <= 12'bz;
            RND3            <= 12'bz;
            RND4            <= 12'bz;
            RND5            <= 12'bz;
            RND6            <= 12'bz;
            RND7            <= 12'bz;
            RND8            <= 12'bz;
            RND9            <= 12'bz;
            RND10           <= 12'bz;
            RND11           <= 12'bz;
            RND12           <= 12'bz;
            
        end else if (SIGN_START_GEN && !busy && OUT_REG_READY && (SIGNAL_TYPE == _NOISE_SIGNAL_TYPE)) begin

            num_of_samples <= (T_IMPULSE * _SAMP_FREQ_VALUE2) << _SAMP_FREQ_SHIFT2; // calculate num of samples for all packet

            z1  <= _Z_INITIAL1;
            z2  <= _Z_INITIAL2;
            z3  <= _Z_INITIAL3;
            z4  <= _Z_INITIAL4;
            z5  <= _Z_INITIAL5;
            z6  <= _Z_INITIAL6;
            z7  <= _Z_INITIAL7;
            z8  <= _Z_INITIAL8;
            z9  <= _Z_INITIAL9;
            z10 <= _Z_INITIAL10;
            z11 <= _Z_INITIAL11;
            z12 <= _Z_INITIAL12;

            SIGN_START_CALC <= 1; // clear flag for output register 
            busy            <= 1; // set flag for next step
            SUM_START       <= 1;

        end else if (busy) begin

            if (SIGN_START_CALC) begin
                SIGN_START_CALC <= 0;
            end

            if (SUM_START) begin
                SUM_START <= 0;
            end
            
            if (samples_counter < num_of_samples) begin

                samples_counter = samples_counter + 1; // calculate number of the next sample

                if (samples_counter == (num_of_samples)) begin // if the current sample is the last one in the package
                    SIGN_STOP_CALC <= 1; // set flag for output register 
                    SUM_STOP       <= 1;
                end  // if the current sample is not the last one in the package calculate new ROM address

                z1  <= ((z1  << _L_BIT_RES) - z1  + 1);
                z2  <= ((z2  << _L_BIT_RES) - z2  + 3);
                z3  <= ((z3  << _L_BIT_RES) - z3  + 5);
                z4  <= ((z4  << _L_BIT_RES) - z4  + 7);
                z5  <= ((z5  << _L_BIT_RES) - z5  + 9);
                z6  <= ((z6  << _L_BIT_RES) - z6  + 11);
                z7  <= ((z7  << _L_BIT_RES) - z7  + 13);
                z8  <= ((z8  << _L_BIT_RES) - z8  + 15);
                z9  <= ((z9  << _L_BIT_RES) - z9  + 17);
                z10 <= ((z10 << _L_BIT_RES) - z10 + 19);
                z11 <= ((z11 << _L_BIT_RES) - z11 + 21);
                z12 <= ((z12 << _L_BIT_RES) - z12 + 23);

                RND1  <= z1[35:24];
                RND2  <= z2[35:24];
                RND3  <= z3[35:24];
                RND4  <= z4[35:24];
                RND5  <= z5[35:24];
                RND6  <= z6[35:24];
                RND7  <= z7[35:24];
                RND8  <= z8[35:24];
                RND9  <= z9[35:24];
                RND10 <= z10[35:24];
                RND11 <= z11[35:24];
                RND12 <= z12[35:24];

            end else if (samples_counter == num_of_samples) begin // if this sample is the next one after the last one in the package
                SIGN_STOP_CALC  <= 0; // clear flag for output register 
                SUM_STOP        <= 0;
                samples_counter <= 0; // reset the counter
                busy            <= 0; // clear flag busy of phase accum
                num_of_samples  <= 0; 

                z1              <= 0;
                z2              <= 0;
                z3              <= 0;
                z4              <= 0;
                z5              <= 0;
                z6              <= 0;
                z7              <= 0;
                z8              <= 0;
                z9              <= 0;
                z10             <= 0;
                z11             <= 0;
                z12             <= 0;

                RND1            <= 12'bz;
                RND2            <= 12'bz;
                RND3            <= 12'bz;
                RND4            <= 12'bz;
                RND5            <= 12'bz;
                RND6            <= 12'bz;
                RND7            <= 12'bz;
                RND8            <= 12'bz;
                RND9            <= 12'bz;
                RND10           <= 12'bz;
                RND11           <= 12'bz;
                RND12           <= 12'bz;
            end             
        end
    end

endmodule