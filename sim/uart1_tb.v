`timescale 1ns / 1ps

module uart1_tb();

    // Global Signals
    reg clk;
    reg rst_n;
    
    // Board A (Transmitter) Signals
    reg send_btn;
    wire tx_to_rx; // Serial link
    reg btn_next_a, btn_up_a, btn_down_a;
    wire [6:0] seg_a;
    wire [3:0] sel_a;

    // Board B (Receiver) Signals
    wire tx_unused;
    reg btn_next_b, btn_up_b, btn_down_b;
    wire [6:0] seg_b;
    wire [3:0] sel_b;

    // 1. Master Unit: Will transmit BCD data
    uart_top Master_Unit (
        .clk(clk),
        .rst_n(rst_n),
        .send_btn(send_btn),
        .rx_pin(1'b1),      // Idle
        .tx_pin(tx_to_rx),   // Connected to Slave RX
        .btn_next(btn_next_a),
        .btn_up(btn_up_a),
        .btn_down(btn_down_a),
        .display_seg(seg_a),
        .display_sel(sel_a)
    );

    // 2. Slave Unit: Will receive and update display
    uart_top Slave_Unit (
        .clk(clk),
        .rst_n(rst_n),
        .send_btn(1'b1),    // Not used
        .rx_pin(tx_to_rx),   // Connected to Master TX
        .tx_pin(tx_unused),
        .btn_next(btn_next_b),
        .btn_up(btn_up_b),
        .btn_down(btn_down_b),
        .display_seg(seg_b),
        .display_sel(sel_b)
    );

    // Clock Generation: 50MHz (20ns period)
    always #10 clk = ~clk;

    initial begin
        // --- Initialization ---
        clk = 0;
        rst_n = 1;
        send_btn = 1;
        btn_next_a = 1; btn_up_a = 1; btn_down_a = 1;
        btn_next_b = 1; btn_up_b = 1; btn_down_b = 1;

        #100 rst_n = 0; // Release Reset
		  #100 rst_n = 1; 
        #100;

        // --- Step 1: Manually set value 5678 on Master ---
        $display("Time: %t | Setting Master BCD to 5678...", $time);

        // Set Digit 0 to '8' (Press Up 8 times)
        repeat(8) begin
            btn_up_a = 0; #21000; btn_up_a = 1; #1000; 
        end

        // Move to Digit 1
        btn_next_a = 0; #21000; btn_next_a = 1; #1000;

        // Set Digit 1 to '7' (Press Up 7 times)
        repeat(7) begin
            btn_up_a = 0; #21000; btn_up_a = 1; #1000;
        end

        // Move to Digit 2
        btn_next_a = 0; #21000; btn_next_a = 1; #1000;

        // Set Digit 2 to '6' (Press Up 6 times)
        repeat(6) begin
            btn_up_a = 0; #21000; btn_up_a = 1; #1000;
        end

        // Move to Digit 3
        btn_next_a = 0; #21000; btn_next_a = 1; #1000;

        // Set Digit 3 to '5' (Press Up 5 times)
        repeat(5) begin
            btn_up_a = 0; #21000; btn_up_a = 1; #1000;
        end

        $display("Time: %t | Master BCD is now: %h", $time, Master_Unit.local_bcd);

        // --- Step 2: Trigger UART Transmission ---
        $display("Time: %t | Triggering Send...", $time);
        send_btn = 0;   // Press send
        #21000;      // Hold for 21ms to pass debouncer
        send_btn = 1;   // Release
		  
		  #5000 $stop;
		  end
		  

		  
endmodule