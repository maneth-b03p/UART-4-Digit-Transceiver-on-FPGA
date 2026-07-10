module transmitter(
    input clk,
    input rst,
    input write_en,
    input en,          
    input [7:0] data_in,
    output reg tx,
    output reg busy
);

    reg [1:0] state;
    reg [2:0] bit_count;
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            state <= 2'b00;
            tx <= 1'b1;
            busy <= 1'b0;
            bit_count <= 3'b0;
            shift_reg <= 8'b0;
        end else begin
            case (state)
                // STATE 0: IDLE
                2'b00: begin
                    if (write_en) begin
                        shift_reg <= data_in;
                        busy <= 1'b1;      
                        state <= 2'b01;   
                    end else begin
                        busy <= 1'b0;    
                        tx <= 1'b1;      
                    end
                end

                // STATE 1: START BIT
                2'b01: begin
                    if (en) begin
                        tx <= 1'b0;        
                        state <= 2'b10;
                        bit_count <= 3'b0;
                    end
                end

                // STATE 2: DATA BITS (LSB first)
                2'b10: begin
                    if (en) begin
                        tx <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        if (bit_count == 3'd7) begin
                            state <= 2'b11; // Move to Stop Bit
                        end else begin
                            bit_count <= bit_count + 3'b1;
                        end
                    end
                end

                // STATE 3: STOP BIT
                2'b11: begin
                    if (en) begin
                        tx <= 1'b1;        
                        busy <= 1'b0;     
                        state <= 2'b00;
                    end
                end

                default: state <= 2'b00;
            endcase
        end
    end
endmodule