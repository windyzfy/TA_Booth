module Booth_tb();
    // 信号定义
    reg clk;
    reg rst_n;
    reg finish;
    wire [63:0] result;

    // 实例化被测模块
    Booth u_Booth(
        .clk(clk),
        .rst_n(rst_n),
        .finish(finish),
        .result(result)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 测试激励
    initial begin
        // 初始化信号
        rst_n = 1;
        finish = 0;
        
        // 复位
        #10 rst_n = 0;
        #20 rst_n = 1;

        // 等待一段时间后开始测试
        #100;
        
        // 测试自增功能
        repeat(5) begin
            @(posedge clk);
            finish = 1;
            @(posedge clk);
            finish = 0;
            // 等待完整的乘法计算周期（20个时钟周期）(实际上更大)
            repeat(20) @(posedge clk);
        end

        // 结束仿真
        #100;
        $finish;
    end

endmodule 