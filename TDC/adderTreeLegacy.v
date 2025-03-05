module adderTreeLegacy #(
    parameter INPUTS = 4,   
    parameter BITS = 3,     
    parameter LEVEL = 2,    
    parameter Y_OUT_LEN = 5 
)(
    input [INPUTS*BITS-1:0] x_in,
    output wire [Y_OUT_LEN-1:0] y_out
);

generate
    if(LEVEL > 1) begin: RECURSE

        reg [((INPUTS+1)/2)*(BITS+1)-1:0] nxt_x;
        reg [BITS:0] sum[0:(INPUTS+1)/2-1]; 

        integer i;
        always @(*) begin
             for (i = 0; i < INPUTS/2; i = i + 1) begin
                sum[i] = x_in[(2*(i+1))*BITS-1 -: BITS] + x_in[2*i*BITS +: BITS];
                nxt_x[i*(BITS+1) +: (BITS+1)] = sum[i];
            end
        end
        adderTreeLegacy #(
            .INPUTS((INPUTS+1)/2),
            .BITS(BITS + 1),
            .LEVEL(LEVEL - 1),
            .Y_OUT_LEN(Y_OUT_LEN)
        ) next_level (
            .x_in(nxt_x),
            .y_out(y_out)
        );
    end
    else begin: END_CONDITION
        reg [((INPUTS+1)/2)*(BITS+1)-1:0] nxt_x;
        reg [BITS:0] sum[0:(INPUTS+1)/2-1]; 

        integer i;
        always @(*) begin
             for (i = 0; i < INPUTS/2; i = i + 1) begin
                sum[i] = x_in[(2*(i+1))*BITS-1 -: BITS] + x_in[2*i*BITS +: BITS];
                nxt_x[i*(BITS+1) +: (BITS+1)] = sum[i];
            end
        end

        assign y_out = nxt_x;
    end
endgenerate

endmodule