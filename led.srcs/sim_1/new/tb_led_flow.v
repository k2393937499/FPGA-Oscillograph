`timescale 1ns / 1ps

module LedController_tb;

// Inputs
reg clk;
reg rst;

// Outputs
wire [3:0] led;

// ʵ����LedControllerģ��
LedController uut (
    .clk(clk), 
    .rst(rst), 
    .led(led)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk; // ����ʱ���źţ��˴�����100MHzʱ��
end

initial begin
    // ��ʼ��
    rst = 1;
    
    // ����
    #100;
    rst = 0;
    
    // �۲�һ��ʱ����������
    #20000;
    $finish;
end

endmodule