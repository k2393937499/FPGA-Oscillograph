set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sys_clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sys_clk }];

## HDMI Tx
set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33 } [get_ports { TMDS_clk_p }]; #IO_L11P_T1_SRCC_35 Sch=hdmi_tx_clk_p
set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33 } [get_ports { TMDS_clk_n }]; #IO_L11N_T1_SRCC_35 Sch=hdmi_tx_clk_n
set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33 } [get_ports { TMDS_data_p[0] }]; #IO_L12P_T1_MRCC_35 Sch=hdmi_tx_d_p[0]
set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33 } [get_ports { TMDS_data_n[0] }]; #IO_L12N_T1_MRCC_35 Sch=hdmi_tx_d_n[0]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33 } [get_ports { TMDS_data_p[1] }]; #IO_L10P_T1_AD11P_35 Sch=hdmi_tx_d_p[1]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33 } [get_ports { TMDS_data_n[1] }]; #IO_L10N_T1_AD11N_35 Sch=hdmi_tx_d_n[1]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33 } [get_ports { TMDS_data_p[2] }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=hdmi_tx_d_p[2]
set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33 } [get_ports { TMDS_data_n[2] }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=hdmi_tx_d_n[2]

# AD 数据输入引脚（连接到 PMODA）
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports {addata[0]}];
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports {addata[1]}];
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {addata[2]}];
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {addata[3]}];
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {addata[4]}];
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {addata[5]}];
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {addata[6]}];
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {addata[7]}];

# DA 数据输出引脚（连接到 PMODB）
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {dadata[0]}];
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {dadata[1]}];
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {dadata[2]}];
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {dadata[3]}];
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {dadata[4]}];
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {dadata[5]}];
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {dadata[6]}];
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {dadata[7]}];

# AD 时钟引脚
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports ad_clk];

# DA 时钟引脚
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33} [get_ports da_clk];

# 按钮引脚 用于控制量程
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {btns[0]}];
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {btns[1]}];
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {btns[2]}];
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {btns[3]}];