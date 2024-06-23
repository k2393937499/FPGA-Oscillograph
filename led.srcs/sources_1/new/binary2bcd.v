`timescale 1ns / 1ps
module binary2bcd (
    input [11:0] binary_in,  // �����12λ��������
    output reg [15:0] bcd_out  // �����BCD�룬���4λ��12λ��������ת��Ϊ4λBCD�룩
);
    // �м����
    reg [27:0] shift_reg;
    integer i;

    always @(*) begin
        // ��ʼ����λ�Ĵ���
        shift_reg = 28'd0;
        shift_reg[11:0] = binary_in;
        
        // ִ��12����λ����
        for (i = 0; i < 12; i = i + 1) begin
            // ���ÿһλ�ĸ�4λ�Ƿ���ڻ����5����������3
            if (shift_reg[15:12] >= 5)
                shift_reg[15:12] = shift_reg[15:12] + 3;
            if (shift_reg[19:16] >= 5)
                shift_reg[19:16] = shift_reg[19:16] + 3;
            if (shift_reg[23:20] >= 5)
                shift_reg[23:20] = shift_reg[23:20] + 3;
            
            // ����һλ
            shift_reg = shift_reg << 1;
        end
        
        // ��ȡBCD���
        bcd_out = shift_reg[27:12];
    end
endmodule