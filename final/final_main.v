`timescale 1ns / 1ps

module final_main(
clk,
resetn,
async_hour_up,
async_min_up,
async_sec_up,
async_ampm_mode_change,
async_start,
async_stop,
async_country_change,
lcd_e,
lcd_rs,
lcd_rw,
lcd_data,
piezo,
cmode
);



// Clk, Resetn
input clk;	// ComboBox Internal CLK_1KHz
input resetn;	// Async Reset
integer clk_cnt = 0;



// Basic Digital Clock Display Value
reg [5:0] hour = 0;
reg [5:0] min = 0;
reg [5:0] sec = 0;



// Basic Digital Clock Time Setting : InSync
// cmode
// 0 : Basic Digital Clock
// 1 : Basic Digital Clock Setting
// 2 : World Clock
// 3 : Alarm
// 4 : Stop Watch
input [7:0] cmode;
reg ampm_mode = 0;
reg is_am = 0;
input async_hour_up, async_min_up, async_sec_up, async_ampm_mode_change;
wire insync_hour_up, insync_min_up, insync_sec_up, insync_ampm_mode_change;
final_insync U1(async_hour_up, clk, insync_hour_up);
final_insync U2(async_min_up, clk, insync_min_up);
final_insync U3(async_sec_up, clk, insync_sec_up);
final_insync U4(async_ampm_mode_change, clk, insync_ampm_mode_change);



// World Clock - England
parameter t_delta = 9;
reg is_korea = 1;
input async_country_change;
wire insync_country_change;
final_insync U7(async_country_change, clk, insync_country_change);



// Alarm
output piezo;
input async_stop;
wire insync_stop;
reg [5:0] alarm_hour = 0;
reg [5:0] alarm_min = 0;
reg [5:0] alarm_sec = 0;
reg alarm_trig = 0;
reg buff = 0;
assign piezo = buff;
integer cnt_sound = 0;
final_insync U6(async_stop, clk, insync_stop);
wire [7:0] LCD_ALARM_TIME [5:0];
num_to_two_char N4(alarm_hour, LCD_ALARM_TIME[5], LCD_ALARM_TIME[4]);
num_to_two_char N5(alarm_min, LCD_ALARM_TIME[3], LCD_ALARM_TIME[2]);
num_to_two_char N6(alarm_sec, LCD_ALARM_TIME[1], LCD_ALARM_TIME[0]);



// Stop Watch
input async_start;
wire insync_start;
reg stopwatch_flag = 1;	// For init sec/min/hour to 0
reg is_start = 0; // Init mode is STOP
final_insync U5(async_start, clk, insync_start);



// Text LCD Display Control Params
output lcd_e, lcd_rs, lcd_rw;
output reg [7:0] lcd_data;
assign lcd_e = clk;
reg lcd_rs, lcd_rw;
reg [2:0] lcd_state;
integer cnt = 0;
parameter delay = 3'b000,
			 function_set = 3'b001,
			 entry_mode = 3'b010,
			 disp_onoff = 3'b011,
			 line1 = 3'b100,
			 line2 = 3'b101;			 



// Text LCD Display Data Params
reg [7:0] LCD_OUT_DATA [31:0];
wire [7:0] LCD_CLOCK_TIME [5:0];
num_to_two_char N1(hour, LCD_CLOCK_TIME[5], LCD_CLOCK_TIME[4]);
num_to_two_char N2(min, LCD_CLOCK_TIME[3], LCD_CLOCK_TIME[2]);
num_to_two_char N3(sec, LCD_CLOCK_TIME[1], LCD_CLOCK_TIME[0]);



// ################################################################################################
// ## Digital Clock ## LCD_OUT_DATA Setting Logic
// ################################################################################################
always @ (posedge clk) begin
	if(cmode == 0 || cmode == 1) begin	// Digital Clock Mode
		LCD_OUT_DATA[0] = 8'h20;	// Space
		LCD_OUT_DATA[1] = 8'h20;	// Space
		LCD_OUT_DATA[2] = 8'b01000100; // D
		LCD_OUT_DATA[3] = 8'b01001001;	// I
		LCD_OUT_DATA[4] = 8'b01000111; // G
		LCD_OUT_DATA[5] = 8'b01001001; // I
		LCD_OUT_DATA[6] = 8'b01010100; // T
		LCD_OUT_DATA[7] = 8'b01000001; // A
		LCD_OUT_DATA[8] = 8'b01001100; // L
		LCD_OUT_DATA[9] = 8'h20;	// Space
		LCD_OUT_DATA[10] = 8'b01000011; // C
		LCD_OUT_DATA[11] = 8'b01001100; // L
		LCD_OUT_DATA[12] = 8'b01001111; // O
		LCD_OUT_DATA[13] = 8'b01000011; // C
		LCD_OUT_DATA[14] = 8'b01001011; // K
		LCD_OUT_DATA[15] = 8'h20;	// Space
		LCD_OUT_DATA[16] = 8'h20;	// Space
		LCD_OUT_DATA[17] = 8'h20;	// Space
		LCD_OUT_DATA[18] = 8'h20;	// Space
		LCD_OUT_DATA[19] = 8'h20;	// Space
		if(ampm_mode) begin
			LCD_OUT_DATA[21] = 8'b01001101;	// M
			if(is_am) LCD_OUT_DATA[20] = 8'b01000001;	// A
			else LCD_OUT_DATA[20] = 8'b01010000;	// P
		end
		else begin
			LCD_OUT_DATA[20] = 8'h20;	// Space
			LCD_OUT_DATA[21] = 8'h20;	// Space
		end
		LCD_OUT_DATA[22] = 8'h20;	// Space
		LCD_OUT_DATA[23] = LCD_CLOCK_TIME[5];	// Hour
		LCD_OUT_DATA[24] = LCD_CLOCK_TIME[4];	// Hour
		LCD_OUT_DATA[25] = 8'b00111010;	// :
		LCD_OUT_DATA[26] = LCD_CLOCK_TIME[3];	// Min
		LCD_OUT_DATA[27] = LCD_CLOCK_TIME[2];	// Min
		LCD_OUT_DATA[28] = 8'b00111010;	// :
		LCD_OUT_DATA[29] = LCD_CLOCK_TIME[1];	// Sec
		LCD_OUT_DATA[30] = LCD_CLOCK_TIME[0];	// Sec
		LCD_OUT_DATA[31] = 8'h20;	// Space
	end
	
	else if(cmode == 2) begin	// World Clock Mode
		LCD_OUT_DATA[0] = 8'h20;	// Space
		LCD_OUT_DATA[1] = 8'h20;	// Space
		LCD_OUT_DATA[2] = 8'b01010111; // W
		LCD_OUT_DATA[3] = 8'b01001111; // O
		LCD_OUT_DATA[4] = 8'b01010010; // R
		LCD_OUT_DATA[5] = 8'b01001100; // L
		LCD_OUT_DATA[6] = 8'b01000100; // D
		LCD_OUT_DATA[7] = 8'h20;	// Space
		LCD_OUT_DATA[8] = 8'b00101101;	// -
		LCD_OUT_DATA[9] = 8'h20;	// Space
		if(is_korea) begin
			LCD_OUT_DATA[10] = 8'b01001011; // K
			LCD_OUT_DATA[11] = 8'b01001111; // O
			LCD_OUT_DATA[12] = 8'b01010010; // R
			LCD_OUT_DATA[13] = 8'b01000101; // E
			LCD_OUT_DATA[14] = 8'b01000001; // A
		end
		else begin
			LCD_OUT_DATA[10] = 8'h20;	// Space
			LCD_OUT_DATA[11] = 8'b01010101; // U
			LCD_OUT_DATA[12] = 8'b00101110; // .
			LCD_OUT_DATA[13] = 8'b01001011; // K
			LCD_OUT_DATA[14] = 8'b00101110; // .
		end
		LCD_OUT_DATA[15] = 8'h20;	// Space
		LCD_OUT_DATA[16] = 8'h20;	// Space
		LCD_OUT_DATA[17] = 8'h20;	// Space
		LCD_OUT_DATA[18] = 8'h20;	// Space
		LCD_OUT_DATA[19] = 8'h20;	// Space
		if(ampm_mode) begin
			LCD_OUT_DATA[21] = 8'b01001101;	// M
			if(is_am) LCD_OUT_DATA[20] = 8'b01000001;	// A
			else LCD_OUT_DATA[20] = 8'b01010000;	// P
		end
		else begin
			LCD_OUT_DATA[20] = 8'h20;	// Space
			LCD_OUT_DATA[21] = 8'h20;	// Space
		end
		LCD_OUT_DATA[22] = 8'h20;	// Space
		LCD_OUT_DATA[23] = LCD_CLOCK_TIME[5];	// Hour
		LCD_OUT_DATA[24] = LCD_CLOCK_TIME[4];	// Hour
		LCD_OUT_DATA[25] = 8'b00111010;	// :
		LCD_OUT_DATA[26] = LCD_CLOCK_TIME[3];	// Min
		LCD_OUT_DATA[27] = LCD_CLOCK_TIME[2];	// Min
		LCD_OUT_DATA[28] = 8'b00111010;	// :
		LCD_OUT_DATA[29] = LCD_CLOCK_TIME[1];	// Sec
		LCD_OUT_DATA[30] = LCD_CLOCK_TIME[0];	// Sec
		LCD_OUT_DATA[31] = 8'h20;	// Space
	end
	
	else if(cmode == 3) begin	// Alarm Mode
		LCD_OUT_DATA[0] = 8'h20;	// Space
		LCD_OUT_DATA[1] = 8'h20;	// Space
		LCD_OUT_DATA[2] = 8'h20;	// Space
		LCD_OUT_DATA[3] = 8'h20;	// Space
		LCD_OUT_DATA[4] = 8'b10010001;	// Bell Char
		LCD_OUT_DATA[5] = 8'h20;	// Space
		LCD_OUT_DATA[6] = 8'h20;	// Space
		LCD_OUT_DATA[7] = LCD_ALARM_TIME[5];	// Hour
		LCD_OUT_DATA[8] = LCD_ALARM_TIME[4];	// Hour
		LCD_OUT_DATA[9] = 8'b00111010;	// :
		LCD_OUT_DATA[10] = LCD_ALARM_TIME[3];	// Min
		LCD_OUT_DATA[11] = LCD_ALARM_TIME[2];	// Min
		LCD_OUT_DATA[12] = 8'b00111010;	// :
		LCD_OUT_DATA[13] = LCD_ALARM_TIME[1];	// Sec
		LCD_OUT_DATA[14] = LCD_ALARM_TIME[0];	// Sec
		LCD_OUT_DATA[15] = 8'h20;	// Space
		LCD_OUT_DATA[16] = 8'h20;	// Space
		LCD_OUT_DATA[17] = 8'h20;	// Space
		LCD_OUT_DATA[18] = 8'h20;	// Space
		LCD_OUT_DATA[19] = 8'h20;	// Space
		if(ampm_mode) begin
			LCD_OUT_DATA[21] = 8'b01001101;	// M
			if(is_am) LCD_OUT_DATA[20] = 8'b01000001;	// A
			else LCD_OUT_DATA[20] = 8'b01010000;	// P
		end
		else begin
			LCD_OUT_DATA[20] = 8'h20;	// Space
			LCD_OUT_DATA[21] = 8'h20;	// Space
		end
		LCD_OUT_DATA[22] = 8'h20;	// Space
		LCD_OUT_DATA[23] = LCD_CLOCK_TIME[5];	// Hour
		LCD_OUT_DATA[24] = LCD_CLOCK_TIME[4];	// Hour
		LCD_OUT_DATA[25] = 8'b00111010;	// :
		LCD_OUT_DATA[26] = LCD_CLOCK_TIME[3];	// Min
		LCD_OUT_DATA[27] = LCD_CLOCK_TIME[2];	// Min
		LCD_OUT_DATA[28] = 8'b00111010;	// :
		LCD_OUT_DATA[29] = LCD_CLOCK_TIME[1];	// Sec
		LCD_OUT_DATA[30] = LCD_CLOCK_TIME[0];	// Sec
		LCD_OUT_DATA[31] = 8'h20;	// Space
	end
	
	else if(cmode == 4) begin	// Stop Watch Mode
		LCD_OUT_DATA[0] = 8'h20;	// Space
		LCD_OUT_DATA[1] = 8'h20;	// Space
		LCD_OUT_DATA[2] = 8'h20;	// Space
		LCD_OUT_DATA[3] = 8'h20;	// Space
		LCD_OUT_DATA[4] = 8'h20;	// Space
		LCD_OUT_DATA[5] = 8'b01010011; // S
		LCD_OUT_DATA[6] = 8'b01010100; // T
		LCD_OUT_DATA[7] = 8'b01001111; // O
		LCD_OUT_DATA[8] = 8'b01010000; // P
		LCD_OUT_DATA[9] = 8'h20;	// Space
		LCD_OUT_DATA[10] = 8'b01010111; // W
		LCD_OUT_DATA[11] = 8'b01000001; // A
		LCD_OUT_DATA[12] = 8'b01010100; // T
		LCD_OUT_DATA[13] = 8'b01000011; // C
		LCD_OUT_DATA[14] = 8'b01001000; // H
		LCD_OUT_DATA[15] = 8'h20;	// Space
		LCD_OUT_DATA[16] = 8'h20;	// Space
		LCD_OUT_DATA[17] = 8'h20;	// Space
		LCD_OUT_DATA[18] = 8'h20;	// Space
		LCD_OUT_DATA[19] = 8'h20;	// Space
		
		LCD_OUT_DATA[20] = 8'h20;	// Space
		LCD_OUT_DATA[21] = 8'h20;	// Space
		
		LCD_OUT_DATA[22] = 8'h20;	// Space
		LCD_OUT_DATA[23] = LCD_CLOCK_TIME[5];	// Hour
		LCD_OUT_DATA[24] = LCD_CLOCK_TIME[4];	// Hour
		LCD_OUT_DATA[25] = 8'b00111010;	// :
		LCD_OUT_DATA[26] = LCD_CLOCK_TIME[3];	// Min
		LCD_OUT_DATA[27] = LCD_CLOCK_TIME[2];	// Min
		LCD_OUT_DATA[28] = 8'b00111010;	// :
		LCD_OUT_DATA[29] = LCD_CLOCK_TIME[1];	// Sec
		LCD_OUT_DATA[30] = LCD_CLOCK_TIME[0];	// Sec
		LCD_OUT_DATA[31] = 8'h20;	// Space
	end
	
end
			
// ################################################################################################
// LCD Display Logic
// ################################################################################################
always @ (posedge clk) begin
	if(~resetn)
		lcd_state = delay;
	else begin
		case (lcd_state)
			delay : 
				if(cnt == 70) lcd_state = function_set;
			function_set : 
				if(cnt == 30) lcd_state = disp_onoff;
			disp_onoff : 
				if(cnt == 30) lcd_state = entry_mode;
			entry_mode : 
				if(cnt == 30) lcd_state = line1;
			line1 : 
				if(cnt == 20) lcd_state = line2;
			line2 : 
				if(cnt == 20) lcd_state = line1;
			default : lcd_state = delay;
		endcase
	end
end

always @ (posedge clk) begin
	if(~resetn)
		cnt = 0;
	else begin
		case (lcd_state)
			delay : 
				if(cnt >= 70) cnt = 0;
				else cnt = cnt + 1;
			function_set :
				if(cnt >= 30) cnt = 0;
				else cnt = cnt + 1;
			disp_onoff :
				if(cnt >= 30) cnt = 0;
				else cnt = cnt + 1;
			entry_mode :
				if(cnt >= 30) cnt = 0;
				else cnt = cnt + 1;
			line1 :
				if(cnt >= 20) cnt = 0;
				else cnt = cnt + 1;
			line2 :
				if(cnt >= 20) cnt = 0;
				else cnt = cnt + 1;
			default : cnt = 0;
		endcase
	end
end

always @ (posedge clk)
begin
	if(~resetn)
		begin
			lcd_rs = 1'b1;
			lcd_rw = 1'b1;
			lcd_data = 8'b00000000;
		end
	else
		begin
			case (lcd_state)
				function_set : 
					begin
						lcd_rs = 1'b0;
						lcd_rw = 1'b0;
						lcd_data = 8'b00111100;
					end
				disp_onoff : 
					begin
						lcd_rs = 1'b0;
						lcd_rw = 1'b0;
						lcd_data = 8'b00001100;
					end
				entry_mode : 
					begin
						lcd_rs = 1'b0;
						lcd_rw = 1'b0;
						lcd_data = 8'b00000110;
					end
				line1 : 
					begin
						lcd_rw = 1'b0;
						case (cnt)
							0 : 
								begin
									lcd_rs = 1'b0;
									lcd_data = 8'b10000000;	
								end
							1 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[0];	
								end
							2 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[1];
								end
							3 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[2];
								end
							4 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[3];
								end
							5 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[4];
								end
							6 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[5];
								end
							7 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[6];
								end
							8 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[7];
								end
							9 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[8];
								end
							10 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[9];
								end
							11 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[10];
								end
							12 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[11];
								end
							13 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[12];
								end
							14 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[13];
								end
							15 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[14];
								end
							16 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[15];
								end
							default : 
								begin
									lcd_rs = 1'b1;
									lcd_data = 8'b00100000;	// space
								end
						endcase
					end
				line2 : 
					begin
						lcd_rw = 1'b0;
						case (cnt)
							0 : 
								begin
									lcd_rs = 1'b0;
									lcd_data = 8'b11000000;	
								end
							1 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[16];	
								end
							2 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[17];
								end
							3 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[18];
								end
							4 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[19];
								end
							5 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[20];
								end
							6 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[21];
								end
							7 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[22];
								end
							8 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[23];
								end
							9 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[24];
								end
							10 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[25];
								end
							11 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[26];
								end
							12 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[27];
								end
							13 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[28];
								end
							14 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[29];
								end
							15 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[30];
								end
							16 : 
								begin
									lcd_rs = 1'b1;
									lcd_data = LCD_OUT_DATA[31];
								end
							default : 
								begin
									lcd_rs = 1'b1;
									lcd_data = 8'b00100000;	// space
								end
						endcase
					end
										
				default : 
					begin
						lcd_rs = 1'b1;
						lcd_rw = 1'b1;
						lcd_data = 8'b00000000;
					end
			endcase
		end
end



// ################################################################################################
// Alarm PIEZO
// ################################################################################################

always @ (posedge clk) begin
	if(alarm_trig == 1) begin
		if(cnt_sound >= 1) begin
			cnt_sound = 0;
			buff = ~buff;
		end
		else cnt_sound = cnt_sound + 1;
	end
end



// ################################################################################################
// Digital Clock
// ################################################################################################

// Counter for 1sec Counting
always @ (posedge clk) begin
	if(cmode == 0 && ~resetn) clk_cnt = 0;
	else begin
		if(clk_cnt >= 999) clk_cnt = 0;
		else clk_cnt = clk_cnt + 1;
	end
end

// Block1. Sec
always @ (posedge clk) begin
	case(cmode)
		0:	// Mode0. Basic Clock Mode
		begin
			stopwatch_flag = 1;	// Only Here
			if(~resetn) sec = 0;
			else begin
				if(clk_cnt == 999) begin
					if(sec >= 59) sec = 0;
					else sec = sec + 1;
				end
			end
		end
		1:	// Mode1. Time Setting Mode
		begin
			stopwatch_flag = 1;	// Only Here
			if(~resetn) sec = 0;
			else begin
				if(insync_sec_up) begin
					if(sec >= 59) sec = 0;
					else sec = sec + 1;
				end
				// Only Up Now.
			end
		end
		2:	// Mode2. World Clock Mode
		begin
			stopwatch_flag = 1;	// Only Here
			if(~resetn) sec = 0;
			else begin
				if(clk_cnt == 999) begin
					if(sec >= 59) sec = 0;
					else sec = sec + 1;
				end
			end
		end
		3:	// Mode2. Alarm Mode
		begin
			stopwatch_flag = 1;	// Only Here
			if(~resetn) alarm_sec = 0;
			else begin
				if(clk_cnt == 999) begin
					if(sec >= 59) sec = 0;
					else sec = sec + 1;
				end
				if(insync_sec_up) begin
					if(alarm_sec >= 59) alarm_sec = 0;
					else alarm_sec = alarm_sec + 1;
				end
			end
		end
		4: // Mode4. Stop Watch
		begin
			if(stopwatch_flag == 1 || ~resetn) sec = 0;
			else begin
				if(insync_start) is_start = ~is_start;
				if(is_start) begin
					if(clk_cnt == 999) begin
						if(sec >= 59) sec = 0;
						else sec = sec + 1;
					end
				end
			end
			stopwatch_flag = 0;
		end
	endcase
end

// Block2. Min
always @ (posedge clk) begin
	case(cmode)
		0:	// Mode0. Basic Clock Mode
		begin
			if(~resetn) min = 0;
			else begin
				// If doesn't exist 'sec == 59',
				// min will count up at each 1s
				if(clk_cnt == 999 && sec == 59) begin
					if(min >= 59) min = 0;
					else min = min + 1;
				end
			end
		end
		1:	// Mode1. Time Setting Mode
		begin
			if(~resetn) min = 0;
			else begin
				if(insync_min_up) begin
					if(min >= 59) min = 0;
					else min = min + 1;
				end
				// Only Up Now.
			end
		end
		2:	// Mode2. World Clock Mode
		begin
			if(~resetn) min = 0;
			else begin
				// If doesn't exist 'sec == 59',
				// min will count up at each 1s
				if(clk_cnt == 999 && sec == 59) begin
					if(min >= 59) min = 0;
					else min = min + 1;
				end
			end
		end
		3:	// Mode2. Alarm Mode
		begin
			if(~resetn) alarm_min = 0;
			else begin
				if(clk_cnt == 999 && sec == 59) begin
					if(min >= 59) min = 0;
					else min = min + 1;
				end
				if(insync_min_up) begin
					if(alarm_min >= 59) alarm_min = 0;
					else alarm_min = alarm_min + 1;
				end
			end
		end
		4: // Mode4. Stop Watch
		begin
			if(stopwatch_flag == 1 || ~resetn) min = 0;
			else begin
				if(insync_start) is_start = ~is_start;	// toggle
				if(is_start) begin
					if(clk_cnt == 999 && sec == 59) begin
						if(min >= 59) min = 0;
						else min = min + 1;
					end
				end
			end
		end
	endcase
end

// Block3. Hour
always @ (posedge clk) begin
	case(cmode)
		0:	// Mode0. Basic Clock Mode
		begin
			if(~resetn) hour = 0;
			else begin
				// If doesn't exist 'min == 59 && sec == 59',
				// hour will count up at each 1s
				if(clk_cnt == 999 && min == 59 && sec == 59) begin
					if(ampm_mode) begin	// AM/PM Mode : 0~11
						if(hour >= 11) hour = 0;
						else hour = hour + 1;
						is_am = ~is_am;
					end
					else begin	// Not AM/PM Mode : 0~23
						if(hour >= 23) hour = 0;
						else hour = hour + 1;
					end
				end
			end
		end
		1:	// Mode1. Time Setting Mode
		begin
			if(~resetn) hour = 0;
			else begin
				// Only Up Now.
				if(insync_hour_up) begin
					if(ampm_mode) begin	// AM/PM Mode : 0~11
						if(hour >= 11) begin
							hour = 0;
							is_am = ~is_am;	// Toggle AM/PM
						end
						else hour = hour + 1;
					end
					else begin	// Not AM/PM Mode : 0~23
						if(hour >= 23) hour = 0;
						else hour = hour + 1;
					end
				end
			end
			if(insync_ampm_mode_change) begin
				ampm_mode = ~ampm_mode;	// Enable AM/PM or Not
				if(hour >= 11) begin
					hour = hour - 12;
					is_am = 0;	// Toggle AM/PM
				end
				else if(ampm_mode == 0 && is_am == 0) begin
					hour = hour + 12;
				end
			end
		end
		2:	// Mode2. World Clock Mode
		begin
			if(~resetn) hour = 0;
			else begin
				// If doesn't exist 'min == 59 && sec == 59',
				// hour will count up at each 1s
				if(clk_cnt == 999 && min == 59 && sec == 59) begin
					if(ampm_mode) begin	// AM/PM Mode : 0~11
						if(hour >= 11) hour = 0;
						else hour = hour + 1;
						is_am = ~is_am;
					end
					else begin	// Not AM/PM Mode : 0~23
						if(hour >= 23) hour = 0;
						else hour = hour + 1;
					end
				end
				if(insync_country_change) begin
					if(ampm_mode) begin	// AM/PM Mode : 0~11
						if(is_korea) begin
							if(hour < 9) hour = 12 - (9 - hour);
							else hour = hour - 9;
						end
						else begin
							hour = hour + 9;
							if(hour >= 12) hour = hour - 12;
						end						
						is_am = ~is_am;
					end
					else begin	// Not AM/PM Mode : 0~23
						if(is_korea) begin
							if(hour < 9) hour = 24 - (9 - hour);
							else hour = hour - 9;
						end
						else begin
							hour = hour + 9;
							if(hour >= 24) hour = hour - 24;
						end
					end
					is_korea = ~is_korea;
				end
			end
		end
		3:	// Mode2. Alarm Mode
		begin
			if(~resetn) alarm_hour = 0;
			else begin
				if(clk_cnt == 999 && min == 59 && sec == 59) begin
					if(hour >= 23) hour = 0;
					else hour = hour + 1;
				end
				if(insync_hour_up) begin
					if(alarm_hour >= 23) alarm_hour = 0;
					else alarm_hour = alarm_hour + 1;
				end
				if(insync_stop) alarm_trig = 0;
				if(ampm_mode) begin
					if(is_am) begin
						if(sec == alarm_sec && min == alarm_min && hour == alarm_hour) alarm_trig = 1;
					end
					else begin
						if(sec == alarm_sec && min == alarm_min && (hour+12) == alarm_hour) alarm_trig = 1;
					end
				end
				else begin
					if(sec == alarm_sec && min == alarm_min && hour == alarm_hour) alarm_trig = 1;
				end
			end
		end
		4: // Mode4. Stop Watch
		begin
			if(stopwatch_flag == 1 || ~resetn) hour = 0;
			else begin
				if(insync_start) is_start = ~is_start;
				if(is_start) begin
					if(clk_cnt == 999 && min == 59 && sec == 59) begin
						if(hour >= 59) hour = 0;	// Limit is 59
						else hour = hour + 1;
					end
				end
			end
		end
	endcase
end
endmodule
