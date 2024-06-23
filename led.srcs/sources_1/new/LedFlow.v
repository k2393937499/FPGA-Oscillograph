`timescale 1ns / 1ps
module top(
    input sys_clk,
    input [4:0]btns,
    
    output TMDS_clk_n,
    output TMDS_clk_p,
    output [2:0]TMDS_data_n,
    output [2:0]TMDS_data_p,
    
    output da_clk,
    output [7:0] dadata,
    output ad_clk,
    input [7:0] addata
);

// 背景参数
wire      video_clk;
wire      video_clk_5x;
wire      video_hs;
wire      video_vs;
wire      video_de;
wire[7:0] video_r;
wire[7:0] video_g;
wire[7:0] video_b;

// 网格参数
wire      grid_hs;
wire      grid_vs;
wire      grid_de;
wire[7:0] grid_r;
wire[7:0] grid_g;
wire[7:0] grid_b;

// 波形参数
wire      wave0_hs;
wire      wave0_vs;
wire      wave0_de;
wire[7:0] wave0_r;
wire[7:0] wave0_g;
wire[7:0] wave0_b;

// 汉字参数1
wire      osd_hs;
wire      osd_vs;
wire      osd_de;
wire[7:0] osd_r;
wire[7:0] osd_g;
wire[7:0] osd_b;

// 汉字参数2
wire      osd1_hs;
wire      osd1_vs;
wire      osd1_de;
wire[7:0] osd1_r;
wire[7:0] osd1_g;
wire[7:0] osd1_b;

// 峰峰值参数
wire       osd2_hs;
wire       osd2_vs;
wire       osd2_de;
wire[7:0]  osd2_r;
wire[7:0]  osd2_g;
wire[7:0]  osd2_b;

// 频率参数
wire       osd3_hs;
wire       osd3_vs;
wire       osd3_de;
wire[7:0]  osd3_r;
wire[7:0]  osd3_g;
wire[7:0]  osd3_b;

// 峰峰值
reg[3:0]   hour;
reg[3:0]   minute;
reg[3:0]   second;

// 频率
reg[3:0]   hour1;
reg[3:0]   minute1;
reg[3:0]   second1;

// 峰峰值、频率计算值
wire[7:0]  v;
reg[11:0]  v_out;
wire[11:0] f;
wire[31:0] f_temp;
wire[11:0] f_out;

// ADDA读取参数
reg[10:0]  adc_addr;
reg[7:0]   adc_data;
reg [8:0] rom_addr;
wire [7:0] rom_data;
wire clk_25;
wire clk_50;

// 时钟设置
// 系统时钟      125M
// video_clk    25.175M
// video_clk_5x 5*25.175M
// clk_25       25M
// clk_50       50M
clk_wiz_0 video_clock_m0
(
    .clk_in1 (sys_clk),
    .clk_out1(video_clk),
    .clk_out2(video_clk_5x),
    .clk_out3(clk_50),
    .clk_out4(clk_25),
    .reset(1'b0),
    .locked()
 );

// RGB信号转HDMI信号
rgb2dvi_1 rgb2dvi_m0 (
	.TMDS_Clk_p (TMDS_clk_p),
	.TMDS_Clk_n (TMDS_clk_n),
	.TMDS_Data_p(TMDS_data_p),
	.TMDS_Data_n(TMDS_data_n),
	.aRst_n(1'b1), 
	
	.vid_pData({osd3_r,osd3_g,osd3_b}),
	.vid_pVDE  (osd3_de),
	.vid_pHSync(osd3_hs),
	.vid_pVSync(osd3_vs),
	.PixelClk  (video_clk),
	.SerialClk (video_clk_5x)
); 

// 背景显示
color_bar hdmi_color_bar(
	.clk(video_clk),
	.rst(1'b0),
	.hs(video_hs),
	.vs(video_vs),
	.de(video_de),
	.rgb_r(video_r),
	.rgb_g(video_g),
	.rgb_b(video_b)
);

// 在背景上叠加网格
grid_display  grid_display_m0(
	.rst_n (1'b1),
	.pclk  (video_clk),
	.i_hs  (video_hs),
	.i_vs  (video_vs),
	.i_de  (video_de),
	.i_data({video_r,video_g,video_b}),
	.o_hs  (grid_hs),
	.o_vs  (grid_vs),
	.o_de  (grid_de),
	.o_data({grid_r,grid_g,grid_b})
); 

// 叠加波形
// 按钮参数用于控制不同功能
wav_display wav_display_m0(
	.rst_n     (1'b1),
	.btn_1     (btns[0]),
	.btn_2     (btns[1]),
	.btn_3     (btns[2]),
	.btn_4     (btns[3]),
	.pclk      (video_clk),
	.ila_clk   (clk_50),
	.wave_color(24'hff0000),
	.i_hs      (grid_hs),
	.i_vs      (grid_vs),
	.i_de      (grid_de),
	.i_data    ({grid_r,grid_g,grid_b}),
	.o_hs      (wave0_hs),
	.o_vs      (wave0_vs),
	.o_de      (wave0_de),
	.o_data    ({wave0_r,wave0_g,wave0_b}),
	.adc_addr  (adc_addr),
    .adc_data  (adc_data),
    .feng      (v),
    .freq      (f)
);

// 叠加汉字
osd_display  osd_display_m0(
	.rst_n (1'b1),
	.pclk  (video_clk),
	.i_hs  (wave0_hs),
	.i_vs  (wave0_vs),
	.i_de  (wave0_de),
	.i_data({wave0_r,wave0_g,wave0_b}),
	.o_hs  (osd_hs),
	.o_vs  (osd_vs),
	.o_de  (osd_de),
	.o_data({osd_r,osd_g,osd_b})
);

osd_display_freq  osd_display_freq(
	.rst_n (1'b1),
	.pclk  (video_clk),
	.i_hs  (osd_hs),
	.i_vs  (osd_vs),
	.i_de  (osd_de),
	.i_data({osd_r,osd_g,osd_b}),
	.o_hs  (osd1_hs),
	.o_vs  (osd1_vs),
	.o_de  (osd1_de),
	.o_data({osd1_r,osd1_g,osd1_b})
);

// 叠加数字
rtc_osd  rtc_osd(
	.rst_n    (1'b1),
	.pclk     (video_clk),
	.rtc_data (v_out),
	.i_hs     (osd1_hs),
	.i_vs     (osd1_vs),
	.i_de     (osd1_de),
	.i_data   ({osd1_r,osd1_g,osd1_b}  ),
	.o_hs     (osd2_hs),
	.o_vs     (osd2_vs),
	.o_de     (osd2_de),
	.o_data   ({osd2_r,osd2_g,osd2_b})
);

rtc_osd1  rtc_osd1(
	.rst_n    (1'b1),
	.pclk     (video_clk),
	.rtc_data (f_out),
	.i_hs     (osd2_hs),
	.i_vs     (osd2_vs),
	.i_de     (osd2_de),
	.i_data   ({osd2_r,osd2_g,osd2_b}),
	.o_hs     (osd3_hs),
	.o_vs     (osd3_vs),
	.o_de     (osd3_de),
	.o_data   ({osd3_r,osd3_g,osd3_b})
);

// 未例化的代码为ADDA部分
assign dadata = rom_data;
assign da_clk = clk_50;
assign ad_clk = clk_50;

always @(posedge  clk_50) begin
    rom_addr <= rom_addr + 1'b1;
    adc_addr <= adc_addr + 1'b1;
end
  
always @(negedge clk_25) begin
    adc_data <= addata;
end

reg [31:0] f_temp_temp;
reg [3:0] cnt;
always @(posedge sys_clk)begin
    cnt <= cnt + 1'b1;
    if(cnt == 0) begin
    if(f_temp > 2'b11)
        f_temp_temp <= f_temp;
    v_out <= v * 10 / 255;
    end
    if(v_out == 12'b000000001010)
        v_out <= 12'b000000010000;
end

// 整数除法器，用于计算频率
divide divide(
    .a({24'b0,f}),
    .b({24'b0,12'b000000000010}),
    .enable(1'b1),
    .yshang(f_temp),
    .yyushu(ss),
    .done(dd)
);

// BCD码生成模块，用于显示频率
binary2bcd binary2bcd(
    .binary_in(f_temp_temp[11:0]),
    .bcd_out(f_out)
);

// 储存波形coe文件的ROM
blk_mem_gen_1 blk_mem_gen_1(
    .clka(clk_50),
    .addra(rom_addr),
    .douta(rom_data)
);

ila_1 ila_m1(
    .clk(sys_clk),
    .probe0(v),
    .probe1(f),
    .probe2(f_temp),
    .probe3(f_temp_temp),
    .probe4(f_out)
);

endmodule
