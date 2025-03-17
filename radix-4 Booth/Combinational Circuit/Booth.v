module Booth #(
    parameter WIDTH = 32
)(
    input clk,
    input rst_n,
    input finish,
    output [(WIDTH*2)-1:0] result
);

    // 12个时钟周期的计数器
    reg [3:0] counter;
    reg [WIDTH-1:0] mult_input;

    // 内部操作数寄存器及finish信号同步逻辑
    reg [WIDTH-1:0] operator;
    reg meta_finish, meta_finish_2;
    wire change;

    always @(posedge clk) begin
        meta_finish <= finish;
        meta_finish_2 <= meta_finish;
    end
    assign change = meta_finish && (~meta_finish_2);    //finish上升沿捕获

    // operator自增逻辑
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            operator <= 0;
        end else begin
            if(change)
                operator <= operator + 1;
            else
                operator <= operator;
        end
    end

    // 计数器逻辑
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            counter <= 4'd0;
        end else begin
            if(counter == 4'd11)
                counter <= 4'd0;
            else
                counter <= counter + 1'b1;
        end
    end

    // 控制乘数输入
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mult_input <= 0;
        end else if(counter == 4'd0) begin
            mult_input <= operator;
        end else begin
            mult_input <= 0;
        end
    end

    // 实例化radix-4 Booth乘法器
    radix_4_booth #(
        .WIDTH(WIDTH),
        .multiplicand(32'h55555555)  // 固定被乘数
    ) u_radix_4_booth (
        .multiplier(mult_input),
        .Result(result)
    );

endmodule