`timescale 1ns / 1ps

module ad_recv(
    input clk,  //ʱ��
    input rst_n,  //��λ�źţ��͵�ƽ��Ч
    input [7:0] ad_data,  //AD��������
    output reg ad_clk
    );
    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        ad_clk <= 1'b0;
    else
        ad_clk <= ~ad_clk;
end
 
endmodule
