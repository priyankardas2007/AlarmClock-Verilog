module aclock (

    input reset,                 // Active-high reset
    input clk,                   // 10 Hz input clock

    input [1:0] H_in1,           // Input: hour tens digit (0–2)
    input [3:0] H_in0,           // Input: hour ones digit (0–9)
    input [3:0] M_in1,           // Input: minute tens digit (0–5)
    input [3:0] M_in0,           // Input: minute ones digit (0–9)

    input LD_time,               // Load/set the current time
    input LD_alarm,              // Load/set the alarm time
    input STOP_al,               // Stop/clear the active alarm
    input AL_ON,                 // Enable the alarm

    output reg Alarm,            // Alarm output

    output [1:0] H_out1,         // Current hour tens digit
    output [3:0] H_out0,         // Current hour ones digit
    output [3:0] M_out1,         // Current minute tens digit
    output [3:0] M_out0,         // Current minute ones digit
    output [3:0] S_out1,         // Current second tens digit
    output [3:0] S_out0          // Current second ones digit

);

    reg [3:0] clk_count;         // Counts 10 clock pulses to create 1 second

    // Current time stored directly as BCD digits
    reg [1:0] hour1;             // Hour tens digit
    reg [3:0] hour0;             // Hour ones digit

    reg [3:0] min1;              // Minute tens digit
    reg [3:0] min0;              // Minute ones digit

    reg [3:0] sec1;              // Second tens digit
    reg [3:0] sec0;              // Second ones digit

    reg [1:0] alarm_hour1;       // Alarm hour tens digit
    reg [3:0] alarm_hour0;       // Alarm hour ones digit

    reg [3:0] alarm_min1;        // Alarm minute tens digit
    reg [3:0] alarm_min0;        // Alarm minute ones digit


    assign H_out1 = hour1;       // Connect internal hour tens to output
    assign H_out0 = hour0;       // Connect internal hour ones to output

    assign M_out1 = min1;        // Connect internal minute tens to output
    assign M_out0 = min0;        // Connect internal minute ones to output

    assign S_out1 = sec1;        // Connect internal second tens to output
    assign S_out0 = sec0;        // Connect internal second ones to output


 // logics

    always @(posedge clk or posedge reset) begin
        // Reset logic 
        if (reset) begin         

            clk_count <= 4'd0;   // Reset the 10 Hz counter
            // load hour 
            hour1 <= H_in1;      
            hour0 <= H_in0;      
            // load minute
            min1 <= M_in1;       
            min0 <= M_in0;       
            // set seconds to 00
            sec1 <= 4'd0;        
            sec0 <= 4'd0;        
            // Reset alarm hour
            alarm_hour1 <= 2'd0;  
            alarm_hour0 <= 4'd0; 
            // Reset alarm minute
            alarm_min1 <= 4'd0;  
            alarm_min0 <= 4'd0;  

            Alarm <= 1'b0;       // Turn Alarm output OFF
        end
        
        // NORMAL OPERATION
        else begin               
            // Stop Alarm
            if (STOP_al)
                Alarm <= 1'b0;   
                // as the STOP_al = 1 it clears the Alarm to 0

            // Load Alarm Time
            if (LD_alarm) begin  

                alarm_hour1 <= H_in1; 
                alarm_hour0 <= H_in0; 

                alarm_min1 <= M_in1;  
                alarm_min0 <= M_in0;  
            end

            // Load Current Time
            if (LD_time) begin   

                hour1 <= H_in1;  
                hour0 <= H_in0;  

                min1 <= M_in1;   
                min0 <= M_in0;   

                sec1 <= 4'd0;    
                sec0 <= 4'd0;

                clk_count <= 4'd0;
            end

            // Normal Time Counting
            else begin           // Run clock normally when LD_time = 0

                // Generate 1-second interval
                if (clk_count == 4'd9) begin
                                    // After counting 10 clock pulses
                                    // 0,1,2,3,4,5,6,7,8,9

                    clk_count <= 4'd0; // Restart counter for next second

                    // Increment Seconds
                    if (sec0 == 4'd9) begin
                        sec0 <= 4'd0; // Reset seconds ones digit
                        if (sec1 == 4'd5) begin
                            sec1 <= 4'd0; // Reset seconds to 00
                            // Increment minute
                            if (min0 == 4'd9) begin
                                min0 <= 4'd0;
                                if (min1 == 4'd5) begin
                                    min1 <= 4'd0; // Reset minutes to 00
                                    // Increment Hours
                                    if ((hour1 == 2'd2) && (hour0 == 4'd3)) begin // at this instant the time is 23:59:59
                                        hour1 <= 2'd0; 
                                        hour0 <= 4'd0;
                                    end // the is reset to 00:00:00 

                                    // case where the hour change 09 to 10 or 19 to 20 
                                    else if (hour0 == 4'd9) begin
                                        hour0 <= 4'd0;
                                        hour1 <= hour1 + 1'b1;
                                    end

                                    // normal increment 
                                    else begin
                                        hour0 <= hour0 + 1'b1;
                                    end
                                end
                                // increment in minutes 
                                else begin
                                    min1 <= min1 + 1'b1;
                                end
                            end
                            else begin
                                min0 <= min0 + 1'b1;
                            end
                        end
                        else begin
                            sec1 <= sec1 + 1'b1;
                        end
                    end
                    else begin 
                        sec0 <= sec0 + 1'b1;
                    end
                end

                // Continue counting the 10 Hz clock

                else begin
                    clk_count <= clk_count + 1'b1;// Count each 10 Hz clock pulse
                end
            end


            // Alarm Comparison

            if (
                AL_ON &&                  // Alarm function must be enabled

                (hour1 == alarm_hour1) && // Compare hour 
                (hour0 == alarm_hour0) && 

                (min1  == alarm_min1) &&  // Compare minute 
                (min0  == alarm_min0) &&  

                (sec1  == 4'd0) &&   
                (sec0  == 4'd0)
            ) begin

                Alarm <= 1'b1;            // Turn Alarm ON

            end

        end

    end

endmodule