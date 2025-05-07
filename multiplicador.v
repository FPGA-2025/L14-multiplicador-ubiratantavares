module Multiplier #(parameter N = 4) (
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg ready,
    input wire [N - 1:0] multiplier,
    input wire [N - 1:0] multiplicand,
    output reg [2 * N - 1:0] product
);

	// estados da máquina de estados
	reg [1:0] state, next_state;

	localparam IDLE = 2'b00, LOAD = 2'b01, CALC = 2'b10, DONE = 2'b11;

	// registradores internos
	reg [N - 1:0] reg_multiplier;
	reg [2 * N - 1:0] reg_multiplicand;
	reg [2 * N - 1:0] acc;
	reg [$clog2(N + 1) - 1:0] count;  // suficiente para contar até N

	// máquina de estados: transição
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			state = IDLE;
		else
			state = next_state;
	end

	// máquina de estados: lógica do próximo estado
	always @(*) begin
		case (state)
			IDLE: next_state = start ? LOAD : IDLE;
			LOAD: next_state = CALC;
			CALC: next_state = (count == 0) ? DONE : CALC;
			DONE: next_state = IDLE;
			default: next_state = IDLE;
		endcase
	end

	// lógica sequencial
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			reg_multiplier = 0;
			reg_multiplicand = 0;
			acc = 0;
			count = 0;
			product = 0;
			ready = 0;
		end else begin
			ready = 0; // Default: desativa ready exceto no estado DONE
			
			case (state)
				LOAD: begin
					reg_multiplier = multiplier;
					reg_multiplicand = { {N{1'b0}}, multiplicand }; // zera bits superiores
					acc = 0;
					count = N;
				end

				CALC: begin
					if (reg_multiplier[0])
						acc = acc + reg_multiplicand;
					reg_multiplicand = reg_multiplicand << 1;
					reg_multiplier = reg_multiplier >> 1;
					count = count - 1;
				end

				DONE: begin
					product = acc;
					ready = 1;
				end
			endcase
		end
	end
endmodule
