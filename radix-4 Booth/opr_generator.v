module opr_generator(
    input clk,
    input rst_n,

    input finish,

    output reg [31:0] operator
);
    wire    change;
    reg     meta_finish;
    reg     meta_finish_2;
    always @(posedge clk) begin
        meta_finish <=  finish;
        meta_finish_2   <=  meta_finish;
    end
    assign change = meta_finish && (~meta_finish_2);    //finish上升沿捕获
    
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            operator   <=  0;
        end    
        else begin
            if(change)
                operator    <=  operator + 1;
            else
                operator    <=  operator;
        end
    end

endmodule