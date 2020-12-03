//vsim -gui -L 220model_ver -L 220model -L altera_ver -L altera -L altera_mf_ver -L altera_mf -L altera_lnsim_ver -L altera_lnsim work.digital_synthesizer_tb

`timescale 1ns/1ps

module digital_synthesizer_tb;

//-----------------------------------------------------------------------------

    reg           clk;
    reg           reset;

    reg           sign_start_gen;
    reg    [ 1:0] signal_type;
    reg    [31:0] f_carrier;   // from 1.2 to 4GHz  (4.2GHz)
    reg    [ 9:0] t_impulse;   // from 60 to 650us  (1023us)

    reg           vobulation;
    reg    [12:0] t_period_1;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_2;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_3;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_4;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_5;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_6;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_7;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_8;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_9;  // from 360 to 6500us(8191us)
    reg    [12:0] t_period_10; // from 360 to 6500us(8191us)
    reg    [ 4:0] num_of_imp;  // from 0 to 31
    reg    [21:0] deviation;   // from 2 to 4MHz    (4.19MHz)
    
    wire   [11:0] syn_out;

    integer file_data;

//--user parameters------------------------------------------------------------

    parameter _LFM_SIGNAL_TYPE   =  2'd 1;
    parameter _PSK_SIGNAL_TYPE   =  2'd 2;
    parameter _NOISE_SIGNAL_TYPE =  2'd 3; 

//-----------------------------------------------------------------------------
    
    digital_synthesizer_v1 digital_synthesizer_v1(.CLK               (clk),
                                                  .RESET             (reset),
                                                  .SIGN_START_GEN    (sign_start_gen),
                                                  .SIGNAL_TYPE       (signal_type),
                                                  .F_CARRIER         (f_carrier),
                                                  .T_IMPULSE         (t_impulse),
                                                  // .T_PERIOD          (t_period),
                                                  .VOBULATION        (vobulation),
                                                  .T_PERIOD_1        (t_period_1),
                                                  .T_PERIOD_2        (t_period_2),
                                                  .T_PERIOD_3        (t_period_3),
                                                  .T_PERIOD_4        (t_period_4),
                                                  .T_PERIOD_5        (t_period_5),
                                                  .T_PERIOD_6        (t_period_6),
                                                  .T_PERIOD_7        (t_period_7),
                                                  .T_PERIOD_8        (t_period_8),
                                                  .T_PERIOD_9        (t_period_9),
                                                  .T_PERIOD_10       (t_period_10),
                                                  .NUM_OF_IMP        (num_of_imp),
                                                  .DEVIATION         (deviation),

                                                  .OUTPUT            (syn_out));

//-----------------------------------------------------------------------------
    
    initial begin
        clk     = 0;
        reset   = 0;

        f_carrier   = (13_00000000 + 0); // Hz
        t_impulse   = 10; // us
        // t_period  = 15;  // us 
        num_of_imp  = 1;  // 
        vobulation  = 0;
        t_period_1  = 2;  // us 
        t_period_2  = 2;  // us 
        t_period_3  = 2;  // us 
        t_period_4  = 2;  // us 
        t_period_5  = 2;  // us 
        t_period_6  = 2;  // us 
        t_period_7  = 2;  // us 
        t_period_8  = 2;  // us 
        t_period_9  = 2;  // us 
        t_period_10 = 2;  // us 
        
        deviation   = 3e6; // Hz

        sign_start_gen = 1;
        signal_type    = _NOISE_SIGNAL_TYPE; // 

        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/digital_synthesizer_v1.2.1/data/output_signal.txt", "w");
        $fclose(file_data) ;
        
    end

//-----------------------------------------------------------------------------

    always #1 clk = ~clk;
    always #2 begin
        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/digital_synthesizer_v1.2.1/data/output_signal.txt", "a");
            $fwrite(file_data, syn_out, "\n");
            $fclose(file_data) ;
    end
    always #10 sign_start_gen = ~sign_start_gen; 
  
endmodule
 