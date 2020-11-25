//vsim -gui -L 220model_ver -L 220model -L altera_ver -L altera -L altera_mf_ver -L altera_mf -L altera_lnsim_ver -L altera_lnsim work.digital_synthesizer_tb

`timescale 1ns/1ps

module digital_synthesizer_tb;

//-----------------------------------------------------------------------------

    reg           clk;
    reg           reset;

    reg           sign_start_gen;
    reg    [ 1:0] signal_type;
    reg    [31:0] f_carrier;  // from 1.2 to 4GHz  (4.2GHz)
    reg    [ 9:0] t_impulse;  // from 60 to 650us  (1023us)
    reg    [12:0] t_period;   // from 360 to 6500us(8191us)
    reg    [ 4:0] num_of_imp; // from 0 to 31
    reg    [21:0] deviation;  // from 2 to 4MHz    (4.19MHz)
    
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
                                                  .T_PERIOD          (t_period),
                                                  .NUM_OF_IMP        (num_of_imp),
                                                  .DEVIATION         (deviation),

                                                  .OUTPUT            (syn_out));

//-----------------------------------------------------------------------------
    
    initial begin
        clk     = 0;
        reset   = 0;

        f_carrier  = (13_00000000 + 0); // Hz
        t_impulse  = 10; // us
        t_period   = 15;  // us 
        num_of_imp = 1;  // 
        deviation  = 3e6; // Hz

        sign_start_gen = 1;
        signal_type    = _LFM_SIGNAL_TYPE; // 

        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/digital_synthesizer_v1.2/data/output_signal.txt", "w");
        $fclose(file_data) ;
        
    end

//-----------------------------------------------------------------------------

    always #1 clk = ~clk;
    always #2 begin
        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/digital_synthesizer_v1.2/data/output_signal.txt", "a");
            $fwrite(file_data, syn_out, "\n");
            $fclose(file_data) ;
    end
    always #10 sign_start_gen = ~sign_start_gen; 
  
endmodule
 