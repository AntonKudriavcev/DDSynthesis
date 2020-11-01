//vsim -gui -L altera_mf_ver work.PSK_tb

`timescale 1ns/1ps

module PSK_tb;

//-----------------------------------------------------------------------------

    reg           clk;
    reg           reset;
    // reg    [33:0] f_sampling; // from min to 17GHz
    reg    [31:0] f_carrier;  // from 1.2 to 4GHz  (4.2GHz)
    reg    [ 9:0] t_impulse;  // from 60 to 650us  (1023us)
    reg    [12:0] t_period;   // from 360 to 6500us(8191us)
    reg    [ 4:0] num_of_imp; // from 0 to 31
    reg    [21:0] deviation;  // from 2 to 4MHz    (4.19MHz)
    reg           sign_start_gen;

    wire   [11:0] ROM_address;
    wire   [11:0] ROM_out;

    wire          sign_start_calc; // wire from phase accum to output reg 
    wire          sign_stop_calc;  // wire from phase accum to output reg 

    wire          reg_ready;
    wire   [11:0] reg_out;

    wire   [31:0] num_of_samples;

    integer file_data;

//-----------------------------------------------------------------------------
    
    PSK_phase_accum PSK_phase_accum(.CLK               (clk),
                                    .RESET             (reset),
                                    .F_CARRIER         (f_carrier),
                                    .T_IMPULSE         (t_impulse),
                                    .T_PERIOD          (t_period),
                                    .NUM_OF_IMP        (num_of_imp),
                                    .SIGN_START_GEN    (sign_start_gen),
                                    .SIGN_START_CALC   (sign_start_calc),
                                    .SIGN_STOP_CALC    (sign_stop_calc),
                                    .OUT_REG_READY     (reg_ready),
                                    .ROM_ADDRESS       (ROM_address));

    ROM             ROM            (.address           (ROM_address),
                                    .clock             (clk),
                                    .q                 (ROM_out));

    output_reg      output_reg      (.CLK              (clk),
                                     .RESET            (reset),
                                     .INPUT            (ROM_out),
                                     .SIGN_START_CALC  (sign_start_calc),
                                     .SIGN_STOP_CALC   (sign_stop_calc),
                                     .READY            (reg_ready),
                                     .OUTPUT           (reg_out));

//-----------------------------------------------------------------------------
    
    initial begin
        clk     = 0;
        reset   = 0;

        f_carrier  = (13_00000000 + 0); // Hz
        t_impulse  = 10; // us
        t_period   = 2;  // us 
        num_of_imp = 1;  // 

        sign_start_gen = 1;

        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/PSK/data/output_signal.txt", "w");
        $fclose(file_data) ;
        
    end

//-----------------------------------------------------------------------------

    always #1 clk = ~clk;
    always #2 begin
        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/PSK/data/output_signal.txt", "a");
            $fwrite(file_data, reg_out, "\n");
            $fclose(file_data) ;
    end
    always #10 sign_start_gen = ~sign_start_gen; 
  
endmodule
 