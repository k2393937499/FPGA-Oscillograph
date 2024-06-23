`timescale 1ns / 1ps

module ad_recv(
    input clk,  //时钟
    input rst_n,  //复位信号，低电平有效
    input [7:0] ad_data,  //AD输入数据
    output reg ad_clk
    );
    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        ad_clk <= 1'b0;
    else
        ad_clk <= ~ad_clk;
end
 
endmodule
