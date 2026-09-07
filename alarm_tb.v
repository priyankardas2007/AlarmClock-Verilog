`timescale 1ns/1ps

module aclock_tb;

    //------------------------------------------------
    // Testbench input registers
    //------------------------------------------------

    reg reset;
    reg clk;

    reg [1:0] H_in1;
    reg [3:0] H_in0;
    reg [3:0] M_in1;
    reg [3:0] M_in0;

    reg LD_time;
    reg LD_alarm;
    reg STOP_al;
    reg AL_ON;


    //------------------------------------------------
    // DUT outputs
    //------------------------------------------------

    wire Alarm;

    wire [1:0] H_out1;
    wire [3:0] H_out0;

    wire [3:0] M_out1;
    wire [3:0] M_out0;

    wire [3:0] S_out1;
    wire [3:0] S_out0;


    //------------------------------------------------
    // Instantiate the DUT
    //------------------------------------------------

    aclock dut (

        .reset(reset),
        .clk(clk),

        .H_in1(H_in1),
        .H_in0(H_in0),

        .M_in1(M_in1),
        .M_in0(M_in0),

        .LD_time(LD_time),
        .LD_alarm(LD_alarm),

        .STOP_al(STOP_al),
        .AL_ON(AL_ON),

        .Alarm(Alarm),

        .H_out1(H_out1),
        .H_out0(H_out0),

        .M_out1(M_out1),
        .M_out0(M_out0),

        .S_out1(S_out1),
        .S_out0(S_out0)

    );


    //------------------------------------------------
    // Generate 10 Hz clock
    //
    // For simulation, period = 10 ns
    // Frequency is not physically important here.
    //------------------------------------------------

    always begin

        #5 clk = ~clk;

    end


    //------------------------------------------------
    // Monitor outputs
    //------------------------------------------------

    initial begin

        $monitor(
            "Time=%0t | Current Time=%0d%0d:%0d%0d:%0d%0d | Alarm=%b",
            $time,

            H_out1, H_out0,
            M_out1, M_out0,
            S_out1, S_out0,

            Alarm
        );

    end


    //------------------------------------------------
    // Test sequence
    //------------------------------------------------

    initial begin

        //------------------------------------------------
        // Initialize all inputs
        //------------------------------------------------

        clk      = 0;
        reset    = 0;

        H_in1    = 0;
        H_in0    = 0;

        M_in1    = 0;
        M_in0    = 0;

        LD_time  = 0;
        LD_alarm = 0;

        STOP_al  = 0;
        AL_ON    = 0;


        //------------------------------------------------
        // TEST 1: RESET
        //
        // Load current time = 12:34:00
        //------------------------------------------------

        #2;

        H_in1 = 1;
        H_in0 = 2;

        M_in1 = 3;
        M_in0 = 4;

        reset = 1;

        #10;

        reset = 0;

        $display("---------------------------------------");
        $display("TEST 1: Reset complete");
        $display("Expected time: 12:34:00");
        $display("---------------------------------------");


        //------------------------------------------------
        // TEST 2: NORMAL COUNTING
        //
        // Wait for 3 simulated seconds
        // Each second = 10 clock pulses
        //------------------------------------------------

        #310;

        $display("---------------------------------------");
        $display("TEST 2: Normal clock counting");
        $display("Clock should have advanced");
        $display("---------------------------------------");


        //------------------------------------------------
        // TEST 3: LOAD CURRENT TIME
        //
        // Set current time = 23:59:55
        // Note: LD_time always resets seconds to 00
        //
        // Therefore first load 23:59:00
        //------------------------------------------------

        H_in1   = 2;
        H_in0   = 3;

        M_in1   = 5;
        M_in0   = 9;

        LD_time = 1;

        #10;

        LD_time = 0;

        $display("---------------------------------------");
        $display("TEST 3: Load time");
        $display("Expected time: 23:59:00");
        $display("---------------------------------------");


        //------------------------------------------------
        // TEST 4: ALARM SETTING
        //
        // Set alarm = 00:00
        //------------------------------------------------

        H_in1    = 0;
        H_in0    = 0;

        M_in1    = 0;
        M_in0    = 0;

        LD_alarm = 1;

        #10;

        LD_alarm = 0;

        $display("---------------------------------------");
        $display("TEST 4: Alarm loaded");
        $display("Expected alarm time: 00:00");
        $display("---------------------------------------");


        //------------------------------------------------
        // TEST 5: ENABLE ALARM
        //------------------------------------------------

        AL_ON = 1;

        $display("---------------------------------------");
        $display("TEST 5: Alarm enabled");
        $display("---------------------------------------");


        //------------------------------------------------
        // TEST 6: WAIT FOR MIDNIGHT
        //
        // Current time is near 23:59:00
        // Wait approximately 61 seconds in simulation
        //
        // Each simulated second = 100 ns
        //------------------------------------------------

        #6100;

        $display("---------------------------------------");
        $display("TEST 6: Midnight rollover");
        $display("Expected time near 00:00:00");
        $display("Alarm should become HIGH");
        $display("---------------------------------------");


        //------------------------------------------------
        // TEST 7: STOP ALARM
        //------------------------------------------------

        STOP_al = 1;

        #10;

        STOP_al = 0;

        $display("---------------------------------------");
        $display("TEST 7: Stop alarm");
        $display("Expected Alarm = 0");
        $display("---------------------------------------");


        //------------------------------------------------
        // TEST 8: LOAD A NEW TIME
        //
        // Set time = 06:29:00
        //------------------------------------------------

        H_in1   = 0;
        H_in0   = 6;

        M_in1   = 2;
        M_in0   = 9;

        LD_time = 1;

        #10;

        LD_time = 0;


        //------------------------------------------------
        // TEST 9: SET ALARM = 06:30
        //------------------------------------------------

        H_in1    = 0;
        H_in0    = 6;

        M_in1    = 3;
        M_in0    = 0;

        LD_alarm = 1;

        #10;

        LD_alarm = 0;

        AL_ON = 1;

        $display("---------------------------------------");
        $display("TEST 8/9:");
        $display("Current time = 06:29:00");
        $display("Alarm time   = 06:30:00");
        $display("---------------------------------------");


        //------------------------------------------------
        // Wait until alarm time
        //------------------------------------------------

        #6100;


        //------------------------------------------------
        // Finish simulation
        //------------------------------------------------

        $display("---------------------------------------");
        $display("Simulation Finished");
        $display("---------------------------------------");

        $finish;

    end


    //------------------------------------------------
    // Create waveform file
    //------------------------------------------------

    initial begin

        $dumpfile("aclock.vcd");
        $dumpvars(0, aclock_tb);

    end

endmodule