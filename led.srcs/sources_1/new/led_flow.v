`timescale 1ns / 1ps

module LedController(
    input clk, // 时钟信号
    input rst, // 复位信号
    output reg [3:0] led // 4个LED的控制信号
);

// 用于产生延时的计数器，宽度根据需要而定
reg [23:0] counter;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
        led <= 4'b0001; // 初始状态，点亮第一个LED
    end else if (counter >= 24'd10000000) begin // 约定每次移位的延时，此处为示例值
        counter <= 0;
        led <= {led[2:0], led[3]}; // 移位操作
    end else begin
        counter <= counter + 1;
    end
end

endmodule
