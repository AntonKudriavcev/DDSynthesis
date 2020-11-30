
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

    wire        reg_ready;

    wire [39:0] lfm_numer_step_max;
    wire [24:0] lfm_denom_step_max;
    wire [39:0] lfm_quotient_step_max;
    wire [24:0] lfm_remain_step_max;

    wire [22:0] lfm_numer_dlt_step;
    wire [47:0] lfm_denom_dlt_step;
    wire [22:0] lfm_quotient_dlt_step;
    wire [47:0] lfm_remain_dlt_step;

    wire [39:0] psk_numer_step_max;
    wire [24:0] psk_denom_step_max;
    wire [39:0] psk_quotient_step_max;
    wire [24:0] psk_remain_step_max;

    wire [39:0] psk_numer_smpls_per_disc;
    wire [24:0] psk_denom_smpls_per_disc;
    wire [39:0] psk_quotient_smpls_per_disc;
    wire [24:0] psk_remain_smpls_per_disc;

    wire [11:0] rnd1;
    wire [11:0] rnd2;
    wire [11:0] rnd3;
    wire [11:0] rnd4;
    wire [11:0] rnd5;
    wire [11:0] rnd6;
    wire [11:0] rnd7;
    wire [11:0] rnd8;
    wire [11:0] rnd9;
    wire [11:0] rnd10;
    wire [11:0] rnd11;
    wire [11:0] rnd12;

    wire        noise_sum_start;
    wire        noise_sum_stop;

    wire [11:0] fifo_data;
    wire        fifo_sclr;
    wire        fifo_rdreq;
    wire        fifo_wrreq;
    wire [11:0] fifo_q;

//-----------------------------------------------------------------------------

    LFM_phase_accum LFM_phase_accum(.CLK                        (CLK),
                                    .RESET                      (RESET),
                                    .SIGNAL_TYPE                (SIGNAL_TYPE),
                                    .F_CARRIER                  (F_CARRIER),
                                    .T_IMPULSE                  (T_IMPULSE),
                                    .T_PERIOD                   (T_PERIOD),
                                    .NUM_OF_IMP                 (NUM_OF_IMP),
                                    .DEVIATION                  (DEVIATION),
                                    .SIGN_START_GEN             (SIGN_START_GEN),
                                    .OUT_REG_READY              (reg_ready),
                                    .QUONTIENT_STEP_MAX         (lfm_quotient_step_max),
                                    .REMAIN_STEP_MAX            (lfm_remain_step_max),
                                    .QUONTIENT_DLT_STEP         (lfm_quotient_dlt_step),
                                    .REMAIN_DLT_STEP            (lfm_remain_dlt_step),

                                    .NUMER_STEP_MAX             (lfm_numer_step_max),
                                    .DENOM_STEP_MAX             (lfm_denom_step_max),
                                    .NUMER_DLT_STEP             (lfm_numer_dlt_step),
                                    .DENOM_DLT_STEP             (lfm_denom_dlt_step),
                                    .ROM_ADDRESS                (LFM_out),
                                    .SIGN_START_CALC            (sign_LFM_start_calc),
                                    .SIGN_STOP_CALC             (sign_LFM_stop_calc));

    div1            div1_LFM       (.clock                      (CLK),
                                    .denom                      (lfm_denom_step_max),
                                    .numer                      (lfm_numer_step_max),

                                    .quotient                   (lfm_quotient_step_max),
                                    .remain                     (lfm_remain_step_max));

    div2            div2_LFM       (.clock                      (CLK),
                                    .denom                      (lfm_denom_dlt_step),
                                    .numer                      (lfm_numer_dlt_step),
 
                                    .quotient                   (lfm_quotient_dlt_step),
                                    .remain                     (lfm_remain_dlt_step));

    PSK_phase_accum PSK_phase_accum(.CLK                        (CLK),
                                    .RESET                      (RESET),

                                    .SIGNAL_TYPE                (SIGNAL_TYPE),
                                    .F_CARRIER                  (F_CARRIER),
                                    .T_IMPULSE                  (T_IMPULSE),
                                    .T_PERIOD                   (T_PERIOD),
                                    .NUM_OF_IMP                 (NUM_OF_IMP),
                                    .SIGN_START_GEN             (SIGN_START_GEN),
                                    .OUT_REG_READY              (reg_ready),
                                    .QUONTIENT_STEP_MAX         (psk_quotient_step_max),
                                    .REMAIN_STEP_MAX            (psk_remain_step_max),
                                    .QUONTIENT_SMPLS_PER_DISC   (psk_quotient_smpls_per_disc),
                                    .REMAIN_SMPLS_PER_DISC      (psk_remain_smpls_per_disc),

                                    .NUMER_SMPLS_PER_DISC       (psk_numer_smpls_per_disc),
                                    .DENOM_SMPLS_PER_DISC       (psk_denom_smpls_per_disc),
                                    .NUMER_STEP_MAX             (psk_numer_step_max),
                                    .DENOM_STEP_MAX             (psk_denom_step_max),
                                    .ROM_ADDRESS                (PSK_out),
                                    .SIGN_START_CALC            (sign_PSK_start_calc),
                                    .SIGN_STOP_CALC             (sign_PSK_stop_calc));

    div1            div1_PSK       (.clock                      (CLK),
                                    .denom                      (psk_denom_step_max),
                                    .numer                      (psk_numer_step_max),

                                    .quotient                   (psk_quotient_step_max),
                                    .remain                     (psk_remain_step_max));
 
    div1            div2_PSK       (.clock                      (CLK),
                                    .denom                      (psk_denom_smpls_per_disc),
                                    .numer                      (psk_numer_smpls_per_disc),

                                    .quotient                   (psk_quotient_smpls_per_disc),
                                    .remain                     (psk_remain_smpls_per_disc));

    signal_mux      signal_mux     (.CLK                        (CLK),
                                    .RESET                      (RESET),
                                    .SIGN_LFM_START_CALC        (sign_LFM_start_calc),
                                    .SIGN_PSK_START_CALC        (sign_PSK_start_calc),
                                    .SIGN_LFM_STOP_CALC         (sign_LFM_stop_calc),
                                    .SIGN_PSK_STOP_CALC         (sign_PSK_stop_calc),
                                    .DATA_FROM_LFM              (LFM_out),
                                    .DATA_FROM_PSK              (PSK_out),

                                    .MUX_OUT                    (signal_mux_out));

    ROM             ROM            (.clock                      (CLK),
                                    .address                    (signal_mux_out),
                                    .q                          (ROM_out));

    noise_generator noise_generator(.CLK                        (CLK),
                                    .RESET                      (RESET),
                                    .SIGNAL_TYPE                (SIGNAL_TYPE),
                                    .T_IMPULSE                  (T_IMPULSE),
                                    .SIGN_START_GEN             (SIGN_START_GEN),
                                    .OUT_REG_READY              (reg_ready),

                                    .SIGN_START_CALC            (sign_NOISE_start_calc),
                                    .SIGN_STOP_CALC             (sign_NOISE_stop_calc),
                                    .SUM_START                  (noise_sum_start),
                                    .SUM_STOP                   (noise_sum_stop),
                                    .RND1                       (rnd1),
                                    .RND2                       (rnd2),
                                    .RND3                       (rnd3),
                                    .RND4                       (rnd4),
                                    .RND5                       (rnd5),
                                    .RND6                       (rnd6),
                                    .RND7                       (rnd7),
                                    .RND8                       (rnd8),
                                    .RND9                       (rnd9),
                                    .RND10                      (rnd10),
                                    .RND11                      (rnd11),
                                    .RND12                      (rnd12));

    noise_sum       noise_sum      (.CLK                        (CLK),
                                    .RESET                      (RESET),
                                    .SUM_START                  (noise_sum_start),
                                    .SUM_STOP                   (noise_sum_stop),
                                    .RND1                       (rnd1),
                                    .RND2                       (rnd2),
                                    .RND3                       (rnd3),
                                    .RND4                       (rnd4),
                                    .RND5                       (rnd5),
                                    .RND6                       (rnd6),
                                    .RND7                       (rnd7),
                                    .RND8                       (rnd8),
                                    .RND9                       (rnd9),
                                    .RND10                      (rnd10),
                                    .RND11                      (rnd11),
                                    .RND12                      (rnd12),

                                    .FIFO_WR                    (fifo_wrreq),
                                    .FIFO_SCLR                  (fifo_sclr),
                                    .NOISE_OUT                  (fifo_data));


    fifo            fifo           (.clock                      (CLK),
                                    .data                       (fifo_data),
                                    .rdreq                      (fifo_rdreq),
                                    .sclr                       (fifo_sclr),
                                    .wrreq                      (fifo_wrreq),

                                    .q                          (fifo_q));

    output_reg      output_reg     (.CLK                        (CLK),
                                    .RESET                      (RESET),
                                    .DATA_FROM_ROM              (ROM_out),
                                    .DATA_FROM_FIFO             (fifo_q),
                                    .SIGN_LFM_START_CALC        (sign_LFM_start_calc),
                                    .SIGN_PSK_START_CALC        (sign_PSK_start_calc),
                                    .SIGN_NOISE_START_CALC      (sign_NOISE_start_calc),
                                    .SIGN_LFM_STOP_CALC         (sign_LFM_stop_calc),
                                    .SIGN_PSK_STOP_CALC         (sign_PSK_stop_calc),
                                    .SIGN_NOISE_STOP_CALC       (sign_NOISE_stop_calc),

                                    .READY                      (reg_ready),
                                    .FIFO_REQ                   (fifo_rdreq),
                                    .REG_OUT                    (OUTPUT));
    

// always @(posedge CLK or posedge RESET) begin
//     if (RESET) begin
//         OUTPUT = 12'bz;
//     end else begin
//         OUTPUT = reg_out;
//     end
// end



endmodule