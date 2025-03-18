module Booth_tb();

    // 时钟和复位信号
    reg clk;
    reg rst_n;
    reg finish;
    wire [63:0] result;

    // 实例化Booth模块
    Booth u_booth(
        .clk(clk),
        .rst_n(rst_n),
        .finish(finish),
        .result(result)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz时钟
    end

    // 测试激励
    initial begin
        // 初始化信号
        rst_n = 1;
        finish = 0;
        
        // 等待100ns后释放复位
        #20 rst_n = 0;
        #20 rst_n = 1;
        
        // 等待100ns后开始测试
        #100;
        
        // 生成finish信号
        repeat(16) begin
            finish = 1;
            #10;
            finish = 0;
            #310;  // 等待一个完整的32周期
        end
        
        // 额外等待一些时间观察结果
        #1000;
        
        // 结束仿真
        $finish;
    end

    // 监控结果
    initial begin
        $monitor("Time=%0t rst_n=%b finish=%b result=%h", 
                 $time, rst_n, finish, result);
    end

    // 波形记录
    initial begin
        $dumpfile("Booth_tb.vcd");
        $dumpvars(0, Booth_tb);
    end

endmodule