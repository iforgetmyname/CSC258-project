module hangman(
	input CLOCK_50,
	input PS2_DAT, PS2_CLK,
	input [0:0] KEY,
	input [3:0] SW,

	output [9:0] LEDR,
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4);
	
	wire clk, reset;
	assign clk = CLOCK_50;
	assign reset = ~KEY[0];

	wire valid, makeBreak;
	wire [7:0] outCode;
	wire [4:0] outLetter;
	wire [29:0] word;
	wire [25:0] mask;
	wire load;
	reg [3:0] wrong_time;
	assign load = (makeBreak == 1'b1);
	assign LEDR[7] = load;
	
	keyboard_press_driver k0(
		.CLOCK_50(CLOCK_50),
		.valid(valid),
		.makeBreak(makeBreak),
		.outCode(outCode),
		
		.PS2_DAT(PS2_DAT),
		.PS2_CLK(PS2_CLK),
		
		.reset(reset)
		);
	
	assign LEDR[9] = valid;
	assign LEDR[8] = makeBreak;

	decoder d0(
		.inCode(outCode),
		.outLetter(outLetter)
		);
	
	wire win_game, lost_game;

	level_select l0(
		.clk(clk),
		.reset(reset),
		
		.start_game(((outLetter == 5'd26) && load)),
		.win_game(win_game),
		.lost_game((wrong_time == 1'b0)),
		.select(SW[3:0]),
		
		.word(word),
		.mask(mask),
		
		.current_state(LEDR[3:0])
		);
	
	wire [25:0] state;
	wire wrong;
	game_state g0(
		.clk(clk),
		.reset(reset),
		.load(load),
		.load_x(outLetter),
		
		.mask(mask),
		
		.win(win_game),
		.wrong(wrong),
		
		.current_state(state)
		);
	
	always @(negedge wrong, posedge reset) begin
		if (reset) 
			wrong_time <= 4'd4;
		else if(load)
			wrong_time <= wrong_time - 1;
	end
	
	hex_decoder h0(
		.hex_digit(outLetter[3:0]),
		.segments(HEX0[6:0])
		);
	
	hex_decoder h1(
		.hex_digit({3'b000, outLetter[4:4]}),
		.segments(HEX1[6:0])
		);
		
	hex_decoder h2(
		.hex_digit(state[3:0]),
		.segments(HEX2[6:0])
		);
	
	hex_decoder h3(
		.hex_digit(state[7:4]),
		.segments(HEX3[6:0])
		);
	
	hex_decoder h4(
		.hex_digit(wrong_time),
		.segments(HEX4[6:0])
		);
endmodule
		
	