`timescale 1ns / 1ps
module divide
(  
input[31:0] a,   
input[31:0] b,  
input enable,
output reg [31:0] yshang,  
output reg [31:0] yyushu,
output reg done 
);  
  
reg[31:0] tempa;  
reg[31:0] tempb;  
reg[63:0] temp_a;  
reg[63:0] temp_b;  
  
integer i;  
  
always @(a or b)  
begin  
    tempa <= a;  
    tempb <= b;  
end  
  
always @(tempa or tempb)  
begin  
if(enable)
  begin
    temp_a = {32'h00000000,tempa};  
    temp_b = {tempb,32'h00000000};  
    done = 0; 
    for(i = 0;i < 32;i = i + 1)  
        begin  
            temp_a = {temp_a[62:0],1'b0};  
            if(temp_a[63:32] >= tempb)  
                temp_a = temp_a - temp_b + 1'b1;  
            else  
                temp_a = temp_a;  
        end  
  
    yshang = temp_a[31:0];  
    yyushu = temp_a[63:32]; 
    done = 1; 
  end
end  
  
endmodule
