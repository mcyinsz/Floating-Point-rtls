/*
    generate control logic (valid, ready) for pipeline registers
*/

module decouple_pipeline_ctrl (
    input wire clock,
    input wire reset,
    input wire in_valid,
    input wire out_ready,
    output wire in_ready,
    output reg out_valid
);

    // ctrl logic
    // empty or dequeue
    assign in_ready =  (!out_valid) || (out_ready);
    
    // in/out fire
    wire in_fire = in_ready && in_valid;
    wire out_fire = out_ready && out_valid;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            out_valid <= 1'b0;
        end else begin
            if (out_fire && (!(in_fire))) begin // input fire without input
                out_valid <= 1'b0;
            end 
            else if (in_fire && (!out_fire)) begin // output fire without input
                out_valid <= 1'b1;
            end
            else begin
                out_valid <= out_valid;
            end
        end
    end

endmodule