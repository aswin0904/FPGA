module top_module(
	input clk,
	input A,
	input B,
	input reset,
	//input [7:0] angle,
	output [3:0] anode,
	output [6:0] num, 
	output up_count
	//output [2:0] state
    );
	wire [8:0] angle;
	encoder enc(.A(A), .B(B), .clk(clk), .reset(reset), .angle(angle), .up_count(up_count));
	seg7_display seg7(.clk(clk), .angle(angle), .anode(anode), .num(num));
endmodule

module encoder(
	input clk,
	input A,
	input B,
	input reset,
	output [8:0] angle,
	output reg up_count
	//output reg [2:0] state
    );
	 
	wire posedge_A;
	wire negedge_A;
	wire posedge_B;
	wire negedge_B;
	
	reg [11:0] counter = 0;
//	reg up_count;
	reg A_d;
	reg B_d; 
	 
	always @(posedge clk) begin
		A_d <= A;
		B_d <= B;
		end
	

	assign posedge_A = ~A_d & A;
	assign negedge_A = A_d & ~A;
	assign posedge_B = ~B_d & B;
	assign negedge_B = B_d & ~B;
	
//	reg [2:0] state;
	parameter idle = 3'b000, F1 = 3'b001, F2 = 3'b010, F3 = 3'b011,
									 R1 = 3'b101, R2 = 3'b110, R3 = 3'b111;
	
//	always @(posedge clk) begin
//		case(state)
//			idle: if(~A & posedge_B)
//						state <= F1 ;
//					else if (posedge_A & ~B) 
//						state <= R1;
//					else 
//						state <= idle;
//			F1: state <= (posedge_A & B) ? F2 : F1;
//			F2: state <= (A & negedge_B) ? F3 : F2;
//			F3: if(negedge_A & ~B) begin 
//					state <= idle; 
//					up_count <= 1; end
//				 else begin 
//					state <= F3; 
//					up_count <= up_count; end
//			R1: state <= (posedge_B & A) ? R2 : R1;
//			R2: state <= (negedge_A & B) ? R3: R2;
//			R3: if(~A & negedge_B) begin 
//					state <= idle; 
//					up_count <= 0; end
//				 else begin 
//					state <= R3; 
//					up_count <= up_count; end
//			default: state <= idle;
//		endcase
//		end
		
	reg [3:0] F, R;
	always @(posedge clk) begin
	if(~A & posedge_B) begin F[0] <= 1; R <= 4'b0; end
	if(posedge_A & B)  begin F[1] <= 1; R <= 4'b0; end
	if(A & negedge_B)  begin F[2] <= 1; R <= 4'b0; end
	if(negedge_A & ~B) begin F[3] <= 1; R <= 4'b0; end
	if(posedge_A & ~B) begin R[0] <= 1; F <= 4'b0; end
	if(posedge_B & A)  begin R[1] <= 1; F <= 4'b0; end
	if(negedge_A & B)  begin R[2] <= 1; F <= 4'b0; end
	if(~A & negedge_B) begin R[3] <= 1; F <= 4'b0; end
	if(R == 4'b1111) up_count <= 0;
	else if(F == 4'b1111) up_count <= 1;
	else up_count <= up_count;
	end
		
	always @(posedge clk or posedge reset) begin
    if (reset)
        counter <= 0;
    else if (posedge_A | negedge_A | posedge_B | negedge_B) begin
        if (up_count) begin
            if (counter == 12'd4000)
                counter <= 0;
            else
                counter <= counter + 1;
        end else if(~up_count) begin
            if (counter == 0)
                counter <= 12'd4000;
            else
                counter <= counter - 1;
        end
		end
	end

	
	wire [8:0] Quo, Rem;
	reg [20:0] temp; 
	divider div(.Q(temp),.M(12'd4000), .Quo(Quo), .Rem(Rem));
	always @(*)begin
		temp = counter * 360;
		end
	assign angle = Quo;
	
endmodule

module time_div(input clk, output reg clk_div);
	reg [21:0] s = 22'b0;
	always @(posedge clk) begin
		s <= s+1;
		clk_div <= s[12];
		end
endmodule

module seg7_display(
	input clk,
	input [8:0] angle,
	output reg [3:0] anode,
	output reg [6:0] num	
    );
	 
	 reg [3:0] num_reg;
	
	always @(num_reg)begin
			case(num_reg)
				4'd0: num <= 7'b1000000;
				4'd1: num <= 7'b1111001;
				4'd2: num <= 7'b0100100;
				4'd3: num <= 7'b0110000;
				4'd4: num <= 7'b0011001;
				4'd5: num <= 7'b0010010;
				4'd6: num <= 7'b0000010;
				4'd7: num <= 7'b1111000;
				4'd8: num <= 7'b0000000;
				4'd9: num <= 7'b0010000;
				default: num <= 7'b0000000;
			endcase
		end
		
	wire [3:0] hundreds, tens, ones;
	wire [6:0] Quo2, Rem1, Rem2, Quo3;
	divider div1(.Q(angle), .M(7'd100), .Quo(hundreds), .Rem(Rem1));
	divider div2(.Q(Rem1), .M(4'd10), .Quo(tens), .Rem(Rem2));
	divider div3(.Q(angle), .M(4'd10), .Quo(Quo3), .Rem(ones));
	
	reg [2:0] state=0;
	parameter S0 = 0, S1 =1, S2 =2, S3 =3, S4 =4;
	wire clk_div;
   time_div td(.clk(clk),.clk_div(clk_div));
   always @(posedge clk_div) begin
		case (state)
		S0: begin state <= S1;end 
		S1: begin state <= S2; end
		S2: begin state <= S3; end
		S3: begin state <= S0; end
		S4:  begin state <= S0;  end
		default: state <= S0;
		endcase 
		end
	always @(state) begin
	case (state)
	S0: begin anode <= 4'b0111; num_reg <= ones; end
	S1: begin anode <= 4'b1011; num_reg <= tens; end
	S2: begin anode <= 4'b1101; num_reg <= hundreds; end
	S3: begin anode <= 4'b1110; num_reg <= 0; end
	S4: begin anode <= 4'b1111; num_reg <= 0; end
	default: begin anode <= 4'b1111; num_reg <= 0; end 
	endcase 
	end
	
endmodule
