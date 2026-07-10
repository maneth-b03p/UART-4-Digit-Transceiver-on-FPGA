module receiver(
    input clk, 
    input rst, 
    input rx, 
    // input rdy_clr, 
    input clk_en,  
    output reg rdy, 
    output reg [7:0] data_out
);
    reg [1:0] state; 
    reg [3:0] smp; 
    reg [2:0] idx; 
    reg [7:0] tmp;

    always @(posedge clk) begin
        if (rst) begin 
            state <= 2'b00; 
            rdy <= 1'b0; 
            smp <= 4'b0;
            idx <= 3'b0;
            data_out <= 8'b0;
            tmp <= 8'b0;
        end else begin
            if (clk_en) begin
                case (state)
                    // STATE 0: 
                    2'b00: begin
                        if (rx == 1'b0) begin
                          
                            rdy <= 1'b0; 
                            
                            if (smp == 7) begin 
                               
                                state <= 2'b01; 
                                smp <= 4'b0; 
                                idx <= 3'b0; 
                            end else begin
                                smp <= smp + 4'b1;
                            end
                        end else begin
                            smp <= 4'b0; 
                        end
                    end

                    // STATE 1: 
                    2'b01: begin
                        if (smp == 15) begin 
                          
                            tmp[idx] <= rx; 
                            smp <= 4'b0; 
                            if (idx == 3'd7) begin
                                state <= 2'b10; 
                            end else begin
                                idx <= idx + 3'b1; 
                            end
                        end else begin
                            smp <= smp + 4'b1;
                        end
                    end

                    // STATE 2: 
                    2'b10: begin
                        if (smp == 15) begin
                            if (rx == 1'b1) begin 
                              
                                data_out <= tmp; 
                                rdy <= 1'b1; 
                            end
                            state <= 2'b00; 
                            smp <= 4'b0; 
                        end else begin
                            smp <= smp + 4'b1;
                        end
                    end

                    default: state <= 2'b00;
                endcase
            end
        end
    end
endmodule