package pkg_3;
import shared_pkg::*;
import pkg_1::*;

class FIFO_scoreboard;
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic full_ref, empty_ref;

    logic [FIFO_WIDTH-1:0] mem_model[$:FIFO_DEPTH-1];

    function new();
        mem_model.delete();
        error_count   = 0;
        correct_count = 0;
    endfunction

    task check_data(input FIFO_transaction F_txn);
        // matches the DUT's one-cycle registered data_out latency
        if (^data_out_ref === 1'bx) begin
            // pipeline-fill transient: no prediction made yet, skip
        end
        else if (F_txn.data_out === data_out_ref) begin
            correct_count++;
        end
        else begin
            error_count++;
            $display("[SCOREBOARD ERROR] time=%0t  data_out: DUT=%0h REF=%0h",
                       $time, F_txn.data_out, data_out_ref);
        end

        reference_model(F_txn);
    endtask

    task reference_model(input FIFO_transaction F_txn);
        if (!F_txn.rst_n) begin
            mem_model.delete();
            data_out_ref = '0;
        end
        else begin
            if (F_txn.wr_en && F_txn.rd_en) begin
                if (empty_ref)
                    mem_model.push_back(F_txn.data_in);
                else if (full_ref)
                    data_out_ref = mem_model.pop_front();
                else begin
                    mem_model.push_back(F_txn.data_in);
                    data_out_ref = mem_model.pop_front();
                end
            end
            else if (F_txn.wr_en && !full_ref) begin
                mem_model.push_back(F_txn.data_in);
            end
            else if (F_txn.rd_en && !empty_ref) begin
                data_out_ref = mem_model.pop_front();
            end
        end

        full_ref  = (mem_model.size() == FIFO_DEPTH);
        empty_ref = (mem_model.size() == 0);
        $display("[DBG] time=%0t wr=%0b rd=%0b din=%0h size=%0d dref=%0h",
           $time, F_txn.wr_en, F_txn.rd_en, F_txn.data_in, mem_model.size(), data_out_ref);
    endtask

endclass
endpackage
