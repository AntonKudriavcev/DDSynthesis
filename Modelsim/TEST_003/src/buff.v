module buff(
	input wire [3:0] DATA,
	output reg [3:0] OUT);

	reg [3:0] buff = 0;

	initial begin
		OUT = 0;
	end

	always @(DATA) begin

		// buff = DATA;
		OUT  = DATA;
		
	end

endmodule 