module rtc_osd(
	input                       rst_n,  	
	input                       pclk,		
	input [11:0]				rtc_data,	
	input                       i_hs, 		   
	input                       i_vs,   	
	input                       i_de,		
	input[23:0]                 i_data, 	
	output                      o_hs,   	
	output                      o_vs,   	 
	output                      o_de,   	
	output[23:0]                o_data  	
);
localparam OSD_X_START 	= 	12'd105;	
localparam OSD_Y_START 	= 	12'd9  ;	
localparam OSD_GAP 		= 	12'd16 ;	
localparam OSD_WIDTH   	=  	12'd16 ;	
localparam OSD_HEGIHT  	=  	12'd32 ;	

wire [11:0] 		pos_x;		
wire [11:0] 		pos_y;		
wire        		pos_hs;
wire        		pos_vs;
wire        		pos_de;
wire [23:0] 		pos_data;
reg	 [23:0]  		v_data;
     
reg	 [11:0]  		osd_x	[7:0] ;
reg	 [11:0]  		osd_y;
reg	 [15:0]  		osd_ram_addr	[7:0] ;
reg  [7:0]      	region_active;
reg  [7:0]      	region_active_d0;

reg        			pos_vs_d0;
reg        			pos_vs_d1;
	
reg	 [3:0]			char_addr_sel ;		
reg	 [5:0]			char_addr ;			
wire [7:0]			char_data ;			

assign o_data 	= v_data;
assign o_hs 	= pos_hs;
assign o_vs 	= pos_vs;
assign o_de 	= pos_de;

always@(posedge pclk)
	begin
		pos_vs_d0 <= pos_vs;
		pos_vs_d1 <= pos_vs_d0;
	end

genvar i ;
generate
	for (i = 0 ;i < 3 ; i = i + 1)
	begin : osd_region
		
		always@(posedge pclk)
		begin
			if(pos_y >= OSD_Y_START && pos_y <= OSD_Y_START + OSD_HEGIHT - 12'd1 
				&& pos_x >= OSD_X_START + OSD_WIDTH*i && pos_x  <= OSD_X_START + OSD_WIDTH*(i+1) - 12'd1)
				region_active[i] <= 1'b1;
			else
				region_active[i] <= 1'b0;
		end
		
		always@(posedge pclk)
		begin
			region_active_d0[i] <= region_active[i];
		end	
		
		
		
		always@(posedge pclk)
		begin
			if(region_active_d0[i] == 1'b1)
				osd_x[i] <= osd_x[i] + 12'd1;
			else
				osd_x[i] <= 12'd0;
		end
		
		always@(posedge pclk)
		begin
			if(pos_vs_d1 == 1'b1 && pos_vs_d0 == 1'b0)
				osd_ram_addr[i] <= 16'd0;
			else if(region_active[i] == 1'b1)
				osd_ram_addr[i] <= osd_ram_addr[i] + 16'd1;
		end	
		
	end		
endgenerate

always@(posedge pclk)
begin
	case(region_active_d0)
		8'b0000_0001 : begin
						if(char_data[osd_x[0][2:0]] == 1'b1) 
							v_data <= 24'hffffff;
						else
							v_data <= pos_data;	   
					   end
		8'b0000_0010 : begin
						if(char_data[osd_x[1][2:0]] == 1'b1)  
							v_data <= 24'hffffff;
						else
							v_data <= pos_data;	   
					   end
		8'b0000_0100 : begin
						if(char_data[osd_x[2][2:0]] == 1'b1)  
							v_data <= 24'hffffff;
						else
							v_data <= pos_data;	   
					   end
		default	: v_data <= pos_data;
	endcase
end

// 选择第几个数字
always @(*)
begin
	case(region_active)
		8'b0000_0001 : char_addr_sel <= rtc_data[11:8] ;
		8'b0000_0010 : char_addr_sel <= rtc_data[7:4] ;
		8'b0000_0100 : char_addr_sel <= rtc_data[3:0] ;
		default :	char_addr_sel <= 6'd0 ;
	endcase
end


always @(*)
begin
	case(region_active)
		8'b0000_0001 : char_addr <= osd_ram_addr[0][15:3] ;
		8'b0000_0010 : char_addr <= osd_ram_addr[1][15:3] ;
		8'b0000_0100 : char_addr <= osd_ram_addr[2][15:3] ;
		default :	   char_addr <= 6'd0 ;
	endcase
end

char_repo  char_repo_inst(
	.clk			(pclk),
	.char_addr_sel	(char_addr_sel),
	.char_addr		(char_addr),
	.char_data      (char_data)

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