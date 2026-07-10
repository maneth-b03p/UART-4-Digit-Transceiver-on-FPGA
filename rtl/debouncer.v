module debouncer(
    input clk,
    input btn_in,
    output reg btn_out
);
    reg [19:0] count; // 20ms at 50MHz is 1,000,000 cycles
    
    always @(posedge clk) begin
        if (btn_in == btn_out) begin
            count <= 20'd0;
        end else begin
            count <= count + 1;
            if (count == 1000000) begin
                btn_out <= btn_in;
            end
        end
    end
endmodule