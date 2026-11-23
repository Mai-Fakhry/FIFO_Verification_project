////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design
//
////////////////////////////////////////////////////////////////////////////////
import shared_pkg::*;

module FIFO(FIFO_INTERFACE.DUT fifo_1);

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

initial begin
    // BUG FIX: Internal FIFO state was not initialized at simulation start.
    // Without initialization, count and pointers could contain X values
    // before reset was applied.
    count  = 0;
    wr_ptr = 0;
    rd_ptr = 0;
end

always @(posedge fifo_1.clk or negedge fifo_1.rst_n) begin
    if (!fifo_1.rst_n) begin
        wr_ptr <= 0;
        fifo_1.wr_ack <= 0;
        fifo_1.overflow <= 0;
    end
    else begin

        if (fifo_1.wr_en && count < FIFO_DEPTH) begin
            mem[wr_ptr] <= fifo_1.data_in;
            fifo_1.wr_ack <= 1;
            wr_ptr <= wr_ptr + 1;
        end
        else begin
            fifo_1.wr_ack <= 0;
        end

        // BUG FIX: Overflow detection was previously coupled to the
        // write-operation else branch. It is now checked independently
        // whenever a write is attempted while the FIFO is full.
        if (fifo_1.full && fifo_1.wr_en)
            fifo_1.overflow <= 1;
        else
            fifo_1.overflow <= 0;

    end
end

always @(posedge fifo_1.clk or negedge fifo_1.rst_n) begin
    if (!fifo_1.rst_n) begin
        // BUG FIX: data_out was not reset in the original RTL,
        // which could leave it at an unknown value after reset.
        rd_ptr <= 0;
        fifo_1.data_out <= '0;
    end
    else if (fifo_1.rd_en && count != 0) begin
        fifo_1.data_out <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 1;
    end
end

always @(posedge fifo_1.clk or negedge fifo_1.rst_n) begin
    if (!fifo_1.rst_n) begin
        count <= 0;
    end
    else begin

        // BUG FIX: The original RTL did not explicitly handle the
        // simultaneous read/write case (wr_en=1, rd_en=1).
        // Boundary cases such as simultaneous read/write when the FIFO
        // is empty or full are now handled explicitly.
        case ({fifo_1.wr_en, fifo_1.rd_en})
            2'b10:
                if (!fifo_1.full)
                    count <= count + 1;

            2'b01:
                if (!fifo_1.empty)
                    count <= count - 1;

            2'b11: begin
                if (!fifo_1.full && !fifo_1.empty)
                    count <= count;
                else if (fifo_1.empty)
                    count <= count + 1;
                else if (fifo_1.full)
                    count <= count - 1;
            end

            default: ;
        endcase
    end
end

assign fifo_1.full = (count == FIFO_DEPTH) ? 1 : 0;
assign fifo_1.empty = (count == 0) ? 1 : 0;
assign fifo_1.underflow = (fifo_1.empty && fifo_1.rd_en) ? 1 : 0;

// BUG FIX: The original RTL asserted almostfull at FIFO_DEPTH-2.
// The required behavior is to assert it when only one FIFO entry
// remains available.
assign fifo_1.almostfull = (count == FIFO_DEPTH-1) ? 1 : 0;

assign fifo_1.almostempty = (count == 1) ? 1 : 0;


// =====================================================================
// Assertions
// =====================================================================

// ---- reset values: sampled while rst_n is low ----
property p_reset_values;
    @(posedge fifo_1.clk)
    !fifo_1.rst_n |-> (count == 0 && wr_ptr == 0 && rd_ptr == 0);
endproperty

assert property (p_reset_values)
    else $error("[ASSERT] count/wr_ptr/rd_ptr not 0 while in reset");

// ---- full flag correctness vs. count ----
property p_full_correct;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    fifo_1.full == (count == FIFO_DEPTH);
endproperty

assert property (p_full_correct)
    else $error("[ASSERT] full mismatch: full=%0b count=%0d",
                fifo_1.full, count);

// ----  empty flag correctness vs. count ----
property p_empty_correct;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    fifo_1.empty == (count == 0);
endproperty

assert property (p_empty_correct)
    else $error("[ASSERT] empty mismatch: empty=%0b count=%0d",
                fifo_1.empty, count);

// ---- almostfull: count == FIFO_DEPTH-1 ----
property p_almostfull_correct;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    fifo_1.almostfull == (count == FIFO_DEPTH-1);
endproperty

assert property (p_almostfull_correct)
    else $error("[ASSERT] almostfull mismatch: almostfull=%0b count=%0d",
                fifo_1.almostfull, count);

// ---- almostempty: count == 1 ----
property p_almostempty_correct;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    fifo_1.almostempty == (count == 1);
endproperty

assert property (p_almostempty_correct)
    else $error("[ASSERT] almostempty mismatch: almostempty=%0b count=%0d",
                fifo_1.almostempty, count);

// ---- underflow correctness (combinational) ----
property p_underflow_correct;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    fifo_1.underflow == (fifo_1.empty && fifo_1.rd_en);
endproperty

assert property (p_underflow_correct)
    else $error("[ASSERT] underflow mismatch: underflow=%0b empty=%0b rd_en=%0b",
                fifo_1.underflow, fifo_1.empty, fifo_1.rd_en);

// ---- full and empty can never both be true (FIFO_DEPTH > 0) ----
property p_full_empty_exclusive;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    !(fifo_1.full && fifo_1.empty);
endproperty

assert property (p_full_empty_exclusive)
    else $error("[ASSERT] full and empty asserted simultaneously");

// ---- overflow: reverse check ----
property p_overflow_correct;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    fifo_1.overflow |-> ($past(fifo_1.full) && $past(fifo_1.wr_en));
endproperty

assert property (p_overflow_correct)
    else $error("[ASSERT] overflow asserted without full & wr_en on prior cycle");

// ---- overflow: forward check ----
property p_overflow_forward;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    (fifo_1.wr_en && fifo_1.full) |=> fifo_1.overflow;
endproperty

assert property (p_overflow_forward)
    else $error("[ASSERT] overflow not asserted after a write attempt while full");

// ---- wr_ack: reverse check ----
property p_wr_ack_correct;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    fifo_1.wr_ack |-> ($past(fifo_1.wr_en) &&
                       ($past(count) < FIFO_DEPTH));
endproperty

assert property (p_wr_ack_correct)
    else $error("[ASSERT] wr_ack asserted without a valid write on prior cycle");

// ---- wr_ack: forward check ----
property p_wr_ack_forward;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    (fifo_1.wr_en && !fifo_1.full) |=> fifo_1.wr_ack;
endproperty

assert property (p_wr_ack_forward)
    else $error("[ASSERT] wr_ack not asserted after a legal write");

// ---- internal counter behavior ----

property p_count_range;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    count <= FIFO_DEPTH;
endproperty

assert property (p_count_range)
    else $error("[ASSERT] count exceeded FIFO_DEPTH: count=%0d", count);

property p_count_inc_on_write;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    (fifo_1.wr_en && !fifo_1.rd_en && !fifo_1.full)
    |=> (count == $past(count) + 1);
endproperty

assert property (p_count_inc_on_write)
    else $error("[ASSERT] count did not increment correctly on write");

property p_count_dec_on_read;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    (fifo_1.rd_en && !fifo_1.wr_en && !fifo_1.empty)
    |=> (count == $past(count) - 1);
endproperty

assert property (p_count_dec_on_read)
    else $error("[ASSERT] count did not decrement correctly on read");

property p_count_hold;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    (!fifo_1.wr_en && !fifo_1.rd_en)
    |=> (count == $past(count));
endproperty

assert property (p_count_hold)
    else $error("[ASSERT] count changed with no wr_en/rd_en asserted");

// ---- internal pointer range checks ----

property p_wr_ptr_range;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    wr_ptr < FIFO_DEPTH;
endproperty

assert property (p_wr_ptr_range)
    else $error("[ASSERT] wr_ptr out of range: wr_ptr=%0d", wr_ptr);

property p_rd_ptr_range;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    rd_ptr < FIFO_DEPTH;
endproperty

assert property (p_rd_ptr_range)
    else $error("[ASSERT] rd_ptr out of range: rd_ptr=%0d", rd_ptr);

// ---- pointer wraparound ----

property p_wr_ptr_wrap;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    (wr_ptr == FIFO_DEPTH-1) &&
    fifo_1.wr_en && !fifo_1.full
    |=> (wr_ptr == 0);
endproperty

assert property (p_wr_ptr_wrap)
    else $error("[ASSERT] wr_ptr failed to wrap to 0 after reaching FIFO_DEPTH-1");

property p_rd_ptr_wrap;
    @(posedge fifo_1.clk) disable iff (!fifo_1.rst_n)
    (rd_ptr == FIFO_DEPTH-1) &&
    fifo_1.rd_en && !fifo_1.empty
    |=> (rd_ptr == 0);
endproperty

assert property (p_rd_ptr_wrap)
    else $error("[ASSERT] rd_ptr failed to wrap to 0 after reaching FIFO_DEPTH-1");

endmodule
