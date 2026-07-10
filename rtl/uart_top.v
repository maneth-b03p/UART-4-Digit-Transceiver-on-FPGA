module uart_top(
    input clk,
    input rst_n,          
    input send_btn,       
    input rx_pin,         
    output tx_pin,        
    
    input btn_next,
    input btn_up,
    input btn_down,
    
    output [6:0] display_seg,
    output [3:0] display_sel
);

    
    wire tx_tick, rx_tick;
    wire [15:0] local_bcd;
    wire rdy, busy;
    wire [7:0] received_byte;
    
    reg uart_write_en;
    reg [7:0] uart_data_to_send;
    reg [2:0] tx_state;

    
    seven_seg_mux display_unit (
        .clk(clk),
        .btn_next(btn_next),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_reset(rst_n),
        .external_load(rdy && (received_byte >= 8'h00 && received_byte <= 8'h09)),
        .external_data(received_byte[3:0]), 
        .display_seg(display_seg),
        .display_sel(display_sel),
        .bcd_data(local_bcd)
    );

    
    baud_rate_generator baud_gen (
        .clk(clk),
        .rst(~rst_n),
        .tx_enb(tx_tick),
        .rx_enb(rx_tick)
    );

    
    transmitter tx_inst (
        .clk(clk), .rst(~rst_n), .en(tx_tick),
        .write_en(uart_write_en), .data_in(uart_data_to_send),
        .tx(tx_pin), .busy(busy)
    );

    receiver rx_inst (
        .clk(clk), .rst(~rst_n), .rx(rx_pin), .clk_en(rx_tick),
        .rdy(rdy), .data_out(received_byte) 
        
    );

   
    reg send_prev;
    always @(posedge clk) begin
        send_prev <= send_btn;
        
        if (~rst_n) begin
            tx_state <= 0;
            uart_write_en <= 0;
            uart_data_to_send <= 8'h00;
        end else begin
            
            uart_write_en <= 0;

            case (tx_state)
                // IDLE
                0: begin
                    if (send_prev && !send_btn && !busy) begin
                        tx_state <= 1;
                    end
                end

                // Digit 3 (Thousands)
                1: begin
                    if (!busy) begin
                        uart_data_to_send <= {4'h0, local_bcd[15:12]};
                        uart_write_en <= 1;
                        tx_state <= 2;
                    end
                end

                // Digit 2 (Hundreds) 
                2: begin
                    if (!busy && !uart_write_en) begin
                        uart_data_to_send <= {4'h0, local_bcd[11:8]};
                        uart_write_en <= 1;
                        tx_state <= 3;
                    end
                end

                // Digit 1 (Tens)
                3: begin
                    if (!busy && !uart_write_en) begin
                        uart_data_to_send <= {4'h0, local_bcd[7:4]};
                        uart_write_en <= 1;
                        tx_state <= 4;
                    end
                end

                // Digit 0 (Ones)
                4: begin
                    if (!busy && !uart_write_en) begin
                        uart_data_to_send <= {4'h0, local_bcd[3:0]};
                        uart_write_en <= 1;
                        tx_state <= 0;
                    end
                end

                
                5: begin
                    if (!busy && !uart_write_en) begin
                        uart_data_to_send <= 8'h3A; 
                        uart_write_en <= 1;
                        tx_state <= 0;
                    end
                end

                default: tx_state <= 0;
            endcase
        end
    end
endmodule
