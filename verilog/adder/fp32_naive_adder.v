module fpu_add (
    input wire clk,
    input wire rst_n,
    input wire [31:0] a,      // IEEE 754 单精度浮点数 A
    input wire [31:0] b,      // IEEE 754 单精度浮点数 B
    output reg [31:0] result, // 加法结果
    output reg invalid        // 异常标志
);

// 解构浮点数
wire a_sign = a[31];
wire [7:0] a_exp = a[30:23];
wire [22:0] a_frac = {1'b1, a[22:0]};  // 添加隐含的1

wire b_sign = b[31];
wire [7:0] b_exp = b[30:23];
wire [22:0] b_frac = {1'b1, b[22:0]};  // 添加隐含的1

// 处理特殊值（NaN/Inf）
wire a_nan = &a_exp && |a[22:0];
wire b_nan = &b_exp && |b[22:0];
wire a_inf = &a_exp && !|a[22:0];
wire b_inf = &b_exp && !|b[22:0];

// 对阶操作
reg [7:0] exp_diff;
reg [23:0] a_frac_adj, b_frac_adj;
reg [7:0] max_exp;

always @(*) begin
    exp_diff = a_exp - b_exp;
    if (a_exp >= b_exp) begin
        max_exp = a_exp;
        a_frac_adj = a_frac;
        b_frac_adj = b_frac >> exp_diff;
    end else begin
        max_exp = b_exp;
        a_frac_adj = a_frac >> (-exp_diff);
        b_frac_adj = b_frac;
    end
end

// 尾数加法
reg [24:0] sum;  // 额外1位用于溢出
always @(*) begin
    if (a_sign == b_sign) begin
        sum = {1'b0, a_frac_adj} + {1'b0, b_frac_adj};
    end else begin
        if (a_frac_adj >= b_frac_adj) 
            sum = {1'b0, a_frac_adj} - {1'b0, b_frac_adj};
        else 
            sum = {1'b0, b_frac_adj} - {1'b0, a_frac_adj};
    end
end

// 规格化
reg [4:0] lead_zeros;
reg [24:0] sum_norm;
reg [7:0] exp_norm;

always @(*) begin
    lead_zeros = 0;
    sum_norm = sum;
    exp_norm = max_exp;
    
    // 检测前导1的位置
    if (sum[24]) begin  // 溢出
        sum_norm = sum >> 1;
        exp_norm = max_exp + 1;
    end else begin
        // 计算前导零数量
        for (int i = 23; i >= 0; i--) begin
            if (sum[i]) begin
                lead_zeros = 23 - i;
                break;
            end
        end
        sum_norm = sum << lead_zeros;
        exp_norm = max_exp - lead_zeros;
    end
end

// 舍入（向最近偶数）
wire round_bit = sum_norm[0];
wire sticky_bit = |sum_norm[23:0];
wire do_round = round_bit && (sum_norm[1] || sticky_bit);

reg [23:0] frac_rounded;
always @(*) begin
    frac_rounded = sum_norm[24:1];
    if (do_round) frac_rounded = frac_rounded + 1;
end

// 最终结果组合
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 32'h0;
        invalid <= 1'b0;
    end else begin
        // 处理特殊值
        if (a_nan || b_nan) begin
            result <= 32'h7FC00000; // 标准NaN
            invalid <= 1'b1;
        end else if (a_inf && b_inf && (a_sign != b_sign)) begin
            result <= 32'h7FC00000; // ∞ - ∞ = NaN
            invalid <= 1'b1;
        end else if (a_inf) begin
            result <= {a_sign, 8'hFF, 23'h0}; // 返回a的无穷大
        end else if (b_inf) begin
            result <= {b_sign, 8'hFF, 23'h0}; // 返回b的无穷大
        end else begin
            // 正常结果
            result <= {a_sign, exp_norm, frac_rounded[22:0]};
            invalid <= 1'b0;
        end
    end
end

endmodule