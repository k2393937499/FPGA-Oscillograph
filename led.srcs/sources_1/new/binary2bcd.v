`timescale 1ns / 1ps
module binary2bcd (
    input [11:0] binary_in,  // 输入的12位二进制数
    output reg [15:0] bcd_out  // 输出的BCD码，最多4位（12位二进制数转换为4位BCD码）
);
    // 中间变量
    reg [27:0] shift_reg;
    integer i;

    always @(*) begin
        // 初始化移位寄存器
        shift_reg = 28'd0;
        shift_reg[11:0] = binary_in;
        
        // 执行12次移位操作
        for (i = 0; i < 12; i = i + 1) begin
            // 检查每一位的高4位是否大于或等于5，如果是则加3
            if (shift_reg[15:12] >= 5)
                shift_reg[15:12] = shift_reg[15:12] + 3;
            if (shift_reg[19:16] >= 5)
                shift_reg[19:16] = shift_reg[19:16] + 3;
            if (shift_reg[23:20] >= 5)
                shift_reg[23:20] = shift_reg[23:20] + 3;
            
            // 左移一位
            shift_reg = shift_reg << 1;
        end
        
        // 提取BCD结果
        bcd_out = shift_reg[27:12];
    end
endmodule