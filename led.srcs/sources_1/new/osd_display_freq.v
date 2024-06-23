`timescale 1ns / 1ps
module osd_display_freq(
	input        rst_n,  //��λ�ź�
	input        pclk,	//����ʱ��
	input        i_hs, 	//��ͬ�������ź�   
	input        i_vs,   //��ͬ�������ź�
	input        i_de,	//ͼ����Ч�����ź�
	input[23:0]  i_data, //ͼ�����������ź�
	output       o_hs,   //��ͬ������ź�    
	output       o_vs,   //��ͬ������ź� 
	output       o_de,   //ͼ����Ч����ź� 
	output[23:0] o_data  //ͼ����������ź�
);
parameter OSD_WIDTH   =  12'd192;	//����OSD�Ŀ�ȣ��ɸ����ַ������������
parameter OSD_HEGIHT  =  12'd32;	//����OSD�ĸ߶ȣ��ɸ����ַ������������

wire[11:0] 		pos_x;		//X����
wire[11:0] 		pos_y;		//Y����
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

//����OSD�ļ�����
always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		osd_x <= osd_x + 12'd1;
	else
		osd_x <= 12'd0;
end
//����ROM�Ķ���ַ����region_active��Чʱ����ַ��1
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
		if(q[osd_x[2:0]] == 1'b1)  //���bitλ�Ƿ���1�������1������������Ϊ��ɫ
			v_data <= 24'hffffff;
		else
			v_data <= pos_data;	   //���򱣳�ԭ����ֵ
	else
		v_data <= pos_data;
end

blk_mem_gen_2 blk_mem_gen_2(
	.clka                       (pclk                    ),      
	.addra                      (osd_ram_addr[15:3]      ), 	//���ɵ��ַ�һ����Ϊ1bit���������ݿ��Ϊ8bit�����8�����ڼ��һ������
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
