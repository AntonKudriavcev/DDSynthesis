
module LFM_phase_accum(

    input wire        CLK,
    input wire        RESET,

    input wire [31:0] F_CARRIER,
    input wire [ 9:0] T_IMPULSE,
    input wire [12:0] T_PERIOD,
    input wire [ 4:0] NUM_OF_IMP,
    input wire [21:0] DEVIATION,
    input wire        SIGN_START_GEN,
    input wire        OUT_REG_READY,

    output reg [31:0] NUM_OF_SAMPLES,

    output reg [11:0] ROM_ADDRESS,
    output reg        SIGN_START_CALC, // inform output reg which calculation of phase started
    output reg        SIGN_STOP_CALC); // inform output reg which calculation of phase stopped

//--user parameters------------------------------------------------------------

    parameter _SAMPLING_FREQ   = 34'd 13_000000000; // 13 GHz
    parameter _ARRAY_DIMENTION = 13'd 4096; 
    parameter _MULT_COEF       = 15'd 16384; 

//--user variables-------------------------------------------------------------

    reg [11:0] address   = 0;
    reg        busy      = 0; // flag which indicates that LFM_phase_accum 
                              // received SIGN_START_GEN and output register 
                              // is ready for work (LFM_phase_accum starts 
                              // calculate phase of signal from ROM)

    reg        start_gen = 0; // flag which indicates that LFM_phase_accum
                              // received SIGN_START_GEN and output register
                              // is NOT ready for work yet (waiting for ready 
                              // of output register)

    reg [31:0] f_carrier      = 0; // from 1.2 to 4GHz  (4.2GHz)
    reg [ 9:0] t_impulse      = 0; // from 60 to 650us  (1023us)
    reg [12:0] t_period       = 0; // from 360 to 6500us(8191us)
    reg [ 4:0] num_of_imp     = 0; // from 0 to 31
    reg [21:0] deviation      = 0; // from 2 to 4MHz    (4.19MHz)

    reg [32:0] f_max          = 0;
    reg [31:0] f_min          = 0;

    reg [31:0] num_of_samples  = 0; // from 0 to 2627950000 - 1
    reg [31:0] samples_counter = 0; // from 0 to 2627950000 - 1

    reg [23:0] imp_samples     = 0; // from 0 to 16777215
    reg [26:0] period_samples  = 0; // from 0 to 134217727

    reg [23:0] imp_samples_counter  = 0; // counter of samples inside each inpulse

    reg [ 4:0] num_of_curr_imp = 1; // from 0 to 31

    reg [58:0] step            = 0;
    reg [25:0] accum           = 0;
 
//-----------------------------------------------------------------------------
    initial begin
        ROM_ADDRESS     = 12'bz;
        SIGN_START_CALC = 0;
        SIGN_STOP_CALC  = 0;
        NUM_OF_SAMPLES  = num_of_samples;

    end
//-----------------------------------------------------------------------------

    always @(posedge CLK) begin
        if (RESET) begin
            // reset
            
        end else if (SIGN_START_GEN && !start_gen) begin

            start_gen  <= 1;

            SIGN_START_CALC <= 1; // set flag for output register 

        end else if (start_gen) begin

            if (busy) begin
                if (samples_counter < num_of_samples) begin

                    ROM_ADDRESS     = address;
                    samples_counter = samples_counter + 1; // calculate number of the next sample

                    if (samples_counter == (num_of_samples)) begin // if the current sample is the last one in the package
                        SIGN_STOP_CALC = 1; // set flag for output register 
                    end else begin // if the current sample is not the last one in the package calculate new ROM address

                        if (samples_counter < (imp_samples + (num_of_curr_imp - 1) * period_samples)) begin // if the current sample is not the last one in the impulse 
                                                                                                            // generate impulse samples

                            imp_samples_counter = imp_samples_counter + 1; // calculate number of impulse sample for the next step

                            // step    = ((_ARRAY_DIMENTION * f_carrier * _MULT_COEF)/_SAMPLING_FREQ); // for the constant output freq
                            // if (samples_counter < ((imp_samples/2) + (num_of_curr_imp - 1) * period_samples)) begin // if the current sample is not the last one in the half of impulse
                            //     step = (_MULT_COEF * _ARRAY_DIMENTION * (f_max - ((deviation * (imp_samples_counter))/(imp_samples/2))))/_SAMPLING_FREQ;

                            // end else begin
                            //     step = (_MULT_COEF * _ARRAY_DIMENTION * ((f_min - deviation) + ((deviation * (imp_samples_counter))/(imp_samples/2))))/_SAMPLING_FREQ;
                            // end

                            if (imp_samples_counter < (imp_samples/2)) begin // if the current sample is not the last one in the half of impulse
                                step = (_MULT_COEF * _ARRAY_DIMENTION * (f_max - ((deviation * (imp_samples_counter))/(imp_samples/2))))/_SAMPLING_FREQ;

                            end else begin
                                step = (_MULT_COEF * _ARRAY_DIMENTION * ((f_min - deviation) + ((deviation * (imp_samples_counter))/(imp_samples/2))))/_SAMPLING_FREQ;
                            end

                            accum   = accum + step[25:0];
                            address = accum/_MULT_COEF;

                        end else begin // generate zero samples between impulses 
                            address = 0;
                            if (samples_counter == (num_of_curr_imp * period_samples)) begin
                                accum = 0;
                                num_of_curr_imp = num_of_curr_imp + 1;
                                imp_samples_counter = 0;
                            end
                        end 

                    end

                end else if (samples_counter == num_of_samples) begin // if this sample is the next one after the last one in the package
                    ROM_ADDRESS     <= 12'b z; // set z-state in out of phase accum
                    SIGN_STOP_CALC  <= 0; // clear flag for output register 
                    samples_counter <= 0; // reset the counter
                    imp_samples     <= 0;
                    period_samples  <= 0;
                    num_of_curr_imp <= 1;
                    busy            <= 0; // clear flag busy of phase accum 
                    start_gen       <= 0; // clear flag start generation of phase accum 
                    address         <= 0;
                    step            <= 0;
                    accum           <= 0;

                    imp_samples_counter <= 0;

                end

            end else begin
                if (OUT_REG_READY) begin // if output register is ready
                    f_carrier      = F_CARRIER;  // save parameters
                    t_impulse      = T_IMPULSE;  // save parameters
                    t_period       = T_PERIOD;   // save parameters
                    num_of_imp     = NUM_OF_IMP; // save parameters
                    deviation      = DEVIATION;  // save parameters

                    f_max = f_carrier + deviation/2;
                    f_min = f_carrier - deviation/2;

                    imp_samples    = t_impulse * (_SAMPLING_FREQ/1000000); // calculate num of samples per inpulse 
                    period_samples = t_period  * (_SAMPLING_FREQ/1000000); // calculate num of samples per period  
                    
                    num_of_samples = (((num_of_imp - 1) * t_period) + t_impulse) * (_SAMPLING_FREQ/1000000);
                    NUM_OF_SAMPLES = num_of_samples;


                    SIGN_START_CALC <= 0; // clear flag for output register 
                    busy            <= 1; // set flag for next step
                end
            end            
        end
    end

endmodule