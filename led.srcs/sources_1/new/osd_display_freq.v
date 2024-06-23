`timescale 1ns / 1ps
module osd_display_freq(
	input        rst_n,  //复位信号
	input        pclk,	//像素时钟
	input        i_hs, 	//行同步输入信号   
	input        i_vs,   //场同步输入信号
	input        i_de,	//图像有效输入信号
	input[23:0]  i_data, //图像数据输入信号
	output       o_hs,   //行同步输出信号    
	output       o_vs,   //场同步输出信号 
	output       o_de,   //图像有效输出信号 
	output[23:0] o_data  //图像数据输出信号
);
parameter OSD_WIDTH   =  12'd192;	//设置OSD的宽度，可根据字符生成软件设置
parameter OSD_HEGIHT  =  12'd32;	//设置OSD的高度，可根据字符生成软件设置

wire[11:0] 		pos_x;		//X坐标
wire[11:0] 		pos_y;		//Y坐标
wire       		pos_hs;
wire       		pos_vs;
wire       		pos_de;
wire[23:0] 		pos_data;
reg	[23:0]  	v_data;
reg	[11:0]  	osd_x;
reg	[11:0]  	osd_y;
reg	[15:0]  	osd_ram_addr;
wire[7:0]  		q;
reg        		region_active;
reg        		region_active_d0;
reg        		region_active_d1;
reg        		region_active_d2;

reg        		pos_vs_d0;
reg        		pos_vs_d1;

assign o_data 	= v_data;
assign o_hs 	= pos_hs;
assign o_vs 	= pos_vs;
assign o_de 	= pos_de;

always@(posedge pclk)
begin
	if(pos_y >= 12'd48 && pos_y <= 12'd48 + OSD_HEGIHT - 12'd1 && pos_x >= 12'd9 && pos_x  <= 12'd9 + OSD_WIDTH - 12'd1)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

always@(posedge pclk)
begin
	region_active_d0 <= region_active;
	region_active_d1 <= region_active_d0;
	region_active_d2 <= region_active_d1;
end

always@(posedge pclk)
begin
	pos_vs_d0 <= pos_vs;
	pos_vs_d1 <= pos_vs_d0;
end

//产生OSD的计数器
always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		osd_x <= osd_x + 12'd1;
	else
		osd_x <= 12'd0;
end
//产生ROM的读地址，在region_active有效时，地址加1
always@(posedge pclk)
begin
	if(pos_vs_d1 == 1'b1 && pos_vs_d0 == 1'b0)
		osd_ram_addr <= 16'd0;
	else if(region_active == 1'b1)
		osd_ram_addr <= osd_ram_addr + 16'd1;
end


always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		if(q[osd_x[2:0]] == 1'b1)  //检查bit位是否是1，如果是1，将此像素设为白色
			v_data <= 24'hffffff;
		else
			v_data <= pos_data;	   //否则保持原来的值
	else
		v_data <= pos_data;
end

blk_mem_gen_2 blk_mem_gen_2(
	.clka                       (pclk                    ),      
	.addra                      (osd_ram_addr[15:3]      ), 	//生成的字符一个点为1bit，由于数据宽度为8bit，因此8个周期检查一次数据
	.douta                      (q                       )  
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
endmodule
