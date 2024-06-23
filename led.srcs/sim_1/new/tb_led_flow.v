`timescale 1ns / 1ps

module LedController_tb;

// Inputs
reg clk;
reg rst;

// Outputs
wire [3:0] led;

// 实例化LedController模块
LedController uut (
    .clk(clk), 
    .rst(rst), 
    .led(led)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk; // 产生时钟信号，此处假设100MHz时钟
end

initial begin
    // 初始化
    rst = 1;
    
    // 重置
    #100;
    rst = 0;
    
    // 观测一段时间后结束仿真
    #20000;
    $finish;
end

endmodule