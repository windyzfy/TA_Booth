module delayline #(
    parameter Nstages = 4,        //LUT2 + LDCE stages
    parameter Ntaps = 96          //CARRY4  taps
)(
    input clk,                  //sampling on rising edge       350MHZ

    input hit,                  //clock posedge

    input clear,                //next clock posedge

    output wire [Ntaps - 1 : 0]    thermo 
);
    wire [Nstages - 1 : 0] LUT_LDCE_chain;       //LUT2 + LDCE output

    wire [Ntaps - 1 : 0] carryOut;              //CARRY chain output

    wire [Ntaps - 1 : 0] metaThermo;            //avoid Metasteasis

    wire hit_CARRY;     //hit the carry chain

genvar i;
(* dont_touch="true" *) generate
	for (i = 0; i < Nstages/2 ; i = i + 1) begin
		if(i == 0) begin :Delay_first
			LUT2 #(
                .INIT(4'h2)  // Specify LUT Contents
            ) LUT2_inst (
               .O(LUT_LDCE_chain[0]),       // LUT general output
               .I0(hit),     // hit   input
               .I1(clear)      // clear input
            );
            LDCE #(
                .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDCE_inst (
               .Q(LUT_LDCE_chain[1]),      // Data output
               .CLR(clear),  // Asynchronous clear/reset input
               .D(LUT_LDCE_chain[0]),      // Data input
               .G(1'b1),      // Gate input
               .GE(1'b1)     // Gate enable input
            );
		end
		if (i > 0) begin :Delay_others
			LUT2 #(
                .INIT(4'h2)  // Specify LUT Contents
            ) LUT2_others (
               .O(LUT_LDCE_chain[2*i]),       // LUT general output
               .I0(LUT_LDCE_chain[2*i-1]),        //the last latch output as the input data
               .I1(clear)      // clear input
            );
            LDCE #(
                .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDCE_others (
               .Q(LUT_LDCE_chain[2*i+1]),      // Data output
               .CLR(clear),  // Asynchronous clear/reset input
               .D(LUT_LDCE_chain[2*i]),      // Data input
               .G(1'b1),      // Gate input
               .GE(1'b1)     // Gate enable input
            );
		end
	end
endgenerate

LDCE #(
    .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
) LDCE_inst_1 (
   .Q(hit_CARRY),      // Data output
   .CLR(clear),  // Asynchronous clear/reset input
   .D(LUT_LDCE_chain[Nstages - 1]),      // Data input
   .G(1'b1),      // Gate input
   .GE(1'b1)     // Gate enable input
);

genvar k;
(* dont_touch="true" *) generate
	for (k = 0; k <= Ntaps/4 - 1; k = k+1) begin
		if(k == 0) begin :carry4_first
			CARRY4 CARRY4_INST (
				.CO				(carryOut[3:0]),      			// 4-bit carry out
				.O				(),           				// 4-bit carry chain XOR data out
				.CI				(1'b0),         			// 1-bit carry cascade input
				.CYINIT			(hit_CARRY), 				// 1-bit carry initialization
				.DI				(4'b0000),      			// 4-bit carry-MUX data in
				.S				(clear ? 4'b0000:4'b1111)       			// 4-bit carry-MUX select input
			);
		end
		if (k > 0) begin :carry4_others
			CARRY4 CARRY4_OTHERS (
				.CO				({carryOut[4*k+3], carryOut[4*k+2], carryOut[4*k+1],carryOut[4*k]}),	// 4-bit carry out
				.O				(),           				// 4-bit carry chain XOR data out
				.CI				(carryOut[4*k-1]),       	// 1-bit carry cascade input
				.CYINIT			(1'b0), 					// 1-bit carry initialization
				.DI				(4'b0000),      			// 4-bit carry-MUX data in
				.S				(clear ? 4'b0000:4'b1111)       			// 4-bit carry-MUX select input
			);
		end
	end
endgenerate

genvar j;
(* dont_touch="true" *) generate 
	for (j = 0; j < Ntaps ; j = j + 1) begin
		FDCE #(
			.INIT				(1'b0) 						// Initial value of register (1'b0 or 1'b1)
        ) FDCE_INST_meta (			
			.Q					(metaThermo[j]),   			// 1-bit Data output
			.C					(clk),      			// 1-bit Clock input
			.CE					(1'b1), 					// 1-bit Clock enable input
			.CLR				(1'b0),  					// 1-bit Synchronous reset input
			.D					(carryOut[j])    			// 1-bit Data input
		);
		
		FDCE #(
			.INIT				(1'b0) 						// Initial value of register (1'b0 or 1'b1)
        ) FDCE_INST_final (		
			.Q					(thermo[j]),			// 1-bit Data output
			.C					(clk),      			// 1-bit Clock input
			.CE					(1'b1),    					// 1-bit Clock enable input
			.CLR				(1'b0),      				// 1-bit Synchronous reset input
			.D					(metaThermo[j])       			// 1-bit Data input
		);
	end
endgenerate


endmodule