`timescale 1ns / 1ps
module FFT(
input clk_50, //fpga clock
input [7:0] fftdata,
output reg [7:0]fft_ans
 );

reg data_finish_flag;
reg rst_n;

wire              fft_s_config_tready;

reg signed [31:0] fft_s_data_tdata;
reg               fft_s_data_tvalid;
wire              fft_s_data_tready;
reg               fft_s_data_tlast;

wire signed [47:0] fft_m_data_tdata;
wire signed [7:0]  fft_m_data_tuser;
wire signed [0:0]  fft_m_data_tvalid;
reg                fft_m_data_tready;
wire               fft_m_data_tlast;

wire          fft_event_frame_started;
wire          fft_event_tlast_unexpected;
wire          fft_event_tlast_missing;
wire          fft_event_status_channel_halt;
wire          fft_event_data_in_channel_halt;
wire          fft_event_data_out_channel_halt;

reg [7:0]     count;

reg signed [23:0] fft_i_out;
reg signed [23:0] fft_q_out;
reg [63:0] fft_abs;
reg root_tvalid; 
reg [47:0] root_tdata;
wire fft_out_tvalid;
wire [24:0] fft_out_tdata;

initial begin
    rst_n = 1'b0;
    fft_m_data_tready = 1'b1;
    count = 8'd0;
    root_tvalid <= 1'b1;
end

always @ (posedge clk_50 or negedge rst_n) begin
    if(!rst_n) begin
        fft_s_data_tvalid <= 1'b0;
        fft_s_data_tdata  <= 32'd0;
        fft_s_data_tlast  <= 1'b0;
        data_finish_flag  <= 1'b0;
        count = 8'd0;
        rst_n = 1'b1;
    end
    else if (fft_s_data_tready) begin 
        if(count == 8'd127) begin
            fft_s_data_tvalid <= 1'b1;
            fft_s_data_tlast  <= 1'b1;
            fft_s_data_tdata  <= {8'd0,fftdata,16'd0};
            //count <= 8'd0;
            data_finish_flag <= 1'b1;
        end
        else begin
            fft_s_data_tvalid <= 1'b1;
            fft_s_data_tlast  <= 1'b0;
            fft_s_data_tdata  <= {8'd0,fftdata,16'd0};   
            count <= count + 1'b1;
        end
    end
    else begin
        fft_s_data_tvalid <= 1'b0;
        fft_s_data_tlast  <= 1'b0;
        fft_s_data_tdata <= fft_s_data_tdata;
    end
end

always @ (posedge clk_50) begin
    if(fft_m_data_tvalid) begin
        fft_i_out <= fft_m_data_tdata[23:0];
        fft_q_out <= fft_m_data_tdata[47:24];
    end
end

always @ (posedge clk_50) begin
    root_tdata <=  fft_i_out * fft_i_out+ fft_q_out * fft_q_out;
    fft_ans <=  fft_out_tdata[14:7];
end

//fft ip核例化
xfft_0 u_fft(
    .aclk(clk_50),                                                // 时钟信号（input）
    .aresetn(rst_n),                                           // 复位信号，低有效（input）
    .s_axis_config_tdata(8'd1),                                // ip核设置参数内容，为1时做FFT运算，为0时做IFFT运算（input）
    .s_axis_config_tvalid(1'b1),                               // ip核配置输入有效，可直接设置为1（input）
    .s_axis_config_tready(fft_s_config_tready),                // output wire s_axis_config_tready
    //作为接收时域数据时是从设备
    .s_axis_data_tdata(fft_s_data_tdata),                      // 把时域信号往FFT IP核传输的数据通道,[31:16]为虚部，[15:0]为实部（input，主->从）
    .s_axis_data_tvalid(fft_s_data_tvalid),                    // 表示主设备正在驱动一个有效的传输（input，主->从）
    .s_axis_data_tready(fft_s_data_tready),                    // 表示从设备已经准备好接收一次数据传输（output，从->主），当tvalid和tready同时为高时，启动数据传输
    .s_axis_data_tlast(fft_s_data_tlast),                      // 主设备向从设备发送传输结束信号（input，主->从，拉高为结束）
    //作为发送频谱数据时是主设备
    .m_axis_data_tdata(fft_m_data_tdata),                      // FFT输出的频谱数据，[47:24]对应的是虚部数据，[23:0]对应的是实部数据(output，主->从)。
    .m_axis_data_tuser(fft_m_data_tuser),                      // 输出频谱的索引(output，主->从)，该值*fs/N即为对应频点；
    .m_axis_data_tvalid(fft_m_data_tvalid),                    // 表示主设备正在驱动一个有效的传输（output，主->从）
    .m_axis_data_tready(fft_m_data_tready),                    // 表示从设备已经准备好接收一次数据传输（input，从->主），当tvalid和tready同时为高时，启动数据传输
    .m_axis_data_tlast(fft_m_data_tlast),                      // 主设备向从设备发送传输结束信号（output，主->从，拉高为结束）
    //其他输出数据
    .event_frame_started(fft_event_frame_started),                  // output wire event_frame_started
    .event_tlast_unexpected(fft_event_tlast_unexpected),            // output wire event_tlast_unexpected
    .event_tlast_missing(fft_event_tlast_missing),                  // output wire event_tlast_missing
    .event_status_channel_halt(fft_event_status_channel_halt),      // output wire event_status_channel_halt
    .event_data_in_channel_halt(fft_event_data_in_channel_halt),    // output wire event_data_in_channel_halt
    .event_data_out_channel_halt(fft_event_data_out_channel_halt)   // output wire event_data_out_channel_halt
  );
  
cordic_0 cordic_0(                         //取模器
    .aclk(clk_50),
    .s_axis_cartesian_tdata(root_tdata),
    .s_axis_cartesian_tvalid(root_tvalid),
    .m_axis_dout_tvalid(fft_out_tvalid),
    .m_axis_dout_tdata(fft_out_tdata)
 );
  
endmodule
