`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Western Washington University
// Engineer: Sara Morimoto & Micah Hollen
// Create Date: 05/26/2018 02:46:25 PM 
// Module Name: SPIControl
// Description: 
//////////////////////////////////////////////////////////////////////////////////
///NOTE TO SELF: SCLK IS NOW SCLK_A!!
//RESET IS ARST_L

module SPIControl(CLK, ARST_L, INT1, DIN, DOUT, SEND, DONE);
input CLK, ARST_L, DONE, INT1;
input [23:0] DOUT;
output [23:0] DIN;
output SEND;
//input [7:0] XDATA_MISO;
//input [7:0] YDATA_MISO;
//wire [7:0] XDATA_MISO;
//wire [7:0] YDATA_MISO;

reg SEND;
reg [23:0] DIN;
reg StateSel;
wire config_roll;
wire config_EN;
wire int_i;
assign int_i = (ConfigReg == DONE6) ? INT1 : 1'b0;

//SYSTEM CONTROL STATE MACHINE
//STATES AS PARAMETERS
parameter [1:0] IDLE_SYS = 2'b00;
parameter [1:0] CONFIG = 2'b01;
parameter [1:0] RUN = 2'b10;

//Present State and Next State
reg [1:0] SysReg;
reg [1:0] SysNext;
//STATE MEMORY//
always@(posedge CLK or negedge ARST_L)
    begin
        if (~ARST_L)
            SysReg <= IDLE_SYS;
        else    
            SysReg <= SysNext;
    end
//NEXT STATE LOGIC//
always@(SysReg or ConfigReg)
begin
case(SysReg)
IDLE_SYS:
    SysNext <= CONFIG;
CONFIG:
if (ConfigReg == DONE6)
    SysNext <= RUN;
RUN:
    SysNext <= RUN;    
endcase
end




//CONFIGURE STATE MACHINE//
//STATE MACHINE NAMES AS PARAMETER//
parameter [3:0] IDLE_CONFIG = 4'b0000;
parameter [3:0] LOAD1 = 1;
parameter [3:0] WRITE1 = 2;
parameter [3:0] LOAD2 = 3;
parameter [3:0] WRITE2 = 4;
parameter [3:0] LOAD3 = 5;
parameter [3:0] WRITE3 = 6;
parameter [3:0] LOAD4 = 7;
parameter [3:0] WRITE4 = 8;
parameter [3:0] LOAD5 =9;
parameter [3:0] WRITE5 = 10;
parameter [3:0] DONE6 = 11;


//PRESENT STATE AND NEXT STATE//
reg [3:0] ConfigReg;
reg [3:0] ConfigNext;

//TRANSITIONS FOR CONFIG
//assign config_trans = (((ConfigReg == IDLE_CONFIG) ||  config_roll)) ? 1'b1:1'b0;
assign config_EN = (SysReg == CONFIG) ? 1'b1 : 1'b0;

//STATE MEMORY//
always@(posedge CLK or negedge ARST_L)
    begin
        if (~ARST_L)
            ConfigReg <= IDLE_CONFIG;
        else 
            ConfigReg <= ConfigNext;
    end
//NEXT STATE LOGIC//
always@(ConfigReg or config_EN or DONE)
begin   
    case(ConfigReg)
    (IDLE_CONFIG):
    if (config_EN == 1'b1)
        ConfigNext <= LOAD1;//ONE CLOCK EDGE
    else
        ConfigNext <= IDLE_CONFIG;
        
    (LOAD1):       
        ConfigNext <= WRITE1;
        
    (WRITE1):
        if (DONE == 1'b1)
            ConfigNext <= LOAD2;
        else 
            ConfigNext <= WRITE1;
            
    (LOAD2):
        ConfigNext <= WRITE2;
        
    (WRITE2):
        if (DONE == 1'b1)
            ConfigNext <= LOAD3;
        else
            ConfigNext <= WRITE2;
            
    (LOAD3):
        ConfigNext <= WRITE3;

    (WRITE3):
        if (DONE == 1'b1)
            ConfigNext <= LOAD4;
        else ConfigNext <= WRITE3;
        
    (LOAD4): 
        ConfigNext<= WRITE4;

    (WRITE4):
        if (DONE == 1'b1)
            ConfigNext <= LOAD5;
        else ConfigNext <= WRITE4;
        
    (LOAD5):
        ConfigNext <= WRITE5;

    (WRITE5):
        if (DONE == 1'b1)
            ConfigNext <= DONE6;
        else
            ConfigNext <= WRITE5;
   (DONE6):
   begin
            ConfigNext <= DONE6;
            StateSel <= 1'b1;
   end
endcase
end
//CONFIG OUTPUT LOGIC//


//DIN AND SEND
always@(posedge CLK or negedge ARST_L)
if (~ARST_L)
begin
    DIN <= 24'h000000;
    SEND <= 1'b0;
end
else if (ConfigReg == LOAD1)
begin
    DIN <= 24'h0A2730;
    SEND <= 1'b1;
end
    
else if (ConfigReg == LOAD2)
begin
    DIN <= 24'h0A2802;
    SEND <= 1'b1;
end

else if (ConfigReg == LOAD3)
begin
    DIN <= 24'h0A2A01;
    SEND <= 1'b1;  
end

else if (ConfigReg == LOAD4)
begin
    DIN <= 24'h0A2C13;
    SEND <= 1'b1;
end

else if (ConfigReg == LOAD5)
begin
    DIN <= 24'h0A2D02;
    SEND <= 1'b1;
end

//else if (ConfigReg == DONE6)
//    StateSel <= 1'b1;

else if (RunReg == LOADX)
begin
    DIN <= 24'h0B0800;
    SEND <= 1'b1;
end

else if (RunReg == LOADY)
begin 
    DIN <= 24'h0B0900;
    SEND <= 1'b1;
end

else
begin
    SEND <= 1'b0;
    StateSel <= 1'b0;
end
    




//RUN STATE MACHINE//

//reg [4:0] count_RUN;

//assign roll_RUN = (count_RUN == 23) ? 1'b1 : 1'b0;
//always@(posedge CLK or negedge ARST_L)
//begin
//    if (~ARST_L)
//        count_RUN <= 5'b00000;
//    else if (roll_RUN == 1'b1)
//        count_RUN <= 5'b00000;
//    else if ((RunReg == READX) || (RunReg == READY))
//        count_RUN <= count_RUN +1;
//    else
//        count_RUN <= 5'b00000;
//end

//STATE MACHINE NAMES AS PARAMETERS//
parameter [2:0] IDLE_RUN = 3'b000;
parameter [2:0] LOADX = 3'b001;
parameter [2:0] READX = 3'b010;
parameter [2:0] LOADY = 3'b011;
parameter [2:0] READY = 3'b100;
parameter [2:0] RESET = 3'b101;

//PRESENT STATE AND NEXT STATE//
reg [2:0] RunReg;
reg [2:0] RunNext;

//RUN STATE MEMORY//
always@(posedge CLK or negedge ARST_L)
begin
    if (~ARST_L)
        RunReg <= RESET;
    else if (ConfigReg == DONE6)   
        RunReg <= RunNext;
    else;
end

//RUN NEXT STATE LOGIC//
always@(RunReg or DONE or int_i)
begin
case(RunReg)
RESET:
    RunNext <= LOADX;
IDLE_RUN:
    if (int_i == 1'b1) 
        RunNext <= LOADX;
    else
        RunNext <= IDLE_RUN;
LOADX:
        RunNext <= READX;
   
READX:
    if (DONE == 1'b1)
        RunNext <= LOADY;
    else
        RunNext <= READX;
LOADY:
   
        RunNext <= READY;
    
READY:
    if (DONE == 1'b1)
        RunNext <= IDLE_RUN;
    else
        RunNext <= READY;
endcase
end


endmodule
