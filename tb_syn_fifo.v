`timescale 1ns/1ps
module syn_fifo_tb#(parameter DEPTH = 16, WIDTH = 8, THRESHOLD = 2)();
    reg clk,rst,wr_en,rd_en;
    reg  [WIDTH-1:0] wr_data;
    wire [WIDTH-1:0] rd_data;
    wire almost_full,almost_empty;
    wire empty,full;
    
    initial begin 
        $dumpfile("fifo.vcd");
        $dumpvars(0, syn_fifo_tb);
    end
    
    initial begin 
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
    end
    
    always #5 clk = ~clk;
    always @(negedge clk) wr_data <= $urandom;
    
    fifo #(.DEPTH(DEPTH), .WIDTH(WIDTH), .THRESHOLD(THRESHOLD)) DUT(.clk(clk),.rst(rst),.wr_en(wr_en),.rd_en(rd_en),.wr_data(wr_data),.rd_data(rd_data),.almost_full(almost_full),.almost_empty(almost_empty),.empty(empty),.full(full));
    
    initial begin
        //wait
        #10;rst = 0;
        
        //1.write overflow
        @(negedge clk)wr_en = 1;rd_en = 0;
        #200;
        
        //2.read underflow
        @(negedge clk)wr_en = 0;rd_en = 1;
        #200;
        
        //3.simultaneous read and write when empty
        @(negedge clk)wr_en = 1;rd_en = 1;
        #200;
        
        //4.few writes and then read
        @(negedge clk)wr_en = 1;rd_en = 0;
        #115;
        @(negedge clk)wr_en = 0;rd_en = 1;
        #85;
        
        //5.simultaneous read and write with some occupancy
        @(negedge clk)wr_en = 1;rd_en = 1;
        #200;
        
        //6.simultaneous read and write when full
        
        //full the fifo
        @(negedge clk)wr_en = 1;rd_en = 0;
        #200;
        
        //now check
        @(negedge clk)wr_en = 1;rd_en = 1;
        #200;
        
        //7.reset in the middle of operation
        @(negedge clk) wr_en = 1; rd_en = 0;
        #200;                              
        @(negedge clk) rst = 1; wr_en = 0; rd_en = 0;
        @(negedge clk) rst = 0;
        #40;                        
        
        $finish;
    end 
    
endmodule