module float_max (
    input [31:0] a,      
    input [31:0] b,      
    output reg [31:0] max
);

wire a_sign = a[31];
wire [7:0] a_exp = a[30:23];
wire [22:0] a_frac = a[22:0];

wire b_sign = b[31];
wire [7:0] b_exp = b[30:23];
wire [22:0] b_frac = b[22:0];

wire a_is_nan = (a_exp == 8'hFF) && (a_frac != 23'h0);
wire b_is_nan = (b_exp == 8'hFF) && (b_frac != 23'h0);

always @(*) begin
    
    if (a_is_nan && b_is_nan) begin
        max = a;
    end
    else if (a_is_nan) begin
        max = b;
    end
    else if (b_is_nan) begin
        max = a;
    end
    else if (a_sign != b_sign) begin
        if (a_sign == 1'b0) 
            max = a;
        else 
            max = b;
    end

    else begin
        if (a_sign == 1'b0) begin
            max = (a >= b) ? a : b;
        end else begin
            max = (a >= b) ? b : a;
        end
    end
end

endmodule