/*同步器（sync），用于在目标时钟（target_clk）域中同步异步输入信号（asyn）。*/
module sync(
    input target_clk,
    input asyn, //异步输入信号
    output reg sync     //同步到目标时钟域上的输出信号
);

reg meta_syn;   //中间寄存器

always @(posedge target_clk) begin
    meta_syn <= asyn;
    sync <= meta_syn;
end


endmodule