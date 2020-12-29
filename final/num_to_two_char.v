`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:56:06 11/26/2020 
// Design Name: 
// Module Name:    num_to_two_char 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module num_to_two_char(number, first_data, second_data);
input [6:0] number;
output [7:0] first_data;
output [7:0] second_data;
reg [3:0] ten, one;
wire [3:0] ten_num, one_num;

assign ten_num = ten;
assign one_num = one;

num_to_char_decoder D1(ten_num, first_data);
num_to_char_decoder D2(one_num, second_data);

always @ (number) begin
	if(number <= 9) begin
		ten = 4'b0000;
		one = number;
	end
	else if(number <= 19) begin
		ten = 1;
		one = number - 10;
	end
	else if(number <= 29) begin
		ten = 2;
		one = number - 20;
	end
	else if(number <= 39) begin
		ten = 3;
		one = number - 30;
	end
	else if(number <= 49) begin
		ten = 4;
		one = number - 40;
	end
	else begin
		ten = 5;
		one = number - 50;
	end
end

endmodule
