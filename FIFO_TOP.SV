module FIFO_TOP;
  logic clk;
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  FIFO_INTERFACE FIFO_if (.clk(clk));

  FIFO         fifo_dut (.fifo_1(FIFO_if.DUT));
  FIFO_MONITOR fifo_mon (.fifo_1(FIFO_if.MONITOR));
  FIFO_TB      fifo_tb  (.fifo_1(FIFO_if.TEST));

property p_async_reset;
    @(FIFO_if.rst_n) $fell(FIFO_if.rst_n) |-> ##0
        (fifo_dut.count == 0 && fifo_dut.wr_ptr == 0 && fifo_dut.rd_ptr == 0);
endproperty
assert property (p_async_reset)
    else $error("[ASSERT] reset did not take effect asynchronously on negedge rst_n");
endmodule
