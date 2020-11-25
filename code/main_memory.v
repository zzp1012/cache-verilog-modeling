`timescale 1ns / 1ps

module main_memory(
    output  reg [127:0]             out_read_data,
    input                           in_row, // 0 means read, 1 means write
    input       [9:0]               in_addr,
    input       [127:0]             in_write_data
    );

    parameter main_size     = 1024;
    parameter block_size    = 128;
    parameter byte          = 8;
    
    reg     [block_size - 1:0]  main_mem[main_size * byte / block_size - 1:0];

    integer                     n;

    initial begin
        for (n = 0; n < main_size * byte / block_size; n = n + 1) begin
            main_mem[n]     = n;
        end
    end

    always @(*) begin
        out_read_data = 'bz;
        case (in_row)
            1'b0: begin
                out_read_data = main_mem[in_addr[9:4]];
            end
            1'b1: begin
                main_mem[in_addr[9:4]] = in_write_data;
            end
        endcase
    end
endmodule