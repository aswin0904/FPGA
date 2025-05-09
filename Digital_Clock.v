module time_div(input clk, output reg clk_div, output reg one_sec);
	reg [25:0] s = 0;
	reg [25:0]counter=0;
	
	always @(posedge clk )
	
	begin
	if(counter == 50000000-1)
	begin 
	    counter<=0;
		 one_sec<=1;
		 
		 end
	else
begin 
counter<=counter+1;
one_sec<=0;	
	end
	end 
	always @(posedge clk) begin
		s <= s+1;
		clk_div <= s[12];
		end
endmodule



module seven_segment( 

    input sw,

    input clk,

    output reg [6:0] num, 

    output reg [3:0] anode,

    output wire led

);  



    integer i, j; 

    reg [3:0] bcd_tens1, bcd_ones1, bcd_tens2, bcd_ones2;

    reg [2:0] state = 0;

    reg[5:0] sec_co = 0;

    reg [5:0] number1 =17;

    reg [5:0] number2=10;

    reg [5:0] temp1;
	 reg [5:0] temp2;

    reg [3:0] digit_0, digit_1, digit_2, digit_3;

    wire clk_div;

    reg t = 0;

     

     wire one_sec;

    // Instantiate time divider module

    time_div td(.clk(clk), .clk_div(clk_div), .one_sec(one_sec));

     

    always @(posedge one_sec) begin

        if (sw) begin 

            t <= ~t; // Toggle LED

            if (sec_co == 59) begin

                sec_co <= 0;

                if (number1 == 59) begin

                    number1 <= 0;

                    if(number2==23)
			begin number2<=0;
				end
			else begin
			number2<=number2+1;

                end end else begin
					 

                    number1 <= number1 + 1;
                end
            end else begin
                sec_co <= sec_co + 1;
            end
        end else begin
            // Reset when switch is off
            number1 <= 0;
            sec_co  <= 0;
        end
    end
    assign led = t; 
    always @(*) begin
        temp1 = number1;
        temp2=number2;
        // Extract tens place (10s)
		   bcd_tens2 = 0;

        for (i= 0; i < 10; i = i + 1) begin

            if (temp2 >= 10) begin

                temp2 = temp2 - 10;

                bcd_tens2 = bcd_tens2 + 1;

            end

        end
		  bcd_ones2 = temp2;

        digit_3 =bcd_tens2 ; 

        digit_2 =bcd_ones2 ;



        bcd_tens1 = 0;

        for (j = 0; j < 10; j = j + 1) begin

            if (temp1 >= 10) begin

                temp1 = temp1 - 10;

                bcd_tens1 = bcd_tens1 + 1;

            end

        end

        bcd_ones1 = temp1;

        digit_1 = bcd_tens1;

        digit_0 = bcd_ones1;

    end



    // State machine for 7-segment display multiplexing

    parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;



    always @(posedge clk_div) begin

        case (state)

            S0: state <= sw ? S1 : S4;

            S1: state <= sw ? S2 : S4;

            S2: state <= sw ? S3 : S4;

            S3: state <= sw ? S0 : S4;

            S4: state <= sw ? S0 : S4;

            default: state <= S0;

        endcase 

    end



    // Function to map BCD to 7-segment encoding

    function [6:0] num12;

        input [3:0] value;

        begin

            case (value)

                4'd0: num12 = 7'b1000000;

                4'd1: num12 = 7'b1111001;

                4'd2: num12 = 7'b0100100;

                4'd3: num12 = 7'b0110000;

                4'd4: num12 = 7'b0011001;

                4'd5: num12 = 7'b0010010;

                4'd6: num12 = 7'b0000010;

                4'd7: num12 = 7'b1111000;

                4'd8: num12 = 7'b0000000;

                4'd9: num12 = 7'b0010000;

                default: num12 = 7'b1111111;

            endcase

        end

    endfunction



    always @(state) begin

        case (state)

            S0: begin anode <= 4'b0111; num <= num12(digit_0); end

            S1: begin anode <= 4'b1011; num <= num12(digit_1); end

            S2: begin anode <= 4'b1101; num <= num12(digit_2); end

            S3: begin anode <= 4'b1110; num <= num12(digit_3); end

            S4: begin anode <= 4'b1111; num <= 7'b1111111; end

            default: begin anode <= 4'b1111; num <= 7'b1111111; end 

        endcase 

    end

endmodule
