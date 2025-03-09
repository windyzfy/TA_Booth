module Top_TDC #(
    parameter   Nstages =   4,
    parameter   Ntaps   =   64      //延迟线参数，需调试
)(
    input   clk,    //300MHZ
    input   rst_n,
    //booth
    output  finish,
    //GPIO
    input   [1:0] gpio2_io_o,
    output  [1:0] gpio_io_i,
    //RAM
    output clkb,
    input   [31:0] rd_data,
    output  enb,
    output  rstb,
    output  [14:0] addrb,
    output  [31:0] datab,
    output  [3:0]   web   
);

    //inside    signal
    wire    [7:0]  ones;
    wire    [Ntaps-1:0] thermo;
    wire    hit;
    wire    clear;

    //signal_generator
    signal_generator  u_generator(
        .clk(clk),
        .rst_n(rst_n),

        .hit(hit),
        .clear(clear)
    );
    //delayline
    delayline #(
        .Nstages(Nstages),
        .Ntaps(Ntaps)
    ) u_delayline(
        .clk(clk),
        .hit(hit),
        .clear(clear),
        
        .thermo(thermo)
    );
    //encoder
    encoder #(
        .Ntaps(Ntaps)
    ) u_encoder(
        .clk(clk),
        .thermo(thermo),

        .ones(ones)
    );
    
    //Controller
    controller u_controller(
        .sys_clk(clk),
        .ones(ones),
        
        //GPIO
        .gpio2_io_o(gpio2_io_o),
        .gpio_io_i(gpio_io_i),

        //booth
        .finish(finish),
        
        //BRAM
        .clkb(clkb),
        .rd_data(rd_data),
        .enb(enb),
        .rstb(rstb),
        .addrb(addrb),
        .datab(datab),
        .web(web)
    );



endmodule