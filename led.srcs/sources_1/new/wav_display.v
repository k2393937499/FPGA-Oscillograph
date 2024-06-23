`timescale 1ns / 1ps
module wav_display(
	input            rst_n,   
	input            btn_1,
	input            btn_2,
	input            btn_3,
	input            btn_4,
	input            pclk,
	input            ila_clk,
	input[10:0]      adc_addr,
	input[7:0]       adc_data,
	input[23:0]      wave_color,
	input            i_hs,    
	input            i_vs,    
	input            i_de,	
	input[23:0]      i_data,  
	output           o_hs,    
	output           o_vs,    
	output           o_de,    
	output[23:0]     o_data,
	output reg[7:0]  feng, // 峰峰值
	output reg[11:0] freq  // 频率
);
wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[23:0] pos_data;
reg[23:0]  v_data;

reg[10:0] rom_addr;
wire [7:0] q;
reg        region_active;

//为了更好的显示，每5帧刷新一次波形
reg [1:0] frame_counter;
reg write_en;

// 横轴调节部分，通过调整显示用的时钟实现
wire pclk_2x;
reg [2:0] idx_1;
clk_wiz_1 clk_wiz_1(
    .clk_in1(pclk),
    .clk_out1(pclk_2x)
);
wire [1:0] clk_arr = {pclk_2x, pclk};

// 纵轴调节部分
reg [7:0] q_temp;
wire [7:0] q_out;

// 计算频率和峰峰值
reg [7:0] max;
reg [7:0] min;
reg [11:0] cnt;
reg [11:0] idx;
reg [7:0] mean;

// fft
wire [7:0] fft_ans;

assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;

initial begin
    min = 8'b11111111;
    cnt = 1'b0;
    idx = 1'b0;
end

// 每5帧写入一次
always@(posedge pos_vs)
begin
    frame_counter <= frame_counter + 1'b1;
    if((frame_counter == 2'b11))
        write_en <= 1'b1;
    else
        write_en <= 1'b0;
end

always@(posedge pclk)
begin
    if(pos_y >= 12'd9 && pos_y <= 12'd471 && pos_x >= 12'd9 && pos_x  <= 12'd631)
        region_active <= 1'b1;
    else
        region_active <= 1'b0;
end

// RAM读取
always@(posedge clk_arr[idx_1])
begin
	if(region_active == 1'b1 && pos_de == 1'b1)		
		rom_addr <= rom_addr + 1'b1;
	else
		rom_addr <= 1'b0;
end

/* if q + pos_y = 287, use wave color, because q is 8 bit, max value is 8'd255, so minimum pos_y is 32.
   for example, if in line 32, pos_y value is 32, when data read from ram is 255, in (pos_x, pos_y) position,
   use wave color, other points in this line use previous color. In every line, ram will be read  */
reg triger_en;  // 用于判断pos_de信号的上升沿
reg [1:0]pos_edge;
reg d;
reg [18:0]temp;
reg [7:0]triger;

// 触发电平调节
// 通过长按按钮调节
// 当显示波形时，如果大于触发电平，则显示波形，否则不显示
always@(posedge pclk)
begin
    if(btn_3)
        temp <= temp + 1'b1;
    if(temp == 19'b1111111111111111111)
        triger <= triger + 1'b1;
end

always@(posedge pclk)
begin
    pos_edge <= {pos_edge[0], pos_de};
    d <= ~pos_edge[1] & pos_edge[0]; //判断pos_de的上升沿，pos_de的上升一次，屏幕刷新一次，每次刷新时判断采集到的信号是否大于触发电平
    if (d & (q_temp >= triger))
        triger_en <= 1'b1;
    if (d & (q_temp < triger))
        triger_en <= 1'b0;
    if(region_active == 1'b1 & pos_de == 1'b1 & triger_en == 1'b1)
        if(12'd330 - pos_y == {4'd0,q_temp})	
            v_data <= wave_color;
        else
            v_data <= pos_data;
    else
        v_data <= pos_data;
end

// 横轴调节
// 不同的idx_1代表读取RAM的不同频率的时钟
always@(posedge pclk)
begin
    if(btn_1)
        idx_1 <= 1'b1;
    else
        idx_1 <= 1'b0;
end

// 纵轴调节
// 直接定义一个变量，值为原本值的一半
always@(posedge pclk)
begin
    if(btn_2)
        q_temp <= q >> 1;
    else if(btn_4)
        q_temp <= fft_ans;
    else
        q_temp <= q;
end

// 频率和峰峰值
// 求最大值、最小值、平均值，最大最小值用于求峰峰值，平均值用于求频率
// 最大值最小值每隔一段时间清空，避免最大值达到255，最小值达到0后峰峰值不变
reg [15:0] cntt;
always @ (posedge ila_clk) begin
    feng <= max-min;
    cntt <= cntt + 1'b1;
    if(cntt == 1'b1) begin
        max <= 0;
        min <= 8'b11111111;    
    end
    if(adc_data > max)
        max <= adc_data;
    if(adc_data < min)
        min <= adc_data;
    mean <= (max&min)+((max^min)>>1);
end

// 求频率
// 选取最大值和最小值的平均值，判断每两个平均值之间有多少采样点，结合时钟频率即可计算频率
// 该方法理论可行，实际应用时由于噪声，有很大误差
always @ (posedge ila_clk) begin
    cnt <= cnt + 1'b1;
    if(adc_data == mean) begin
        idx <= cnt;
    end
    if(adc_data == mean & cnt - idx > 0) begin
        freq <= cnt - idx;
    end
end

// 储存和读取波形的RAM，宽度8，深度4096
// Memory Type: Simple Dual Port RAM
blk_mem_gen_0 blk_mem_gen_0 (
 .clka(ila_clk), // input clka
 .addra(adc_addr), // input [8 : 0] addra
 .dina(adc_data),
 .wea(write_en),
 .addrb(rom_addr),
 .clkb(pclk),
 .doutb(q) // output [7 : 0] doutb
);

timing_gen_xy timing_gen_xy_m0(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);

ila_0 ila_m0(
    .clk(ila_clk),
    .probe0(adc_data),
    .probe1(mean),
    .probe2(cntt),
    .probe3(idx),
    .probe4(freq),
    .probe5(fft_ans),
    .probe6(min)
);

FFT fft(
    .clk_50(ila_clk),
    .fftdata(q),
    .fft_ans(fft_ans)
);

endmodule