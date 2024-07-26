`timescale 10ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2024 02:02:08 PM
// Design Name: 
// Module Name: ad4003_deserializer_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ad4003_deserializer_tb;

    reg rst, adc_spi_clk,adc_read_clk;
    //reg [23:0] adc_sdo_cha,adc_sdo_chb;
    wire cnvst, sdi, sck, reader_en_sync;
    wire [5:0] adc_spi_clk_count;
    
  
    ad4003_deserializer dut (
        .rst(rst),
        .adc_spi_clk(adc_spi_clk),
        .adc_read_clk(adc_read_clk),
        .force_read(1'b0),
        .force_write(1'b0),
        .adc_spi_clk_count(adc_spi_clk_count),  // o [5:0]
        .reader_en_sync(reader_en_sync), // o
        .cnvst(cnvst),
//        .adc_sdo_cha(adc_sdo_cha),
//        .adc_sdo_chb(adc_sdo_chb),
        .sdi(sdi),
        .sck(sck)
       // .adc_data(adc_data),
        );
    
    initial begin
      adc_spi_clk = 1'b0;
      forever adc_spi_clk = #625 !adc_spi_clk;     
     end
     
     initial begin
        adc_read_clk = 1'b0;
        #320 adc_read_clk = 1'b0;
        forever adc_read_clk = #625 !adc_read_clk;  
     end
     
    initial begin
      rst = 1'b1;
      #2000 rst = 1'b0;
    end

endmodule
