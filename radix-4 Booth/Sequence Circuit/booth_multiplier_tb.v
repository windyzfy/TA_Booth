module booth_multiplier_tb;

// 参数定义
parameter N = 32;

// 信号定义
reg clk;
reg rst_n;
reg start;
reg [N-1:0] multiplier;
wire [2*N-1:0] product;
wire done;

// 实例化被测模块
radix_4_booth #(
    .N(N),
    .multiplicand(32'h5555_5555)
) u_radix_4_booth (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .multiplier(multiplier),
    .product(product),
    .done(done)
);

// 时钟生成
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns周期
end

// 测试激励
initial begin
    // 初始化信号
    rst_n = 1;
    start = 0;
    multiplier = 0;
    
    // 等待100ns
    #100;
    
    // 复位
    rst_n = 0;
    #20;
    rst_n = 1;
    #20;
    
    // 测试用例1：正数相乘
    $display("测试用例1：正数相乘");
    multiplier = 32'h0000_0003;  // 3
    start = 1;
    #10;
    start = 0;
    wait(done);
    #20;
    $display("3 * 0x55555555 = %h", product);
    
    // 测试用例2：负数相乘
    $display("\n测试用例2：负数相乘");
    multiplier = 32'hFFFF_FFFD;  // -3
    start = 1;
    #10;
    start = 0;
    wait(done);
    #20;
    $display("-3 * 0x55555555 = %h", product);
    
    // 测试用例3：大数相乘
    $display("\n测试用例3：大数相乘");
    multiplier = 32'hFFFF_FFFF;  // -1
    start = 1;
    #10;
    start = 0;
    wait(done);
    #20;
    $display("-1 * 0x55555555 = %h", product);
    
    // 测试用例4：零相乘
    $display("\n测试用例4：零相乘");
    multiplier = 32'h0000_0000;  // 0
    start = 1;
    #10;
    start = 0;
    wait(done);
    #20;
    $display("0 * 0x55555555 = %h", product);
    
    // 结束仿真
    #100;
    $display("\n仿真结束");
    $finish;
end

// 监控输出
initial begin
    $monitor("Time=%0t rst_n=%b start=%b multiplier=%h product=%h done=%b",
             $time, rst_n, start, multiplier, product, done);
end

endmodule