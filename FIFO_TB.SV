import shared_pkg::*;
import pkg_1::*;
import pkg_2::*;
import pkg_3::*;

module FIFO_TB(FIFO_INTERFACE.TEST fifo_1);

  FIFO_transaction drv_tr = new();

  initial begin

    // Reset
    fifo_1.rst_n   = 0;
    fifo_1.wr_en   = 0;
    fifo_1.rd_en   = 0;
    fifo_1.data_in = 0;

    repeat (2) @(negedge fifo_1.clk);
    fifo_1.rst_n = 1;


    // 1) Random stimulus
    repeat (100) begin

      assert(drv_tr.randomize())
      else $error("randomize failed for drv_tr");

      fifo_1.wr_en   = drv_tr.wr_en;
      fifo_1.rd_en   = drv_tr.rd_en;
      fifo_1.data_in = $urandom;

      @(negedge fifo_1.clk);
      -> drv_done;

    end

    // 2) Fill FIFO completely
    fifo_1.rd_en = 0;

    while (!fifo_1.full) begin

      fifo_1.wr_en   = 1;
      fifo_1.data_in = $urandom;

      @(negedge fifo_1.clk);
      -> drv_done;

    end


    // 3) Write while FULL
    // Covers overflow and full && wr_en

    fifo_1.wr_en   = 1;
    fifo_1.rd_en   = 0;
    fifo_1.data_in = $urandom;

    @(negedge fifo_1.clk);
    -> drv_done;


    // 4) Read one entry from FULL
    // Creates almostfull condition
    fifo_1.wr_en = 0;
    fifo_1.rd_en = 1;

    @(negedge fifo_1.clk);
    -> drv_done;


    // 5) Drain FIFO until EMPTY
    while (!fifo_1.empty) begin

      fifo_1.wr_en = 0;
      fifo_1.rd_en = 1;

      @(negedge fifo_1.clk);
      -> drv_done;

    end



    // 6) EMPTY-state combinations
    // wr=0, rd=0
    fifo_1.wr_en = 0;
    fifo_1.rd_en = 0;

    @(negedge fifo_1.clk);
    -> drv_done;


    // wr=0, rd=1
    // Covers underflow
    fifo_1.wr_en = 0;
    fifo_1.rd_en = 1;

    @(negedge fifo_1.clk);
    -> drv_done;


    // wr=1, rd=1 while empty
    fifo_1.wr_en   = 1;
    fifo_1.rd_en   = 1;
    fifo_1.data_in = $urandom;

    @(negedge fifo_1.clk);
    -> drv_done;


    // 7) Create ALMOSTEMPTY condition

    // Reset again to guarantee count = 0
    fifo_1.rst_n   = 0;
    fifo_1.wr_en   = 0;
    fifo_1.rd_en   = 0;
    fifo_1.data_in = 0;

    @(negedge fifo_1.clk);
    -> drv_done;

    fifo_1.rst_n = 1;


    // Write two entries
    // count: 0 -> 1 -> 2
    repeat (2) begin

      fifo_1.wr_en   = 1;
      fifo_1.rd_en   = 0;
      fifo_1.data_in = $urandom;

      @(negedge fifo_1.clk);
      -> drv_done;

    end


    // Read one entry
    // count: 2 -> 1
    // Therefore almostempty = 1
    fifo_1.wr_en = 0;
    fifo_1.rd_en = 1;

    @(negedge fifo_1.clk);
    -> drv_done;


    // 8) CR4 target:

    fifo_1.wr_en   = 1;
    fifo_1.rd_en   = 1;
    fifo_1.data_in = $urandom;

    @(negedge fifo_1.clk);
    -> drv_done;


    // 9) Both enables OFF while FIFO is non-empty
    fifo_1.wr_en = 0;
    fifo_1.rd_en = 0;

    @(negedge fifo_1.clk);
    -> drv_done;


    // 10) Deterministic ALMOSTFULL + idle

    fifo_1.wr_en = 0;
    fifo_1.rd_en = 0;
    fifo_1.rst_n = 0;

    @(negedge fifo_1.clk);
    -> drv_done;

    fifo_1.rst_n = 1;

    @(negedge fifo_1.clk);
    -> drv_done;


    // FIFO is guaranteed empty here.
    // Fill to FIFO_DEPTH - 1.
    repeat (FIFO_DEPTH-1) begin

      fifo_1.wr_en   = 1;
      fifo_1.rd_en   = 0;
      fifo_1.data_in = $urandom;

      @(negedge fifo_1.clk);
      -> drv_done;

    end


    // count = FIFO_DEPTH - 1
    // therefore almostfull = 1
    // wr_en = 0, rd_en = 0
    fifo_1.wr_en = 0;
    fifo_1.rd_en = 0;

    @(negedge fifo_1.clk);
    -> drv_done;


    test_finished = 1;
    -> drv_done;

  end

endmodule
