`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:03:08 11/25/2020 
// Design Name: 
// Module Name:    final_insync 
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
module final_insync(input_signal, clk, output_insync);
input input_signal, clk;
output reg output_insync;
reg trig;

always @ (negedge clk) begin
	trig <= input_signal;
	output_insync <= input_signal & ~trig;
end

endmodule
