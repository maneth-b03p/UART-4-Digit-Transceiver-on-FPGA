`timescale 1ns / 1ps

module uart_tb();
    reg clk;
    reg rst;
    reg write_en;
    reg [7:0] data_in;
	 reg rdy_clr;
    

    wire tx_out_wire;
	 wire rx_in_wire;
	
    assign #5000 rx_in_wire = tx_out_wire;	
    

    wire [7:0] led_out;
    wire busy, rdy;

    uart_top uut (
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .data_in(data_in),       
			
			
		  .rdy_clr(rdy_clr),
		  
        .tx_pin(tx_out_wire),
        .rx_pin(rx_in_wire), 
        
        .busy(busy),
        .rdy(rdy),
        .led_out(led_out)
    );
	 
	 initial clk = 0;
    always #10 clk = ~clk;

    initial 
		  begin
        
        rst = 1;
		  write_en = 0; 
		  data_in = 8'h00; 
		  rdy_clr = 0;
        #100 rst = 0;
        
        // Send 0xC3 (11000011)
        #100;
        data_in = 8'hC3;
        write_en = 1;
		  
		  #20 write_en = 0;
		  
		  // Wait for 'rdy' signal from receiver
        wait(rdy == 1);
		  #1
        $display("Success! Received: %h", led_out);
		  
		  #20 rdy_clr = 1;
		  #20 rdy_clr = 0;
		  
		  
		  // Send 0xD4 (11010100)
		  #10000;
        data_in = 8'hD4;
        write_en = 1;
        #20 write_en = 0;

        wait(rdy == 1);
		  #1
        $display("Success! Received: %h", led_out);
		  
		  rdy_clr = 1;
		  #20 rdy_clr = 0;
        
        #500000 $stop;
        end


endmodule