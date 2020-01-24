`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sara Morimoto
// Create Date: 05/22/2018 06:23:45 PM
// Module Name: EksBox
// Description: 
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////
module EksBox(CLK, ARST_L, SCLK, SDATA, HSYNC, VSYNC, RED, GREEN, BLUE, SCLK_A, SS, INT1, MISO, MOSI, MISO_PMOD, MOSI_PMOD, SS_PMOD, SCLK_A_PMOD, CLKOUT_DEBUG, SWDB_INT_PMOD);
input CLK, ARST_L, SCLK, SDATA, INT1, MISO;
output HSYNC, VSYNC, RED, GREEN, BLUE, SS, SCLK_A, MOSI;
output MOSI_PMOD, MISO_PMOD, SS_PMOD, SCLK_A_PMOD;
output CLKOUT_DEBUG; // debug
output SWDB_INT_PMOD;//debug
wire [3:0] RED;
wire [3:0] GREEN;
wire [3:0] BLUE;
reg [3:0] HEX1;
reg [3:0] HEX0;
wire [3:0] HEX1_i;
wire [3:0] HEX0_i;
wire [7:0] HEXOUT;
wire SYNC_SDATA;
wire SYNC_SCLK;
wire [9:0] HCOORD;
wire [9:0] VCOORD;
assign  HEXOUT = {HEX1_i[3:0], HEX0_i[3:0]};
wire CLKOUT;
wire KEYUP;
wire [11:0] CSEL;
wire CLKOUT1M;
wire SCLK_A;
//wire [7:0] XDATA_OUTPUT;
//wire [7:0] YDATA_OUTPUT;
wire [1:0] SysReg_tb;
wire [3:0] ConfigReg_tb;
wire [23:0] SPIReg_tb;

wire [2:0] RunReg_tb;
wire [23:0] DIN;
wire [23:0] DOUT;

wire CLKOUT2M;
wire MOSI_PMOD;
wire MISO_PMOD;
wire SS_PMOD;
wire SCLK_A_PMOD;
wire CLKOUT_DEBUG;
wire ARST_L_PMOD;
wire SWDB_INT_PMOD;

wire [7:0] XDATA_MISO;
wire [7:0] YDATA_MISO;
assign MOSI_PMOD = MOSI;
assign MISO_PMOD = MISO;
assign SS_PMOD = SS;
assign SCLK_A_PMOD = SCLK_A;
assign CLKOUT_DEBUG = CLKOUT2M;
assign ARST_L_PMOD = ARST_L;
assign SWDB_INT_PMOD = SWDB_INT;

//wire hi_i;
//assign hi_i = 1'b1;

Clk25Mhz Clk25Mhz(.CLKIN(CLK), .ACLR(ARST_L), .CLKOUT(CLKOUT));//OUTPUT IS 25MHZ CLOCK (div by4)

Sync2 Sync2CLK(.CLK(CLK), .ASYNC(SCLK), .ACLR(ARST_L), .SYNC(SYNC_SCLK)); //SYNC KEYBOARD CLOCK WITH SYSTEM CLOCK 

Sync2 SyncSDATA(.CLK(CLK), .ASYNC(SDATA), .ACLR(ARST_L), .SYNC(SYNC_SDATA));//SYNC KEYBOARD DATA WITH SYSTEM 

KBDecoder KBDecoder(.CLK(SYNC_SCLK), .SDATA(SYNC_SDATA), .ARST(ARST_L), .HEX1(HEX1_i), .HEX0(HEX0_i), .KEYUP(KEYUP)); //DECODE KEYBOARD INPUTS

SwitchDB SwitchDB(.SW(KEYUP), .CLK(CLKOUT), .ACLR_L(ARST_L), .SWDB(SWDB)); //SENDS KEYBOARD STROBE

VGAController VGAController(.CLK(CLKOUT), .KBCODE(HEXOUT), .HCOORD(HCOORD), .VCOORD(VCOORD), .KBSTROBE(SWDB), .ARST(ARST_L), .CSEL(CSEL), .XDATA_MISO(XDATA_MISO), .YDATA_MISO(YDATA_MISO));//VGA

VGAEncoder VGAEncoder(.CLK(CLKOUT), .CSEL(CSEL), .ARST(ARST_L), .HSYNC(HSYNC), .VSYNC(VSYNC), .RED(RED), .GREEN(GREEN), .BLUE(BLUE), .HCOORD(HCOORD), .VCOORD(VCOORD));

ClkDiv100 ClkDiv100(.CLKIN(CLK), .ACLR_L(ARST_L), .CLKOUT(CLKOUT1M));//OUTPUT IS 1MHZ CLOCK (div by 100)

SwitchDB SwitchDB_INT (.SW(INT1), .CLK(CLKOUT1M), .ACLR_L(ARST_L), .SWDB(SWDB_INT));//SENDS INT1 STROBE 

SPIControl SPIControl (.CLK(CLKOUT2M), .ARST_L(ARST_L), .DIN(DIN), .DOUT(DOUT), .SEND(SEND), .DONE(DONE), .INT1(SWDB_INT));

SPIHandler SPIHandler (.DIN(DIN), .DOUT(DOUT), .CLK(CLKOUT2M), .ARST_L(ARST_L), .SEND(SEND), .DONE(DONE), .MOSI(MOSI), .MISO(MISO), .SCLK_A(SCLK_A), .SS(SS), .XDATA_MISO(XDATA_MISO), .YDATA_MISO(YDATA_MISO));

CLK2Mhz Clk2Mhz (.CLK(CLK), .ARST_L(ARST_L), .CLKOUT(CLKOUT2M));
//MAKE INTERNAL WIRES
//MAKE HEXOUT A BUS WITH CONCATINATED ASSIGN 


endmodule
