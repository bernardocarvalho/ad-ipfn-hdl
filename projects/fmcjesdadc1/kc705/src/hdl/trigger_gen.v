`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/30/2019 03:15:44 PM
// Design Name:
// Module Name: trigger_gen
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Additional Comments:
//
//
// Copyright 2019-2021 IPFN-Instituto Superior Tecnico, Portugal
// Creation Date   04/30/2019 03:15:44 PM
//
// Licensed under the EUPL, Version 1.2 or - as soon they
// will be approved by the European Commission - subsequent
// versions of the EUPL (the "Licence");
//
// You may not use this work except in compliance with the
// Licence.
// You may obtain a copy of the Licence at:
//
// https://joinup.ec.europa.eu/software/page/eupl
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the Licence is
// distributed on an "AS IS" basis,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied.
// See the Licence for the specific language governing
// permissions and limitations under the Licence.
//
//
//////////////////////////////////////////////////////////////////////////////////
module trigger_gen #(
  parameter     ADC_DATA_WIDTH = 16)  // ADC is 14 bit, but data is 16
  (
    input rxclk,      // 125 Mhz , two samples per clock
    input [31:0] adc_data_a,
    input adc_enable_a,
    input adc_valid_a,
    input [31:0] adc_data_b,
    input adc_enable_b,
    input adc_valid_b,
    input [31:0] adc_data_c,
    input adc_enable_c,
    input adc_valid_c,
    input [31:0] adc_data_d,
    input adc_enable_d,
    input adc_valid_d,

    input trig_enable,  // Enable/Reset State Machine
    input  [31:0] trig_level_a,
    input  [31:0] trig_level_b,
    input  [31:0] trig_level_c,

    input      [31:0]  param_mul,
    input      [31:0]  param_off,

    output [31:0] pulse_tof,  // Difference Pulse_0 -> Pulse_1
    output [3:0] detect_pls //channel 4 Osc
//    output detect_pls_1,  // 
//    output detect_pls_2  // Channel 3 Osc
  );
/*********** Function Declarations ***************/

function signed [ADC_DATA_WIDTH:0] adc_channel_sum_f;  // 17 bit for sum headroom
	 input [31:0] adc_data;

     reg signed [ADC_DATA_WIDTH:0] adc_ext_1st;
     reg signed [ADC_DATA_WIDTH:0] adc_ext_2nd;
	   begin
            adc_ext_1st = $signed({adc_data[15],  adc_data[15:0]}); // sign extend
            adc_ext_2nd = $signed({adc_data[31], adc_data[31:16]});
            adc_channel_sum_f = adc_ext_1st + adc_ext_2nd;
	  end
  endfunction
  
/*
function  trigger_rising_eval_f;
	input signed [ADC_DATA_WIDTH:0] adc_channel_mean;
	input signed [ADC_DATA_WIDTH-1:0] trig_lvl;

    reg signed [ADC_DATA_WIDTH:0] trig_lvl_ext;
	begin
       trig_lvl_ext          = $signed({trig_lvl, 1'b0}); // Mult * 2 with sign
       trigger_rising_eval_f =(adc_channel_mean > trig_lvl_ext)? 1'b1: 1'b0;
    end
endfunction


https://web.mit.edu/6.111/www/f2016/handouts/L08_4.pdf
wire signed [31:0] a,b,s;
wire z,n,v,c;
assign {c,s} = a + b;
assign z = ~|s;
assign n = s[31];
assign v = a[31]^b[31]^s[31]^c; /overload
*/
/*
function  trigger_falling_eval_f;
	input signed [ADC_DATA_WIDTH:0] adc_channel_mean;
	input signed [ADC_DATA_WIDTH-1:0] trig_lvl;
	reg signed [ADC_DATA_WIDTH:0] trig_lvl_ext;
    reg signed [ADC_DATA_WIDTH-1:0] s;
	reg z,n,v,c;
	begin
	    trig_lvl_ext = $signed({trig_lvl, 1'b0}); // Mult * 2  with  sign extend
	    {c,s} = adc_channel_mean + trig_lvl_ext;
	    trigger_falling_eval_f = s[31]; // negative if adc_channel_mean
        //trig_lvl_ext = $signed({trig_lvl, 1'b0}); // Mult * 2  with  sign extend
        // trigger_falling_eval_f =(adc_channel_mean < trig_lvl_ext)? 1'b1: 1'b0;
    end
endfunction


function  trigger_falling_eval_f;
	input signed [ADC_DATA_WIDTH:0] adc_channel_mean;
	input signed [ADC_DATA_WIDTH-1:0] trig_lvl;
	reg signed [ADC_DATA_WIDTH:0] trig_lvl_ext;
	reg less;
	begin
        trig_lvl_ext = $signed({trig_lvl, 1'b0}); // Mult * 2  with  sign extend
        less = adc_channel_mean < trig_lvl_ext;
        trigger_falling_eval_f =(less)? 1'b1: 1'b0;
    end
endfunction
*/

function  trigger_eval_f;
        input signed [ADC_DATA_WIDTH:0] adc_channel_mean;
        input signed [ADC_DATA_WIDTH-1:0] trig_lvl_p;
        input signed [ADC_DATA_WIDTH-1:0] trig_lvl_m;

        reg signed [ADC_DATA_WIDTH:0] trig_lvl_p_ext, trig_lvl_m_ext;

        begin
           trig_lvl_p_ext          = $signed({trig_lvl_p, 1'b0}); // Mult * 2 with sign
           trig_lvl_m_ext          = $signed({trig_lvl_m, 1'b0}); // Mult * 2 with sign
           trigger_eval_f = (adc_channel_mean > trig_lvl_p_ext) || (adc_channel_mean < trig_lvl_m_ext);
        end
endfunction

/*********** End Function Declarations ***************/

/************ Trigger Logic ************/
	/* ADC Data comes in pairs. Compute mean, or simply add */
	(* mark_debug = "true" *) reg signed [ADC_DATA_WIDTH:0] adc_sum_a, adc_sum_b, adc_sum_c, adc_sum_d ;
	always @(posedge rxclk) begin
         if (adc_enable_a)  // Use adc_valid_a ?
            adc_sum_a <= adc_channel_sum_f(adc_data_a); // check order (not really necessary, its a mean...)
         if (adc_enable_b)  // Use adc_valid_b ?
            adc_sum_b <= adc_channel_sum_f(adc_data_b);
         if (adc_enable_c)
            adc_sum_c <= adc_channel_sum_f(adc_data_c);
         if (adc_enable_d)
            adc_sum_d <= adc_channel_sum_f(adc_data_d);
	end

	reg [3:0] detect_pls_r = 4'h0;
    assign detect_pls = detect_pls_r;

    //(* mark_debug = "true" *) 
     wire  signed [15:0]  trig_level_a_p = trig_level_a[31:16];
    //(* mark_debug = "true" *) 
     wire  signed [15:0]  trig_level_a_m = trig_level_a[15:0];
    // (* mark_debug = "true" *) 
     wire  signed [15:0]  trig_level_b_p = trig_level_b[31:16];
     wire  signed [15:0]  trig_level_b_m = trig_level_b[15:0];
     wire  signed [15:0]  trig_level_c_p = trig_level_c[31:16];
     wire  signed [15:0]  trig_level_c_m = trig_level_c[15:0];

     //(* mark_debug = "true" *) wire less_i = trigger_falling_eval_f(adc_sum_b, trig_level_b_m);

     localparam WAIT_WIDTH = 32;

     reg [31:0] pulse_delay_r         =  32'hFFFF;
     reg [WAIT_WIDTH-1:0] hold_cnt_r  = 'h00;
     assign pulse_tof = pulse_delay_r;

     localparam START            = 3'b000;
     localparam WAIT_PULSE1     = 3'b001;
     localparam HOLD1           = 3'b011;
     localparam WAIT_PULSE2     = 3'b010;
     localparam HOLD2           = 3'b110;
     localparam WAIT_PULSE3     = 3'b111;
     localparam DELAY_TRIGGER    = 3'b101;
     localparam TRIGGER         = 3'b100;

     //localparam WAIT_WIDTH = 24;

     reg signed [31:0] delay_time = 'h00;  // Q16.16 Number. 32'h0001_0000 = 8ns

     (* mark_debug = "true" *)  reg [2:0] state = START;

    reg signed [31:0] counter=0;
    reg  [31:0] wait_cnt_r = 32'h0;

    always @(posedge rxclk)
       if (!trig_enable) begin
          state <= START;
          //detect_pls_0_r  <=  0;
          //detect_pls_1_r  <=  0;
          //detect_pls_2_r  <=  0;
          hold_cnt_r    <= 32'd12_500_000; // (* 8ns) Initial Idle Time  = 0.1 s Max 4294967294/34 s
       end
       else
          case (state)
             START: begin        // Sleeping
                if (hold_cnt_r == {WAIT_WIDTH{1'b0}}) begin
                   state <= WAIT_PULSE1;
                   //pulse_delay_r  <=   32'h0A; // Testing
                end
        	    detect_pls_r <= 4'h0;
                hold_cnt_r <=  hold_cnt_r - 32'h01;
                pulse_delay_r  <= trig_level_a; //  {trig_level_b_p, trig_level_b_m} ; // Debug
             end
             WAIT_PULSE1: begin // Armed: Waiting first pulse
                if (trigger_eval_f(adc_sum_a, trig_level_a_p, trig_level_a_m)) begin
                   state <= HOLD1;
                   detect_pls_r[0]  <=  1'b1;
                   pulse_delay_r  <=   {trig_level_b_m, 16'h0B} ; // Testing
                   hold_cnt_r        <= 32'd2500;  //(* 8ns). Dead Time  = 20 us ,
                   delay_time <= 'h00;    // Reset delay counting
                   wait_cnt_r <= 'h00;    // Reset unit counting
                end
             end
             HOLD1: begin        // Holding period, no detect, but counting
                if (hold_cnt_r == {WAIT_WIDTH{1'b0}}) begin  // Holding time
                   state <= WAIT_PULSE2;
                end
                else begin
                    delay_time   <=  delay_time + $signed(param_mul); // counting delay time units
                    hold_cnt_r   <=  hold_cnt_r - 32'h01; // Wait to Zero
                    wait_cnt_r   <=  wait_cnt_r + 32'h01;
                end
             end
             WAIT_PULSE2: begin // Got first pulse. waiting second probe
                if (trigger_eval_f(adc_sum_b, trig_level_b_p, trig_level_b_m)) begin
                    state <= HOLD2;
                    detect_pls_r[1]  <=  1'b1;
                    pulse_delay_r   <= wait_cnt_r;  // Save waiting cycles
                    delay_time      <=  delay_time + $signed(param_off);  // Save pulse B-A  Time + Offset
                    hold_cnt_r      <= 32'd2500; // (* 8ns) Dead Time  = 20 us, 200mm , (1 us = 10 mm @10km/s)
                end
                else begin
                    delay_time   <=  delay_time + $signed(param_mul);           //  time units
                    wait_cnt_r   <=  wait_cnt_r + 32'h01;
                end
             end
             HOLD2: begin        // Got second pulse. Holding period, no detect.
                if (hold_cnt_r == {WAIT_WIDTH{1'b0}}) begin  // Holding time
                   state       <= WAIT_PULSE3;
                end
                else begin
                    hold_cnt_r <=  hold_cnt_r - 32'h01;
                end
             end
             WAIT_PULSE3: begin   //   Waiting Third channel
                if (trigger_eval_f(adc_sum_c, trig_level_c_p, trig_level_c_m)) begin
                    detect_pls_r[2]  <=  1'b1;
                    state       <= DELAY_TRIGGER;
                    counter     <= 32'h00;
                end
             end
             DELAY_TRIGGER : begin   // Got Third pulse. Waiting calculated delay
                if (counter >= delay_time) begin
                   //detect_pls_0_r <=  1'b1;
                   detect_pls_r[3]  <=  1'b1;
                   //detect_pls_1_r <=  1'b1;
                   state        <= TRIGGER;
                end
                else begin
                    counter <= counter + 32'h0001_0000;  // count 8ns periods
                    end
             end
             TRIGGER : begin  // Send Trigger and Stop SM
                  state <= TRIGGER;
             end
             default :
                     state <= START;
          endcase


endmodule
