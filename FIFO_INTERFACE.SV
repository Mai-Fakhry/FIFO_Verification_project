import shared_pkg::*;
interface FIFO_INTERFACE(input logic clk);

logic [FIFO_WIDTH-1:0] data_in;
logic rst_n, wr_en, rd_en;
logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;
 
 modport DUT(
     input clk,
     input rst_n,
     input data_in,
     input wr_en,
     input rd_en,
     output data_out,
     output wr_ack,
     output overflow,
     output full,
     output empty,
     output almostfull,
     output almostempty,
     output underflow
 );

 modport TEST(
     input clk,
     output rst_n,
     output data_in,
     output wr_en,
     output rd_en,
     input data_out,
     input wr_ack,
     input overflow,
     input full,
     input empty,
     input almostfull,
     input almostempty,
     input underflow
 );

 modport MONITOR(
    input clk,
    input rst_n,
    input data_in,
    input wr_en,
    input rd_en,
    input data_out,
    input wr_ack,
    input overflow,
    input full,
    input empty,
    input almostfull,
    input almostempty,
    input underflow
);
endinterface
