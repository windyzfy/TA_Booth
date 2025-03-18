module booth_multiplier_array #(
    parameter NUM_UNITS = 32,  // 阵列规模
    parameter N = 32,           //乘法器位宽
    parameter multiplicand = 32'h5555_5555  //固定被乘数
)(
    input  clk,
    input  rst_n,
    input  start,

    input  [N-1:0] multiplier,
    output [2*N-1:0] products,
    output done
);

    // 内部信号
    wire [NUM_UNITS-1:0] done_array;
    wire [2*N-1:0] dummy_results [NUM_UNITS-1:0];
    // Booth 乘法器阵列实例化
    genvar i;
    generate
        for (i = 0; i < NUM_UNITS; i = i + 1) begin : booth_array
            (* keep = "true" *) radix4_booth #(
                .N(N),
                .multiplicand(multiplicand)
            ) booth_unit (
                .clk(clk),
                .rst_n(rst_n),
                .start(start),
                .multiplier(multiplier),
                .product(dummy_results[i]),
                .done(done_array[i])
            );
        end
    endgenerate

    //选择一个乘法器作为输出，同时避免vivado优化
    reg [5:0] counter;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            counter <= 6'd0;
        end 
        else begin
            if(start) begin
                counter <= counter + 6'd1;
            end
            else begin
                counter <= counter;
            end
    end
    end
    // 输出赋值
    assign done = &done_array;  // 所有乘法器 done 才输出 done

    assign product = dummy_results[counter];

endmodule
