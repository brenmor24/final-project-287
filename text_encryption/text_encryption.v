module text_encryption(
input clk,
input rst,
input send_data,						// want to have an input en? Prob not?
input [15:0]user_input,				// may not need this - this is currently unused
input encr_go,							// button for user to press which starts the encryption
input [1:0]select_disp,					// for users to select between viewing each group of 16 bits in the key/value on the 7-seg display		
output reg [63:0]msg,

input [3:0]most,
input [3:0]most_2,
input [3:0]least_2,
input [3:0]least,

output [6:0]seg7_most,
output [6:0]seg7_most_2,
output [6:0]seg7_least_2,
output [6:0]seg7_least
);

reg [63:0]key;
reg [63:0]value;

/*
Total time spent: 6 hours

Design:
	1) 64-bit encryption key that we will get by flipping on 16 switches x 4 times
		- ALWAYS give the user the ability to go back and edit each bit in 1 of the 4 cycles
		- Counter to check how many times the button has been pressed before moving to the next state
		- Display each 16-bit hex value on the 7-seg and then display the 64-bit value on the LCD once all 4 cycles are done
	2) 64-bit input for encryption that we will get by flipping on 16 switches x 4 times
		- Update the LCD display (?) after each 16-bit hex digit is input, going from MSb to LSb
	3) Encrypt value using key
		- Create .mif files for the encryption
	4) Store the encrypted value in on-chip memory (register?)
	5) Display the 4 16-bit hex digits on the LCD display (?)
	6) Have the user put in the same encryption key as before and then the output from the 7-seg display
	7) Output the decrypted value
		- THIS SHOULD BE THE SAME AS THE INPUT VALUE FROM STEP 2!
	
	
	BUTTONS:
	1. rst
	2. en
	3. go through each of the 4 cycles when entering in info
	4. encrypt? (could also use SW16/17)

*/

/*
reg [3:0]most_r;
reg [3:0]most_2_r;
reg [3:0]least_2_r;
reg [3:0]least_r;
*/

seven_segment hex1(most, seg7_most);
seven_segment hex2(most_2, seg7_most_2);
seven_segment hex3(least_2, seg7_least_2);
seven_segment hex4(least, seg7_least);

// FSM
reg [4:0]S;
reg [4:0]NS;

parameter START = 5'd0,
			 IN_KEY = 5'd1,
			 DISP_KEY = 5'd2,
			 IN_VALUE = 5'd3,
			 DISP_KEY_VAL = 5'd4,
			 ENCR = 5'd5,
			 DISP_MSG = 5'd6,
			 DONE = 5'd7,
			 ERROR = 5'b11111;
			 
reg [2:0]button_count;

// NS transitions			 
always @(*)
begin
	
	case(S)
		START: NS = DISP_INIT;
		DISP_INIT: NS = IN_KEY;
	
		IN_KEY:
		begin
			if (button_count >= 3'd5)
				NS = DISP_KEY;
			else
				NS = IN_KEY;
		end
	
		DISP_KEY: NS = IN_VALUE;
	
		IN_VALUE:
		begin
			if (button_count >= 3'd5)
				NS = DISP_KEY_VAL;
			else
				NS = IN_VALUE;
		end
	
		DISP_KEY_VAL:
		begin
			if (encr_go == 1'b1)
				NS = ENCR;
			else
				NS = DISP_KEY_VAL;
		end
	
		ENCR: NS = DISP_MSG;
		DISP_MSG: NS = DONE;
		DONE: NS = DONE;
		default: NS = ERROR;
		
	endcase
	
end

// What happens in each state
always @(posedge clk or negedge rst)
begin
	case(S)
	
		START:
		begin
			// set EVERYTHING to 0 (key, value, msg, button_count, encr_go, inputs for hex and LCD displays, etc)
		end
		
		DISP_INIT:
		begin
			//
		end
		
		IN_KEY:
		begin
			if (send_data == 1'b0)
				button_count <= button_count + 3'd1;
			
			if (button_count == 3'd1)
				key[15:0] <= user_input;
				
			if (button_count == 3'd2)
				key[31:16] <= user_input;
				
			if (button_count == 3'd3)
				key[47:32] <= user_input;
				
			if (button_count == 3'd4)
				key[63:48] <= user_input;
				
		end
		
	endcase
end

// FSM init
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)							// rst is mapped to buttons so have it pressed as soon as the program starts
		S <= START;
	else
		S <= NS;
end

endmodule
