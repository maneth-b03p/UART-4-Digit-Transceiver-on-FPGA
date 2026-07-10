module baud_rate_generator(input clk, input rst, output tx_enb, rx_enb);
  
  reg [12:0] tx_counter;
  reg [9:0] rx_counter;
  
  always @(posedge clk)
	  if (rst) begin
					tx_counter <= 13'd0;
					rx_counter <= 10'd0;
					end
    else begin
      if (tx_counter == 5208) tx_counter <= 13'b0;
      else tx_counter <= tx_counter + 13'b1;  
    
      if (rx_counter == 325) rx_counter <= 10'b0;
      else rx_counter <= rx_counter + 10'b1;  
    end
  
  
  assign tx_enb = (tx_counter == 13'b0)? 1'b1 : 1'b0;
  assign rx_enb = (rx_counter == 10'b0)? 1'b1 : 1'b0;



endmodule