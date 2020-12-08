module noise_sum(

    input wire CLK,
    input wire RESET,

    input wire SUM_START,
    input wire SUM_STOP,

    input wire [11:0] RND1,
    input wire [11:0] RND2,
    input wire [11:0] RND3,
    input wire [11:0] RND4,
    input wire [11:0] RND5,
    input wire [11:0] RND6,
    input wire [11:0] RND7,
    input wire [11:0] RND8,
    input wire [11:0] RND9,
    input wire [11:0] RND10,
    input wire [11:0] RND11,
    input wire [11:0] RND12,

    output reg        FIFO_WR,
    output reg        FIFO_SCLR,
    output reg [11:0] NOISE_OUT);

//--user parameters------------------------------------------------------------

    parameter _PRIMARY_RND_BIT_DEPH =  5'd 12;
    parameter _SIGMA_REQ            =  9'd 682;    // required standart deviation
    parameter _M_CALC               = 11'd 2044;

//--user variables-------------------------------------------------------------

    reg        busy      = 0;
    reg [23:0] sum       = 0;
    reg [36:0] sum_shift = 0;
    reg [36:0] rnd       = 0;

//-----------------------------------------------------------------------------

    initial begin
        FIFO_WR   = 0;
        FIFO_SCLR = 0;
        NOISE_OUT = 12'bz;
    end
//-----------------------------------------------------------------------------

    always @(posedge CLK) begin
        if (RESET) begin

            FIFO_WR   = 0;
            FIFO_SCLR = 1;
            NOISE_OUT = 12'bz;

            busy = 0;
            rnd  = 0;
            
        end else begin

            if (SUM_START && !busy) begin
                busy      = 1;
                FIFO_SCLR = 0;
            end else if (busy) begin

                if (!FIFO_WR) begin
                    FIFO_WR   = 1;
                end

                if (SUM_STOP) begin
                    busy      = 0;
                    FIFO_WR   = 0;
                end
                sum       = (RND1 + RND2 + RND3 + RND4 + RND5 + RND6 + RND7 + RND8 + RND9 + RND10 + RND11 + RND12);
                sum_shift = ((sum << 9) + (sum << 7) + (sum << 5) + (sum << 3) + (sum << 1));

                rnd       = (sum_shift >> _PRIMARY_RND_BIT_DEPH) - _M_CALC;


                // rnd = ((((RND1 + RND2 + RND3 + RND4 + RND5 + RND6 + RND7 + RND8 + RND9 + RND10 + RND11 + RND12) *
                //               _SIGMA_REQ) >> _PRIMARY_RND_BIT_DEPH) - _M_CALC);

                NOISE_OUT = rnd[11:0];
            end
        end
    end





endmodule