module seven_seg(
    input wire clk,
    input wire btn_next, btn_up, btn_down, btn_reset,
    input wire external_load,
    input wire [3:0] external_data,
    output reg [6:0] display_seg,
    output reg [3:0] display_sel,
    output wire [15:0] bcd_data 
);

    reg [1:0] digit_index = 0;
    reg [16:0] refresh_counter = 0;
    reg [1:0] selected_digit = 0;
    reg [3:0] digits [3:0];
    reg [3:0] current_digit_val;

    assign bcd_data = {digits[3], digits[2], digits[1], digits[0]};

    //Blink
    reg [24:0] blink_cnt;
    wire blink_state = ~blink_cnt[24];
    always @(posedge clk) blink_cnt <= blink_cnt + 1;

    //Debounce
    reg [3:0] btn_sync;
    reg [3:0] btn_state = 4'b1111;
    reg [3:0] btn_last = 4'b1111;
    reg [19:0] debounce_timer = 0;

    always @(posedge clk) begin
        btn_sync <= {btn_next, btn_up, btn_down, btn_reset};
        if (btn_sync != btn_state) begin
            if (debounce_timer < 20'd1000000) debounce_timer <= debounce_timer + 1'b1;
            else begin btn_state <= btn_sync; debounce_timer <= 0; end
        end else debounce_timer <= 0;
        btn_last <= btn_state;
    end

    wire n_p = (btn_last[3] == 1 && btn_state[3] == 0);
    wire u_p = (btn_last[2] == 1 && btn_state[2] == 0);
    wire d_p = (btn_last[1] == 1 && btn_state[1] == 0);
    wire r_p = (btn_last[0] == 1 && btn_state[0] == 0);


    reg load_prev; 

    always @(posedge clk) begin
        load_prev <= external_load; 

        if (r_p) begin
            digits[0] <= 0; digits[1] <= 0; digits[2] <= 0; digits[3] <= 0;
            selected_digit <= 0;
        end else begin
            if (n_p) selected_digit <= selected_digit + 1'b1;

          
            if (external_load && !load_prev) begin 
                
                digits[3] <= digits[2]; 
                digits[2] <= digits[1]; 
                digits[1] <= digits[0]; 
                digits[0] <= external_data;
            end else begin
                if (u_p) digits[selected_digit] <= (digits[selected_digit] == 9) ? 0 : digits[selected_digit] + 1;
                if (d_p) digits[selected_digit] <= (digits[selected_digit] == 0) ? 9 : digits[selected_digit] - 1;
            end
        end
    end


    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter >= 50000) begin 
            refresh_counter <= 0; 
            digit_index <= digit_index + 1; 
        end
    end

    always @(*) begin
        current_digit_val = digits[digit_index];
        
        
        case(digit_index)
            0: display_sel = 4'b0001; 
            1: display_sel = 4'b0010; 
            2: display_sel = 4'b0100; 
            3: display_sel = 4'b1000;
            default: display_sel = 4'b0000;
        endcase

       
        case(current_digit_val)
            0: display_seg = 7'b1000000; 1: display_seg = 7'b1111001; 2: display_seg = 7'b0100100;
            3: display_seg = 7'b0110000; 4: display_seg = 7'b0011001; 5: display_seg = 7'b0010010;
            6: display_seg = 7'b0000010; 7: display_seg = 7'b1111000; 8: display_seg = 7'b0000000;
            9: display_seg = 7'b0010000; default: display_seg = 7'b1111111;
        endcase

        // Apply Blinking
        if (digit_index == selected_digit && blink_state) display_seg = 7'b1111111;
    end
endmodule