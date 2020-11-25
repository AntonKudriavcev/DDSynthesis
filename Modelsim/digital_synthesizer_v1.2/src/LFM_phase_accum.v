
module LFM_phase_accum(

    input wire        CLK,
    input wire        RESET,

    input wire [ 1:0] SIGNAL_TYPE,
    input wire [31:0] F_CARRIER,
    input wire [ 9:0] T_IMPULSE,
    input wire [12:0] T_PERIOD,
    input wire [ 4:0] NUM_OF_IMP,
    input wire [21:0] DEVIATION,
    input wire        SIGN_START_GEN,
    input wire        OUT_REG_READY,

    input wire [39:0] QUONTIENT_STEP_MAX,
    input wire [24:0] REMAIN_STEP_MAX,
    input wire [22:0] QUONTIENT_DLT_STEP,
    input wire [47:0] REMAIN_DLT_STEP,

    output reg [39:0] NUMER_STEP_MAX,
    output reg [24:0] DENOM_STEP_MAX,
    output reg [22:0] NUMER_DLT_STEP,
    output reg [47:0] DENOM_DLT_STEP,
    
    output reg [11:0] ROM_ADDRESS,
    output reg        SIGN_START_CALC, // inform output reg which calculation of phase started
    output reg        SIGN_STOP_CALC); // inform output reg which calculation of phase stopped

//--user parameters------------------------------------------------------------

    // sampling frequency = 13000000000 Hz = 25390625 << 9
    parameter _SAMP_FREQ_VALUE1 = 25'd 25390625; 
    parameter _SAMP_FREQ_SHIFT1 =  4'd 9; 

    // sampling frequency = 130000 MHz = 1625 << 3 MHz
    parameter _SAMP_FREQ_VALUE2 = 11'd 1625; 
    parameter _SAMP_FREQ_SHIFT2 =  2'd 3;

    parameter _ARRAY_BIT_RESOL =  4'd 12; // bit resolution of array with sin samples (ROM-memory)
    parameter _LFM_SIGNAL_TYPE =  2'd 1;
    parameter _DIV_DELAY       =  5'd 23; 

//--user variables-------------------------------------------------------------

    reg [11:0] address        = 0;
    reg        busy           = 0; // flag which indicates that LFM_phase_accum 
                                   // received SIGN_START_GEN and output register 
                                   // is ready for work (LFM_phase_accum starts 
                                   // calculate phase of signal from ROM)

    reg [31:0] num_of_samples  = 0; // from 0 to 2627950000 - 1
    reg [31:0] samples_counter = 0; // from 0 to 2627950000 - 1
    reg [31:0] imp_border_cnt  = 0; // counter which contains border of current impulse
    reg [31:0] per_border_cnt  = 0; // counter which contains border of current period

    reg [21:0] half_imp_border_cnt = 0; // counter for monitoring borders half of impulse (for bidirectional LFM)

    reg [23:0] imp_samples     = 0; // from 0 to 16777215
    reg [26:0] period_samples  = 0; // from 0 to 134217727

    reg [39:0] step_max_div    = 0; // integer part of the division for max step value
    reg [24:0] step_max_mod    = 0; // the fractional part of the division for max step value
    reg [22:0] dlt_step_div    = 0; // integer part of the division for delta step value
    reg [47:0] dlt_step_mod    = 0; // the fractional part of the division for delta step value

    reg [26:0] step_max_cnt    = 0; // counter for the fractional part of the division for max step value
    reg [49:0] dlt_step_cnt    = 0; // counter for the fractional part of the division for delta step value

    reg [49:0] buffer          = 0; // buffer for summation the fractional part of the division for max step value

    reg [47:0] dlt_step_denom  = 0; // denominator of the delta step divider

    reg [ 4:0] div_delay       = 0; // delay for the delta step divider (div2) and max step divider (div1)
 
//-----------------------------------------------------------------------------
    initial begin
        ROM_ADDRESS     = 12'bz;
        SIGN_START_CALC = 0;
        SIGN_STOP_CALC  = 0;
    end
//-----------------------------------------------------------------------------

    always @(posedge CLK) begin

        if (RESET) begin
            ROM_ADDRESS     <= 12'b z; // set z-state in out of phase accum
            SIGN_STOP_CALC  <= 0; // clear flag for output register 
            samples_counter <= 0; // reset the counter
            num_of_samples  <= 0;
            imp_samples     <= 0;
            period_samples  <= 0;
            busy            <= 0; // clear flag busy of phase accum 
            address         <= 0;
            step_max_div    <= 0;
            step_max_mod    <= 0;
            dlt_step_div    <= 0;
            dlt_step_mod    <= 0;
            div_delay       <= 0;
            imp_border_cnt  <= 0;
            per_border_cnt  <= 0;

            step_max_cnt    <= 0;
            dlt_step_cnt    <= 0;

            dlt_step_denom  <= 0;

            half_imp_border_cnt <= 0;
            
        end else if (SIGN_START_GEN && !busy && OUT_REG_READY && (SIGNAL_TYPE == _LFM_SIGNAL_TYPE)) begin

            imp_samples    = (T_IMPULSE * _SAMP_FREQ_VALUE2) << _SAMP_FREQ_SHIFT2; // calculate num of samples per inpulse 

            period_samples = (T_PERIOD  * _SAMP_FREQ_VALUE2) << _SAMP_FREQ_SHIFT2; // calculate num of samples per period  

            num_of_samples = ((((NUM_OF_IMP - 1) * T_PERIOD) + T_IMPULSE) * _SAMP_FREQ_VALUE2) << _SAMP_FREQ_SHIFT2; // calculate num of samples for all packet
                                                        
            imp_border_cnt = imp_samples;    // border of first impulse
            per_border_cnt = period_samples; // border of first period

            half_imp_border_cnt = (imp_samples >> 1); // border of first half-impulse

            // make a division (_ARRAY_DIMENTION * F_CARRIER)/_SAMPLING_FREQ) (calculate max step)
            NUMER_STEP_MAX <= ((F_CARRIER + (DEVIATION >> 1)) << (_ARRAY_BIT_RESOL - _SAMP_FREQ_SHIFT1));
            DENOM_STEP_MAX <= _SAMP_FREQ_VALUE1;  // is equal to _SAMPLING_FREQ/(2^9)

            // make a division (_ARRAY_DIMENTION * DEVIATION)/(_SAMPLING_FREQ * T_IMPULSE)) (calculate delta step)
            NUMER_DLT_STEP <= (DEVIATION << (_ARRAY_BIT_RESOL + 1 - _SAMP_FREQ_SHIFT1 - _SAMP_FREQ_SHIFT2));
            dlt_step_denom = (T_IMPULSE * _SAMP_FREQ_VALUE1 * _SAMP_FREQ_VALUE2); // save value for next steps
            DENOM_DLT_STEP = dlt_step_denom;

            busy            <= 1; // set flag for next step

            SIGN_START_CALC <= 1;

        end else if (busy) begin

            if (div_delay < _DIV_DELAY) begin
                div_delay <= div_delay + 1; // waiting while divisions is occured

            end else if (div_delay == _DIV_DELAY) begin
                // SIGN_START_CALC = 1;

                div_delay    <= div_delay + 1;      // for next step
                step_max_div <= QUONTIENT_STEP_MAX; // save value
                step_max_mod <= REMAIN_STEP_MAX;    // save value
                dlt_step_div <= QUONTIENT_DLT_STEP; // save value
                dlt_step_mod <= REMAIN_DLT_STEP;    // save value          

            end else begin

                if (SIGN_START_CALC) begin
                    SIGN_START_CALC = 0; // clear sign 
                end

                if (samples_counter < num_of_samples) begin

                    ROM_ADDRESS     = address;
                    samples_counter = samples_counter + 1; // calculate number of the next sample

                    if (samples_counter == (num_of_samples)) begin // if the current sample is the last one in the package
                        SIGN_STOP_CALC = 1; // set flag for output register 
                    end else begin // if the current sample is not the last one in the package calculate new ROM address

                        if (samples_counter < imp_border_cnt) begin // if the current sample is not the last one in the impulse 
                                                                    // generate impulse samples

                            step_max_cnt = step_max_cnt + step_max_mod; // accumulate remain of max step

                            if (step_max_cnt >= _SAMP_FREQ_VALUE1) begin 
                                step_max_cnt = step_max_cnt - _SAMP_FREQ_VALUE1;
                                address      = address + 1;
                            end

                            // algorithm for first half of impulse
                            if (samples_counter < half_imp_border_cnt) begin

                                buffer       = buffer + dlt_step_mod; // accumulate remain of delta step
                                dlt_step_cnt = dlt_step_cnt + buffer; 
                                
                                // its a kind of magic
                                if (dlt_step_cnt >= (dlt_step_denom << 1))begin
                                    address      = address + step_max_div[11:0] - 2;
                                    dlt_step_cnt = dlt_step_cnt - (dlt_step_denom << 1);
                                end else if (dlt_step_cnt >= dlt_step_denom) begin
                                    address      = address + step_max_div[11:0] - 1;
                                    dlt_step_cnt = dlt_step_cnt - dlt_step_denom;
                                end else begin
                                    address      = address + step_max_div[11:0];
                                end

                            end else begin // algorithm for first half of impulse

                                buffer       = buffer - dlt_step_mod;
                                dlt_step_cnt = (dlt_step_cnt + (dlt_step_denom << 1)) - (buffer);

                                // its a kind of magic
                                if (dlt_step_cnt >= (dlt_step_denom << 1))begin
                                    address      = address + step_max_div[11:0];
                                    dlt_step_cnt = dlt_step_cnt - (dlt_step_denom << 1);
                                end else if (dlt_step_cnt >= dlt_step_denom) begin
                                    address      = address + step_max_div[11:0] - 1;
                                    dlt_step_cnt = dlt_step_cnt - dlt_step_denom;
                                end else begin
                                    address      = address + step_max_div[11:0] - 2;
                                end
                            end

                        end else begin // generate zero samples between impulses 
                            address = 0;
                            if (samples_counter == per_border_cnt) begin

                                step_max_cnt <= 0;
                                dlt_step_cnt <= 0;
                                buffer       <= 0;

                                imp_border_cnt <= imp_border_cnt + period_samples;
                                per_border_cnt <= per_border_cnt + period_samples;

                                half_imp_border_cnt <= half_imp_border_cnt + period_samples;
                            end
                        end 
                    end

                end else if (samples_counter == num_of_samples) begin // if this sample is the next one after the last one in the package
                    ROM_ADDRESS     <= 12'b z; // set z-state in out of phase accum
                    SIGN_STOP_CALC  <= 0; // clear flag for output register 
                    samples_counter <= 0; // reset the counter
                    num_of_samples  <= 0;
                    imp_samples     <= 0;
                    period_samples  <= 0;
                    busy            <= 0; // clear flag busy of phase accum 
                    address         <= 0;
                    step_max_div    <= 0;
                    step_max_mod    <= 0;
                    dlt_step_div    <= 0;
                    dlt_step_mod    <= 0;
                    div_delay       <= 0;
                    imp_border_cnt  <= 0;
                    per_border_cnt  <= 0;

                    step_max_cnt    <= 0;
                    dlt_step_cnt    <= 0;

                    dlt_step_denom  <= 0;

                    half_imp_border_cnt <= 0;
                end 
            end             
        end
    end

endmodule
