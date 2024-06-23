`timescale 1ns / 1ps

module LedController(
    input clk, // ʱ���ź�
    input rst, // ��λ�ź�
    output reg [3:0] led // 4��LED�Ŀ����ź�
);

// ���ڲ�����ʱ�ļ���������ȸ�����Ҫ����
reg [23:0] counter;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
        led <= 4'b0001; // ��ʼ״̬��������һ��LED
    end else if (counter >= 24'd10000000) begin // Լ��ÿ����λ����ʱ���˴�Ϊʾ��ֵ
        counter <= 0;
        led <= {led[2:0], led[3]}; // ��λ����
    end else begin
        counter <= counter + 1;
    end
end

endmodule
