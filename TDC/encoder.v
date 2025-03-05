module encoder #(
    parameter Ntaps = 96
)(
    input clk,
    input [Ntaps - 1 : 0] thermo,

    output reg  [7:0]   ones   
);
//expand thermo to 48bits
localparam BITS_WIDTH = 96;
wire [BITS_WIDTH-1 : 0] thermo_expand;
assign thermo_expand = { {(BITS_WIDTH - Ntaps){1'b0}}, thermo };
wire [7:0]  adder_out;
//输入LUT6，统计1的个数
localparam NLUTs = BITS_WIDTH / 6;
wire [NLUTs*3-1:0] LUTout;      //LUT6统计结果，3位为一组,共8组
generate
    genvar i;
    for (i = 0; i < NLUTs; i = i + 1) begin : LUTs
        LUT6 #(
            .INIT(64'h6996966996696996)  
        ) LUT6_inst0 (
            .O(LUTout[3*i]),          
            .I0(thermo_expand[6*i]), 
            .I1(thermo_expand[6*i+1]), 
            .I2(thermo_expand[6*i+2]), 
            .I3(thermo_expand[6*i+3]),
            .I4(thermo_expand[6*i+4]), 
            .I5(thermo_expand[6*i+5])  
        );

        LUT6 #(
            .INIT(64'h8117177E177E7EE8)  // inst1?????????
        ) LUT6_inst1 (
            .O(LUTout[3*i+1]),          
            .I0(thermo_expand[6*i]), // LUT input
            .I1(thermo_expand[6*i+1]), // LUT input
            .I2(thermo_expand[6*i+2]), // LUT input
            .I3(thermo_expand[6*i+3]), // LUT input
            .I4(thermo_expand[6*i+4]), // LUT input
            .I5(thermo_expand[6*i+5])  // LUT input       
        );

        LUT6 #(
            .INIT(64'hFEE8E880E8808000)  // inst2?????????
        ) LUT6_inst2 (
            .O(LUTout[3*i+2]),          
            .I0(thermo_expand[6*i]), // LUT input
            .I1(thermo_expand[6*i+1]), // LUT input
            .I2(thermo_expand[6*i+2]), // LUT input
            .I3(thermo_expand[6*i+3]), // LUT input
            .I4(thermo_expand[6*i+4]), // LUT input
            .I5(thermo_expand[6*i+5])  // LUT input    
        );
    end
endgenerate

adderTreeLegacy #(
    .INPUTS(NLUTs),
    .BITS(3),
    .LEVEL(4),
    .Y_OUT_LEN(8)
) adder_tree (
    .x_in(LUTout),
    .y_out(adder_out)
);

always @(posedge clk) begin
    ones <= adder_out;
end


endmodule