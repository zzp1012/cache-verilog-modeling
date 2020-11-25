`timescale 1ns / 1ps

module test_bench;
    // read_write: 0 for read, 1 for write
    // Address: 10 bits byte address
    // write_data: 32 bits value (8 bits are enough for this project demo)
    // keep track of the output of your (cache+memory) block, which are read_data and hit_miss
    // also please find a way to show the content of the main memory 

    parameter block_size    = 128;
    parameter addr_size     = 10;
    parameter byte          = 8;

    reg                         read_write;
    reg     [addr_size - 1:0]   address;
    reg     [byte - 1:0]        write_data;

    wire    [block_size - 1:0]  data_from_main;
    wire                        row_from_cache;
    wire                        hit_or_miss;
    wire    [addr_size - 1:0]   addr_from_cache;
    wire    [block_size -1:0]   data_from_cache;
    wire    [byte - 1:0]        read_data;

    cache2a   cache(
        .out_row(row_from_cache),
        .hit_or_miss(hit_or_miss),
        .out_addr(addr_from_cache),
        .out_write_data(data_from_cache),
        .out_read_data(read_data),
        .in_row(read_write),
        .in_addr(address),
        .in_write_data(write_data),
        .in_read_data(data_from_main)
    );

    main_memory main(
        .out_read_data(data_from_main),
        .in_row(row_from_cache),
        .in_addr(addr_from_cache),
        .in_write_data(data_from_cache)
    );

    initial begin
        #0 read_write = 0; address = 10'b0000000000; //should miss
        #10 read_write = 1; address = 10'b0000000000; write_data = 8'b11111111; //should hit
        #10 read_write = 0; address = 10'b0000000000; //should hit and read out 0xff
        
        //here check main memory content, 
        //the first byte should remain 0x00 if it is write-back, 
        //should change to 0xff if it is write-through.
        
        #10 read_write = 0; address = 10'b1000000000; //should miss
        #10 read_write = 0; address = 10'b0000000000; //should hit for 2-way associative, should miss for directly mapped
        
        #10 read_write = 0; address = 10'b1100000000; //should miss
        #10 read_write = 0; address = 10'b1000000000; //should miss both for directly mapped and for 2-way associative (Least-Recently-Used policy)
        
        //here check main memory content, 
        //the first byte should be 0xff
    end

    initial #100 $finish;
endmodule //test_bench

