module signal_generator(
    input clk,         
    input rst_n,

(* dont_touch="true" *)    output reg hit,
(* dont_touch="true" *)    output reg clear
);

    parameter idle = 0 , Hit_state = 1 , Clear_state = 2;

    reg [1:0] state;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state   <=  idle;
            hit     <=  0;
            clear   <=  0;
        end
        else begin 
            case(state)
                idle    :   begin
                    hit     <=  0;
                    clear   <=  0;
                    state   <=  Hit_state;  
                end
                Hit_state   :   begin 
                    hit     <=  1;
                    clear   <=  0;
                    state   <=  Clear_state;
                end
                Clear_state :   begin
                    hit     <=  0;
                    clear   <=  1;
                    state   <=  Hit_state;                   
                end
                default     :   begin
                    hit     <=  0;
                    clear   <=  0;
                    state   <=  idle;
                end
            endcase
        end
    end

endmodule   
