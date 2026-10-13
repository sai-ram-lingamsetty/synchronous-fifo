`timescale 1ns/1ps
//Assumed depth will be in powers of 2
module fifo #(parameter DEPTH = 16,parameter WIDTH = 8,parameter THRESHOLD = 2)(
    input clk,rst,wr_en,rd_en,
    input  [WIDTH-1:0] wr_data,
    output reg [WIDTH-1:0] rd_data,
    output almost_full,almost_empty,
    output empty,full
);
    localparam SIZE = $clog2(DEPTH);
    reg [WIDTH-1:0] mem [DEPTH-1:0];
    reg [SIZE:0] wr_ptr,rd_ptr;
    wire [SIZE:0] occupancy;
    wire wr_allow,rd_allow;
    
    assign occupancy = wr_ptr - rd_ptr;
    assign empty = (occupancy == 'b0);
    assign wr_allow = wr_en && (!full);
    assign rd_allow = rd_en && (!empty);
    assign full = (occupancy == DEPTH);  
    assign almost_empty = (occupancy <= THRESHOLD);
    assign almost_full = (occupancy >= DEPTH - THRESHOLD);   
    
    always@(posedge clk) begin
        if(rst) begin
            rd_ptr <= 'b0;
            wr_ptr <= 'b0;
            rd_data <= 'b0;
        end else begin
            if(wr_en && rd_en && empty) begin
                rd_data <= wr_data;
            end else if(wr_en && rd_en && full)begin
                rd_data <= mem[rd_ptr[SIZE-1:0]];
                mem[wr_ptr[SIZE-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
                rd_ptr <= rd_ptr + 1'b1;
            end else begin
                wr_ptr <= wr_allow ? (wr_ptr + 'b1) : wr_ptr;
                rd_ptr <= rd_allow ? (rd_ptr + 'b1) : rd_ptr;
                if(wr_allow) begin
                    mem[wr_ptr[SIZE-1:0]] <= wr_data;
                end 
                if(rd_allow) begin
                    rd_data <= mem[rd_ptr[SIZE-1:0]];
                end
            end
        end
    end
    
endmodule