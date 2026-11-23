package pkg_2;

import shared_pkg::*;
import pkg_1::*;

class FIFO_coverage;
 FIFO_transaction F_cvg_txn = new();

 covergroup cvr_g_1;
 cp_wr_en: coverpoint F_cvg_txn.wr_en{
  bins wr_en_active ={1};
  bins wr_en_not_active ={0};
 }
cp_rd_en: coverpoint F_cvg_txn.rd_en{
  bins rd_en_active ={1};
  bins rd_en_not_active ={0};
 }

 cp_wr_ack: coverpoint F_cvg_txn.wr_ack{
  bins wr_ack_active ={1};
  bins wr_ack_not_active ={0};
 }

 cp_overflow: coverpoint F_cvg_txn.overflow{
  bins overflow_active ={1};
  bins overflow_not_active ={0};
 }
 cp_full: coverpoint F_cvg_txn.full{
  bins full_active ={1};
  bins full_not_active ={0};
 }
 cp_empty: coverpoint F_cvg_txn.empty{
  bins empty_active ={1};
  bins empty_not_active ={0};
 }
 cp_almostfull: coverpoint F_cvg_txn.almostfull{
  bins almostfull_active ={1};
  bins almostfull_not_active ={0};
 }
  cp_almostempty: coverpoint F_cvg_txn.almostempty{
  bins almostempty_active ={1};
  bins almostempty_not_active ={0};
 }
  cp_underflow: coverpoint F_cvg_txn.underflow{
  bins underflow_active ={1};
  bins underflow_not_active ={0};
 }
 

 cr1: cross cp_wr_en, cp_rd_en, cp_full;
 cr2: cross cp_wr_en, cp_rd_en, cp_empty;
 cr3: cross cp_wr_en, cp_rd_en, cp_almostfull;
 cr4: cross cp_wr_en, cp_rd_en, cp_almostempty;
 cr5: cross cp_wr_en, cp_rd_en, cp_underflow {
    illegal_bins rd_en_off_underflow_active =
        binsof(cp_rd_en) intersect {0} && binsof(cp_underflow) intersect {1};
}
 cr6: cross cp_wr_en, cp_rd_en, cp_overflow;
 cr7: cross cp_wr_en, cp_rd_en, cp_wr_ack;
 
 endgroup

 function new();
  cvr_g_1= new();
 endfunction

 function void sample_data(input FIFO_transaction F_txn);
  F_cvg_txn = F_txn ;
  cvr_g_1.sample();
 endfunction

endclass 
endpackage 
