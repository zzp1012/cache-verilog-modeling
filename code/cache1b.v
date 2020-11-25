`timescale 1ns / 1ps

module cache1b(
    output reg                      out_row,
    output reg                      hit_or_miss, // 1 means hit, 0 means miss
    output reg  [9:0]               out_addr,
    output reg  [127:0]             out_write_data,
    output reg  [7:0]               out_read_data,
    input                           in_row,
    input       [9:0]               in_addr,
    input       [7:0]               in_write_data,
    input       [127:0]             in_read_data
    );
    
    parameter block_size    = 128;
    parameter tag_size      = 5;
    parameter addr_size     = 10;
    parameter block_num     = 4;
    parameter byte          = 8;

    reg     [block_size - 1:0]  cache_mem[block_num-1:0];
    reg     [tag_size - 1:0]    tags[block_num - 1:0];
    reg                         valid[block_num - 1:0];
    reg                         unused[block_num - 1:0];

    integer                     n;

    initial begin
        for (n = 0; n < block_num; n = n + 1) begin
            cache_mem[n]    = 0;
            valid[n]        = 0;
            tags[n]         = 0;
            unused[n]       = 1;
        end

        out_row             = 'bz;
        hit_or_miss         = 0;
        out_addr            = 'bz;
        out_write_data      = 'bz;
        out_read_data       = 'bz;
    end

    always @(*) begin
        n                   = -1;
        hit_or_miss         = 'bz;
        case (in_addr[4])
            1'b0: begin
                if (valid[0] == 1'b1 && tags[0] == in_addr[9:5]) begin
                    hit_or_miss = 1;
                    n           = 0;
                end 
                else if (valid[1] == 1'b1 && tags[1] == in_addr[9:5]) begin
                    hit_or_miss = 1;
                    n           = 1;
                end
                else begin
                    hit_or_miss = 0;
                end
            end
            1'b1: begin
                if (valid[2] == 1'b1 && tags[2] == in_addr[9:5]) begin
                    hit_or_miss = 1;
                    n           = 2;
                end 
                else if (valid[3] == 1'b1 && tags[3] == in_addr[9:5]) begin
                    hit_or_miss = 1;
                    n           = 3;
                end
                else begin
                    hit_or_miss = 0;
                end
            end
        endcase

        out_row             = 'bz;
        out_write_data      = 'bz;
        out_addr            = 'bz;
        out_read_data       = 'bz;
        if (in_row == 1'b1 && hit_or_miss == 1'b1) begin
            cache_mem[n][in_addr[3:0] * byte +: byte] = in_write_data;
            out_write_data  = cache_mem[n];
            out_addr        = in_addr;
            out_row         = 1;
        end
        else if (in_row == 1'b0 && hit_or_miss == 1'b1) begin
            out_read_data   = cache_mem[n][in_addr[3:0] * byte +: byte];
        end
        else if (hit_or_miss == 1'b0) begin
            out_addr        = in_addr;
            out_row         = 0;
            case (in_addr[4])
                1'b0: begin
                    if (valid[0] == 1'b0) begin
                        n   = 0;
                    end
                    else if (valid[1] == 1'b0) begin
                        n   = 1;
                    end
                    else if (unused[0] == 1'b1) begin
                        n   = 0;
                    end
                    else begin
                        n   = 1;
                    end
                end
                1'b1: begin
                    if (valid[2] == 1'b0) begin
                        n   = 2;
                    end
                    else if (valid[3] == 1'b0) begin
                        n   = 3;
                    end
                    else if (unused[2] == 1'b1) begin
                        n   = 2;
                    end
                    else begin
                        n   = 3;
                    end
                end
            endcase
            if (n != -1) begin
                #1 cache_mem[n] = in_read_data;
                tags[n]         = in_addr[9:5];
                hit_or_miss     = 1;
                if (in_row == 1'b0) begin
                    out_read_data   = cache_mem[n][in_addr[3:0] * byte +: byte];
                end
                else if (in_row == 1'b1) begin
                    cache_mem[n][in_addr[3:0] * byte +: byte] = in_write_data;
                    out_write_data  = cache_mem[n];
                    out_addr        = in_addr;
                out_row         = 1;
                end
            end
        end

        if (n != -1) begin
            valid[n]       = 1;
            unused[n]           = 0;
            unused[n + (-1)**(n % 2)] = 1;
        end
    end
    
endmodule