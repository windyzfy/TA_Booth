module radix_4_booth #(
    parameter WIDTH = 8,
    parameter multiplicand = 8'h55  //固定被乘数
)(
    input [WIDTH-1:0] multiplier,

    output wire [2*WIDTH-1:0] Result
);

    //预处理数据
    wire [WIDTH : 0] mul_expand;             //被乘数符号扩展一位 
    wire [WIDTH : 0] neg_M;                  //被乘数的负补码
    wire [WIDTH : 0] double_M;               //被乘数的2倍
    wire [WIDTH : 0] neg_double_M;           //被乘数的负2倍补码

    assign mul_expand = {multiplicand[WIDTH-1], multiplicand};
    assign neg_M = ~{multiplicand[WIDTH-1], multiplicand} + 1'b1;
    assign double_M = {multiplicand[WIDTH-1], multiplicand} << 1;
    assign neg_double_M = (~{multiplicand[WIDTH-1], multiplicand} + 1'b1) << 1;

    
    reg [WIDTH:0] partial_products [WIDTH/2-1:0];  //存储所有部分积 ， 共WIDTH/2个，对应Booth2算法运算量减半
    wire [2*WIDTH-1:0] shifted_results [WIDTH/2-1:0];   //对部分积进行移位处理

    wire [2*WIDTH-1:0] final_sum;           //部分积累加结果

    //部分积生成及存储
    genvar i;
    generate
        for(i = 0 ; i < WIDTH/2 ; i = i + 1) begin
            wire [2:0] Mode;    //运算模式  0 +1M +2M -2M -1M
            if(i == 0) begin
                assign Mode = op_mode({multiplier[1:0], 1'b0});
            end else begin
                assign Mode = op_mode({multiplier[2*i +: 2], multiplier[2*i-1]});
            end

            always @(*) begin
                case(Mode)
                    3'b000: 
                        partial_products[i] = {(WIDTH+1){1'b0}};
                    3'b001:
                        partial_products[i] = mul_expand;
                    3'b010:
                        partial_products[i] = double_M;
                    3'b011:
                        partial_products[i] = neg_double_M;
                    3'b100:
                        partial_products[i] = neg_M;
                    default:
                        partial_products[i] = {(WIDTH+1){1'b0}};
                endcase    
            end
            //部分积移位
            assign shifted_results[i] = {{WIDTH{partial_products[i][WIDTH]}}, partial_products[i]} << (2*i);            
        end

    endgenerate

// 使用加法树结构
    generate
        if (WIDTH == 2) begin
            assign final_sum = shifted_results[0];
        end else begin
            wire [2*WIDTH-1:0] sum_tree [WIDTH/2-2:0];
            
            // 第一级加法
            assign sum_tree[0] = shifted_results[0] + shifted_results[1];
            
            // 生成加法树
            for (i = 1; i < WIDTH/2-1; i = i + 1) begin : gen_sum_tree
                assign sum_tree[i] = sum_tree[i-1] + shifted_results[i+1];
            end
            
            // 最终结果
            assign final_sum = sum_tree[WIDTH/2-2];
        end
    endgenerate

    assign Result = final_sum;
    

    function [2:0] op_mode;
        input   [2:0]   mul_3;
        begin
            case(mul_3)
                3'b000,3'b111:
                    op_mode = 3'b000;       // 0
                3'b001,3'b010:
                    op_mode = 3'b001;       // +1M
                3'b011:
                    op_mode = 3'b010;       // +2M
                3'b100:
                    op_mode = 3'b011;       // -2M
                3'b101,3'b110:
                    op_mode = 3'b100;       // -1M
                default:
                    op_mode = 3'b000;
            endcase
        end
        
    endfunction


endmodule