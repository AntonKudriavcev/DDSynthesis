//vsim -gui -L altera_mf_ver work.noise_tb

`timescale 1ns/1ps

module noise_tb;

//-----------------------------------------------------------------------------

    reg           clk;
    reg           reset;
    // reg    [33:0] f_sampling; // from min to 17GHz

    reg    [ 9:0] t_impulse;  // from 60 to 650us  (1023us)
    reg           sign_start_gen;

    wire          sign_start_calc; // wire from phase accum to output reg 
    wire          sign_stop_calc;  // wire from phase accum to output reg 
    wire          reg_ready;

    wire   [11:0] buf_out;
    wire   [11:0] noise_out;
    wire   [11:0] reg_out;


    integer file_data;

//-----------------------------------------------------------------------------
    
    noise_generator noise_generator (.CLK              (clk),
                                     .RESET            (reset),
                                     .T_IMPULSE        (t_impulse),
                                     .SIGN_START_GEN   (sign_start_gen),
                                     .OUT_REG_READY    (reg_ready),

                                     .SIGN_START_CALC  (sign_start_calc),
                                     .SIGN_STOP_CALC   (sign_stop_calc),
                                     .NOISE_OUT        (noise_out));

    buffer          buffer          (.CLK              (clk),
                                     .RESET            (reset),
                                     .BUF_IN           (noise_out),

                                     .BUF_OUT          (buf_out));

    output_reg      output_reg      (.CLK              (clk),
                                     .RESET            (reset),
                                     .INPUT            (buf_out),
                                     .SIGN_START_CALC  (sign_start_calc),
                                     .SIGN_STOP_CALC   (sign_stop_calc),

                                     .READY            (reg_ready),
                                     .OUTPUT           (reg_out));

//-----------------------------------------------------------------------------
    
    initial begin
        clk     = 0;
        reset   = 0;

        t_impulse  = 10; // us

        sign_start_gen = 1;

        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/NOISE/data/output_signal.txt", "w");
        $fclose(file_data) ;
        
    end

//-----------------------------------------------------------------------------

    always #1 clk = ~clk;
    always #2 begin
        file_data = $fopen("D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/NOISE/data/output_signal.txt", "a");
            $fwrite(file_data, reg_out, "\n");
            $fclose(file_data) ;
    end
    always #10 sign_start_gen = ~sign_start_gen; 
  
endmodule
 