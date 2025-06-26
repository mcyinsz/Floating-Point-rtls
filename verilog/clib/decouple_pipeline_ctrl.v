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

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            out_valid <= 1'b0;
        end else begin
            if (in_ready) begin
                out_valid <= in_valid;
            end
        end
    end


endmodule