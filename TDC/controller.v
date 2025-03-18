module controller(
    input sys_clk,

    //TDC
    input [7:0] ones,

    //GPIO
    input [1:0] gpio2_io_o,
    output reg [1:0] gpio_io_i,

    //Booth
    output reg finish,

    //RAM Port
    output clkb,
    input [31:0] rd_data,
    output reg enb,
    output rstb,
    output reg [14:0] addrb,     //BRAM address +4
    output reg [31:0] datab,     //BRAM DATA
    output reg [3:0] web    
);



assign clkb = sys_clk;
assign rstb = 1'b0;

// 状态定义
parameter INIT = 3'b000,   
          IDLE = 3'b001,
          RUNNING = 3'b010,        
          RUN_DONE = 3'b011,
          CLEAR = 3'b100,
          CLR_DONE = 3'b101;


reg [2:0] state;

wire run , clr;
reg rdy , full;
assign run = gpio2_io_o[0];
assign clr = gpio2_io_o[1];

always @(posedge sys_clk) begin
    case(state)
        INIT        :   begin
            state   <=  IDLE;
            addrb   <=  15'd0;
            datab   <=  32'd0;
            web     <=  4'd0;
            rdy     <=  0;
            full    <=  0;
            finish  <=  0;      //添加finish信号
        end
        IDLE        :   begin
            if(run)begin
                state   <=  RUNNING;
                enb     <=  1;
                web     <=  4'b1111;
            end
            if(clr)begin
                state   <=  CLEAR;
                enb     <=  1;
                web     <=  4'b1111;
            end
            rdy     <=  1;
        end
        RUNNING     :   begin
            finish  <=  0;      //在running阶段，应保持booth操作数稳定，故finish置0

            if(addrb    ==  15'b111_1111_1111_1100)begin
                state   <=  RUN_DONE;
                full    <=  1;
            end
            else begin
                rdy     <=  0;
                if(ones != 8'b0) begin
                    datab   <=  {{24{1'b0}} , ones};
                    addrb   <=  addrb    +   15'd4;
                end
            end
        end
        RUN_DONE    :   begin
            web     <=  4'd0;
            datab   <=  32'd0;
            rdy     <=  0;
            enb     <=  0;
            if(!run)
                state   <=  INIT;
        end
        CLEAR       :   begin
            finish  <=  1;          //在bram清零阶段，将finish信号置一，以提前改变booth乘法器的操作数

            rdy     <=  0;
            datab   <=  0;
            if(addrb    ==  15'b111_1111_1111_1100)begin
                state   <=  CLR_DONE;
                full    <=  0;
            end
            else begin
                addrb   <=  addrb    +   15'd4;
                full    <=  1;
            end
        end
        CLR_DONE    :   begin
            web     <=  4'd0;
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
