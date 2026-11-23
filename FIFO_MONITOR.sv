import shared_pkg::*;
import pkg_1::*;
import pkg_2::*;
import pkg_3::*;

module FIFO_MONITOR(FIFO_INTERFACE.MONITOR fifo_1);

FIFO_transaction fifo_tr = new();
FIFO_scoreboard fifo_scr = new();
FIFO_coverage fifo_cov = new();

initial begin 
  forever begin 
    @(drv_done);
      fifo_tr.rst_n       = fifo_1.rst_n;
      fifo_tr.data_in     = fifo_1.data_in;
      fifo_tr.wr_en       = fifo_1.wr_en;
      fifo_tr.rd_en       = fifo_1.rd_en;
      fifo_tr.data_out    = fifo_1.data_out;
      fifo_tr.wr_ack      = fifo_1.wr_ack;
      fifo_tr.overflow    = fifo_1.overflow;
      fifo_tr.full        = fifo_1.full;
      fifo_tr.empty       = fifo_1.empty;
      fifo_tr.almostfull  = fifo_1.almostfull;
      fifo_tr.almostempty = fifo_1.almostempty;
      fifo_tr.underflow   = fifo_1.underflow;
  

  fork
    fifo_cov.sample_data(fifo_tr);
    fifo_scr.check_data(fifo_tr);
  join

    if(test_finished)
    begin 
      $display("Simulation ends with correct counts: %d and error counts:%d",correct_count,error_count);
      $stop;
    end 
end
end
endmodule
