module time_div(input clk, output reg clk_div);
	reg [21:0] s = 22'b0;
	always @(posedge clk) begin
		s <= s+1;
		clk_div <= s[21];
		end
endmodule

module seven_segment( 
	 input num_in, 
	 input clk,
    output reg [6:0] num, 
    output reg [3:0] anode
);
	reg [2:0] state=0;
	parameter S0 = 0, S1 =1, S2 =2, S3 =3, S4 =4;
	wire clk_div;
   time_div td(.clk(clk),.clk_div(clk_div));
   always @(posedge clk_div) begin
		case (state)
		S0: begin state <= num_in ? S1 : S4;end 
		S1: begin state <= num_in ? S2 : S4; end
		S2: begin state <= num_in ? S3 : S4; end
		S3: begin state <= num_in ? S0 : S4; end
		S4:  begin state <= num_in ? S0 : S4;  end
		default: state <= S0;
		endcase 
		end 
	always @(state) begin
	case (state)
	S0: begin anode <= 4'b0111; num <= 7'b0011001; end
	S1: begin anode <= 4'b1011; num <= 7'b0000000; end
	S2: begin anode <= 4'b1101; num <= 7'b0010000; end
	S3: begin anode <= 4'b1110; num <= 7'b1111001; end
	S4: begin anode <= 4'b1111; num <= 7'b1111111; end
	default: begin anode <= 4'b1111; num <= 7'b1111111; end 
	endcase 
	end
endmodule

