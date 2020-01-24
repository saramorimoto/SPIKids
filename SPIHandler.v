`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2018 05:53:28 PM
// Design Name: 
// Module Name: SPIHandler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 


//SCLK_A!!!!!!!!!!!!!!!

module SPIHandler(CLK, ARST_L, DIN, DOUT, SEND, DONE, MOSI, MISO, SCLK_A, SS, XDATA_MISO, YDATA_MISO);
input CLK, ARST_L;
input [23:0] DIN;
output [23:0] DOUT;
input SEND;
output DONE;
input MISO;
output MOSI;
output SS, SCLK_A;
output [7:0] XDATA_MISO;
output [7:0] YDATA_MISO;
reg [7:0] XDATA_MISO;
reg [7:0] YDATA_MISO;



wire READNWRITE;
reg [23:0] SPIReg;
wire roll_i;
reg [4:0] count_i;
reg DONE;
reg SS;
reg SCLK_A;

reg [2:0] HandlerReg;
reg [2:0] HandlerNext;
//State machine state names as parameters
parameter [2:0] IDLE_HANDLER = 3'b000;
parameter [2:0] SSLOW = 3'b001;
parameter [2:0] SCLK_AHIGH = 3'b010;
parameter [2:0] SCLK_ALOW = 3'b011;
parameter [2:0] SSHIGH = 3'b100;
parameter [2:0] DONESTROBE = 3'b101;

assign MOSI = SPIReg [23]; //shifting data OUT MSB first

assign READNWRITE = (DIN [7:0] == 8'b00000000) ? 1'b1 : 1'b0;
//READING == 1 when DIN == 0


//SPIReg Shift Register
always@(posedge CLK or negedge ARST_L)
begin
    if (~ARST_L)
        SPIReg <= 24'h000000;
    else if (HandlerReg == SSLOW)
        SPIReg <= DIN;//LOAD SPI REG
    else if ((READNWRITE == 1'b0) && (HandlerReg == SCLK_ALOW))
        SPIReg <= {SPIReg [22:0], 1'b0}; //SHIFT SPI REG
    else if ((READNWRITE == 1'b1) && (HandlerReg == SCLK_ALOW))
        SPIReg <= {SPIReg[22:0], MISO};  //LOAD SPI REG..Maybe shifts?
//    else if (READNWRITE == 1'b0) 
////        SPIReg <= {SPIReg [22:0], 0};

    else;
end       

//MISO!!!
always@(posedge CLK or negedge ARST_L)
if (~ARST_L)
begin
    XDATA_MISO <= 8'b00000000;
    YDATA_MISO <= 8'b00000000;
end
else if ((READNWRITE == 1'b1) && ( HandlerReg == SSHIGH) && (DONE == 1'b1))
begin
    XDATA_MISO <= SPIReg [7:0];
    YDATA_MISO <= SPIReg [7:0];
end
else;

//State Memory
always@(posedge CLK or negedge ARST_L)
if (~ARST_L)
HandlerReg <= IDLE_HANDLER;
else
HandlerReg <= HandlerNext;

//Next State Logic
always@(SEND or roll_i or HandlerReg)
begin
    case(HandlerReg)
        
        IDLE_HANDLER:
            if (SEND == 1'b1)
                HandlerNext <= SSLOW;
            else
                HandlerNext <= IDLE_HANDLER;
                
        SSLOW: 
            HandlerNext <= SCLK_AHIGH;
            
        SCLK_AHIGH:
            HandlerNext <= SCLK_ALOW;
            
        SCLK_ALOW:
            if (roll_i == 1'b1)
                HandlerNext <= SSHIGH;
            else
                HandlerNext <= SCLK_AHIGH;
        SSHIGH:
            HandlerNext <= DONESTROBE;
        DONESTROBE:
            HandlerNext <= IDLE_HANDLER;
           
    endcase
end

//SS and SCLK_A and DONE
always@(posedge CLK or negedge ARST_L)
begin
    if (~ARST_L)
        begin
          DONE <= 1'b0;
          SS <= 1'b1;
          SCLK_A <= 1'b0;
         end
    else if (HandlerReg == SSLOW)
        SS <= 1'b0;
    else if (HandlerReg == SCLK_AHIGH)
        SCLK_A <= 1'b1;
    else if (HandlerReg == SCLK_ALOW)
        SCLK_A <= 1'b0;
    else if (HandlerReg == SSHIGH)
        SS <= 1'b1;
    else if (HandlerReg == DONESTROBE)
        DONE <= 1'b1;
    else
    begin
        DONE <= 1'b0;
        SS <= 1'b1;
        SCLK_A <= 1'b0;
    end
end

//24 count counter!
always@(posedge CLK or negedge ARST_L)
if (~ARST_L)
    count_i <= 5'b00000;
else if (roll_i == 1'b1)
    count_i <= 5'b00000;
else if (HandlerReg == SCLK_AHIGH)
    count_i <= count_i + 1;
else;

assign roll_i = (count_i == 24) ? 1'b1 : 1'b0;

endmodule
