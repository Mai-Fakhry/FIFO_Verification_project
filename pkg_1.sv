package pkg_1;
import shared_pkg::*;
  class FIFO_transaction;

    logic [FIFO_WIDTH-1:0] data_in;
    rand logic rst_n, wr_en, rd_en;
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow;
 
    integer RD_EN_ON_DIST, WR_EN_ON_DIST;

    function new(input integer RD_EN_ON_DIST=30, input integer WR_EN_ON_DIST=70);
    begin
          this.RD_EN_ON_DIST=RD_EN_ON_DIST;
          this.WR_EN_ON_DIST=WR_EN_ON_DIST;
    end
    endfunction
    
    constraint assert_rst{
      rst_n dist {1:=90,0:=10};
    }

    constraint wr_en_const{
      wr_en dist {1:=WR_EN_ON_DIST,0:=(100-WR_EN_ON_DIST)};
    }

    constraint rd_en_const{
      rd_en dist {1:=RD_EN_ON_DIST,0:=(100-RD_EN_ON_DIST)};
    }
  endclass
endpackage


