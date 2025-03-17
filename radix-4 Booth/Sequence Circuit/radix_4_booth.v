module radix_4_booth #(
    parameter N = 32,
    parameter multiplicand = 32'h5555_5555
    ) (
    input  clk,              // 时钟信号
    input  rst_n,            // 复位信号
    input  start,            // 开始信号
    input  [N-1:0] multiplier,    // 乘数
    output reg [2*N-1:0] product,     // 乘积结果
    output reg done                   // 计算完成标志
);

    reg [N:0] extended_multiplier;    // 扩展的乘数（用于Booth编码）
    reg [2*N-1:0] partial_sum;        // 部分和
    reg [2*N-1:0] partial_product;    // 部分积
    reg [3:0] state;                  // 状态机状态
    reg [4:0] counter;                // 计数器（用于控制迭代次数）

    // 状态定义
    localparam IDLE = 4'b0000;        // 空闲状态
    localparam CALC = 4'b0001;        // 计算状态
    localparam DONE = 4'b0010;        // 完成状态

    //Booth编码
    wire [2:0] Booth_code;
    assign Booth_code = (extended_multiplier >> (2 * counter)) & 3'b111;

    // Booth解码的case语句
    always @(*) begin
        case (Booth_code)
            3'b000, 3'b111: partial_product = 0;          // 无操作
            3'b001, 3'b010: partial_product = multiplicand; // +M
            3'b011: partial_product = multiplicand << 1;    // +2M
            3'b100: partial_product = ~(multiplicand << 1) + 1; // -2M
            3'b101, 3'b110: partial_product = ~multiplicand + 1; // -M
            default: partial_product = 0;
        endcase
        partial_product = partial_product << (2*counter);  // 根据位置左移
    end

    // 状态机
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            product <= 0;
            done <= 0;
            counter <= 0;
            partial_sum <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        extended_multiplier <= {multiplier, 1'b0}; // 扩展乘数
                        partial_sum <= 0;
                        counter <= 0;
                        state <= CALC;
                        done <= 0;
                    end
                end

                CALC: begin
                    if (counter < N/2) begin
                        partial_sum <= partial_sum + partial_product; // 累加部分积
                        counter <= counter + 1; // 更新计数器
                    end else begin
                        state <= DONE; // 计算完成
                    end
                end

                DONE: begin
                    product <= partial_sum; // 输出最终结果
                    done <= 1;              // 设置完成标志
                    state <= IDLE;         // 回到空闲状态
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule