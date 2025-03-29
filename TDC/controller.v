module controller(
    input sys_clk,

    //TDC
    input [7:0] ones,

    //GPIO
    input [1:0] gpio2_io_o,
    output reg [1:0] gpio_io_i,

    //Booth
    input booth_start,      //确保TDC采样与Booth运行完全同步
    input booth_end,
    output reg finish,

    //RAM Port
    output clkb,
    input [7:0] rd_data,
    output reg enb,
    output rstb,
    output reg [13:0] addrb,     //BRAM address +1         
    output reg [7:0] datab,     //BRAM DATA     total:16384
    output reg  web    
);

assign clkb = sys_clk;
assign rstb = 1'b0;

// 状态定义
parameter INIT = 3'b000,   
          IDLE = 3'b001,
          RUNNING = 3'b010,  
          Booth_RUN = 3'b110,
          Booth_END = 3'b111,      
          RUN_DONE = 3'b011,
          CLEAR = 3'b100,
          CLR_DONE = 3'b101;


reg [2:0] state;

wire run , clr;
reg rdy , full;
assign run = gpio2_io_o[0];
assign clr = gpio2_io_o[1];

reg [1:0] split_counter;    //用于Booth_END状态时，产生连续的4个99作为各个波形段之间的分隔符

always @(posedge sys_clk) begin
    case(state)
        INIT        :   begin
            state   <=  IDLE;
            addrb   <=  14'd0;
            datab   <=  8'd0;
            web     <=  0;
            rdy     <=  0;
            full    <=  0;
            finish  <=  0;      //添加finish信号
            split_counter   <=  0;
        end
        IDLE        :   begin
            if(run)begin
                state   <=  RUNNING;
                enb     <=  1;
                web     <=  1;
            end
            if(clr)begin
                state   <=  CLEAR;
                enb     <=  1;
                web     <=  1;
            end
            rdy     <=  1;
        end
        RUNNING     :   begin
            finish  <=  0;      //在running阶段，应保持booth操作数稳定，故finish置0
            rdy     <=  0;
            state   <= (booth_start) ? Booth_RUN : RUNNING;
        end
        Booth_RUN   :   begin
            if(booth_end) begin     //booth运算结束，且booth_start 与 booth_end不会同时为1
                state   <=  Booth_END;
                split_counter   <=  2'b0;
            end
            else begin
                if(addrb    ==  14'b11_1111_1111_1110) begin
                    state   <=  RUN_DONE;
                    full    <=  1;
                end
                else if(ones != 8'b0) begin
                    datab   <= ones;
                    addrb   <= addrb + 1;
                end
            end
        end

        Booth_END   :   begin
            if(addrb == 14'b11_1111_1111_1110) begin
                state   <=  RUN_DONE;
                full    <=  1;
                split_counter   <=  0;
            end
            else begin
                if(split_counter == 2'd3) begin
                    state   <=  RUNNING;
                    datab   <=  8'd99;
                    addrb   <=  addrb + 1;
                    split_counter   <=  0;
                end
                else begin
                    datab   <=  8'd99;
                    addrb   <=  addrb + 1;
                    split_counter   <=  split_counter + 1;
                end
            end
        end
        RUN_DONE    :   begin
            web     <=  0;
            datab   <=  4'd0;
            rdy     <=  0;
            enb     <=  0;
            if(!run)
                state   <=  INIT;
        end
        CLEAR       :   begin
            finish  <=  1;          //在bram清零阶段，将finish信号置一，以提前改变booth乘法器的操作数
            rdy     <=  0;
            datab   <=  0;
            if(addrb    ==  14'b11_1111_1111_1110)begin
                state   <=  CLR_DONE;
                full    <=  0;
            end
            else begin
                addrb   <=  addrb    +   1;
                full    <=  1;
            end
        end
        CLR_DONE    :   begin
            web     <=  0;
            rdy     <=  0;
            enb     <=  0;
            if(!clr)
                state   <=  INIT;
        end
        default     :   state   <=  INIT;
    endcase    

    gpio_io_i[0]    <=  rdy;
    gpio_io_i[1]    <=  full;
end
endmodule
