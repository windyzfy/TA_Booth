module radix_4_booth #(
    parameter WIDTH = 8,
    parameter multiplicand = 8'h55  //固定被乘数
)(
    input [WIDTH-1:0] multiplier,
    output reg [2*WIDTH-1:0] Result
);

    reg [2*WIDTH:0] A_reg;     // 被乘数寄存器，多扩展1位用于符号
    reg [2*WIDTH:0] M_reg;     // 乘数寄存器，多扩展1位用于Booth编码
    reg [2*WIDTH:0] P;         // 部分积寄存器
    reg [2*WIDTH:0] temp;      // 临时寄存器，用于补码计算
    
    integer i;
    
    always @(*) begin
        // 初始化寄存器
        A_reg = {{(WIDTH+1){multiplicand[WIDTH-1]}}, multiplicand};  // 被乘数符号扩展
        M_reg = {multiplier, 1'b0};                                  // 乘数后补0
        P = 0;
        
        // Radix-4 Booth算法
        for(i = 0; i < WIDTH; i = i + 2) begin
            // 计算移位后的值
            temp = A_reg << i;
            
            case({M_reg[2:0]})  // 检查3位
                3'b000, 3'b111: begin  // +0
                    // 不做操作
                end
                3'b001, 3'b010: begin  // +1
                    P = P + temp;
                end
                3'b011: begin          // +2
                    P = P + (temp << 1);
                end
                3'b100: begin          // -2 (使用补码加法)
                    P = P + (~(temp << 1) + 1'b1);
                end
                3'b101, 3'b110: begin  // -1 (使用补码加法)
                    P = P + (~temp + 1'b1);
                end
                default: begin
                    // 不做操作
                end
            endcase
            
            // 右移2位，为下一次编码做准备
            M_reg = {2'b00, M_reg[2*WIDTH:2]};
        end
        
        // 最终结果
        Result = P[2*WIDTH-1:0];
    end

endmodule