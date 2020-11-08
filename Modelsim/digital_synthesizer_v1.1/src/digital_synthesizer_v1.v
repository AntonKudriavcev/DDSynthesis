
module digital_synthesizer_v1(

    input wire        CLK,
    input wire        RESET,

    input wire        SIGN_START_GEN,
    input wire [ 1:0] SIGNAL_TYPE,
    //-signals parameters--------
    input wire [31:0] F_CARRIER,
    input wire [ 9:0] T_IMPULSE,
    input wire [12:0] T_PERIOD,
    input wire [ 4:0] NUM_OF_IMP,
    input wire [21:0] DEVIATION,
    //---------------------------

    output wire [11:0] OUTPUT);

//-----------------------------------------------------------------------------

    wire        sign_LFM_start_calc;   // wire from LFM phase accum to output reg 
    wire        sign_PSK_start_calc;   // wire from PSK phase accum to output reg
    wire        sign_NOISE_start_calc; // wire from NOISE module to output reg

    wire        sign_LFM_stop_calc;   // wire from LFM phase accum to output reg 
    wire        sign_PSK_stop_calc;   // wire from PSK phase accum to output reg
    wire        sign_NOISE_stop_calc; // wire from NOISE module to output reg

    wire [11:0] LFM_out;
    wire [11:0] PSK_out;
    wire [11:0] NOISE_out;

    wire [11:0] signal_mux_out;

    wire [11:0] ROM_out;
    wire [11:0] NOISE_buf_out;

    wire        reg_ready;

//-----------------------------------------------------------------------------

    LFM_phase_accum LFM_phase_accum(.CLK                   (CLK),
                                    .RESET                 (RESET),
                                    .SIGNAL_TYPE           (SIGNAL_TYPE),
                                    .F_CARRIER             (F_CARRIER),
                                    .T_IMPULSE             (T_IMPULSE),
                                    .T_PERIOD              (T_PERIOD),
                                    .NUM_OF_IMP            (NUM_OF_IMP),
                                    .DEVIATION             (DEVIATION),
                                    .SIGN_START_GEN        (SIGN_START_GEN),
                                    .OUT_REG_READY         (reg_ready),

                                    .ROM_ADDRESS           (LFM_out),
                                    .SIGN_START_CALC       (sign_LFM_start_calc),
                                    .SIGN_STOP_CALC        (sign_LFM_stop_calc));

    PSK_phase_accum PSK_phase_accum(.CLK                   (CLK),
                                    .RESET                 (RESET),

                                    .SIGNAL_TYPE           (SIGNAL_TYPE),
                                    .F_CARRIER             (F_CARRIER),
                                    .T_IMPULSE             (T_IMPULSE),
                                    .T_PERIOD              (T_PERIOD),
                                    .NUM_OF_IMP            (NUM_OF_IMP),
                                    .SIGN_START_GEN        (SIGN_START_GEN),
                                    .OUT_REG_READY         (reg_ready),

                                    .ROM_ADDRESS           (PSK_out),
                                    .SIGN_START_CALC       (sign_PSK_start_calc),
                                    .SIGN_STOP_CALC        (sign_PSK_stop_calc));

    noise_generator noise_generator(.CLK                   (CLK),
                                    .RESET                 (RESET),
                                    .SIGNAL_TYPE           (SIGNAL_TYPE),
                                    .T_IMPULSE             (T_IMPULSE),
                                    .SIGN_START_GEN        (SIGN_START_GEN),
                                    .OUT_REG_READY         (reg_ready),

                                    .SIGN_START_CALC       (sign_NOISE_start_calc),
                                    .SIGN_STOP_CALC        (sign_NOISE_stop_calc),
                                    .NOISE_OUT             (NOISE_out));

    signal_mux      signal_mux     (.CLK                   (CLK),
                                    .RESET                 (RESET),
                                    .SIGN_LFM_START_CALC   (sign_LFM_start_calc),
                                    .SIGN_PSK_START_CALC   (sign_PSK_start_calc),
                                    .SIGN_LFM_STOP_CALC    (sign_LFM_stop_calc),
                                    .SIGN_PSK_STOP_CALC    (sign_PSK_stop_calc),
                                    .DATA_FROM_LFM         (LFM_out),
                                    .DATA_FROM_PSK         (PSK_out),

                                    .MUX_OUT               (signal_mux_out));


    buffer          buffer         (.CLK                   (CLK),
                                    .RESET                 (RESET),
                                    .DATA_FROM_NOISE       (NOISE_out),

                                    .BUF_OUT               (NOISE_buf_out));

    ROM             ROM            (.clock                 (CLK),
                                    .address               (signal_mux_out),
                                    .q                     (ROM_out));

    output_reg      output_reg     (.CLK                   (CLK),
                                    .RESET                 (RESET),
                                    .DATA_FROM_ROM         (ROM_out),
                                    .DATA_FROM_BUF         (NOISE_buf_out),
                                    .SIGN_LFM_START_CALC   (sign_LFM_start_calc),
                                    .SIGN_PSK_START_CALC   (sign_PSK_start_calc),
                                    .SIGN_NOISE_START_CALC (sign_NOISE_start_calc),
                                    .SIGN_LFM_STOP_CALC    (sign_LFM_stop_calc),
                                    .SIGN_PSK_STOP_CALC    (sign_PSK_stop_calc),
                                    .SIGN_NOISE_STOP_CALC  (sign_NOISE_stop_calc),

                                    .READY                 (reg_ready),
                                    .REG_OUT               (OUTPUT));
    

// always @(posedge CLK or posedge RESET) begin
//     if (RESET) begin
//         OUTPUT = 12'bz;
//     end else begin
//         OUTPUT = reg_out;
//     end
// end



endmodule