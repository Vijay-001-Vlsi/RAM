class reference_model;
        logic[7:0]mem[0:31];
        mailbox #(transaction)rm_wr_mbox;
        mailbox #(transaction)rm_rd_mbox;
        mailbox #(transaction)exp_mbox;

        logic[7:0]ref_mem[0:31];
        function new(mailbox #(transaction)rm_wr_mbox,
                mailbox #(transaction)rm_rd_mbox,
                mailbox #(transaction)exp_mbox);
                this.rm_wr_mbox=rm_wr_mbox;
                this.rm_rd_mbox=rm_rd_mbox;
                this.exp_mbox=exp_mbox;
        endfunction


        task write_thread();
                transaction txn;
                forever begin
                        rm_wr_mbox.get(txn);
                        ref_mem[txn.address]=txn.data_in;
                        $display("[RM]write addr=%0d data=%0h",txn.address,txn.data_in);
                end
        endtask

        task read_thread();
                transaction txn;
                forever begin
                        rm_rd_mbox.get(txn);
                        txn.data_out=ref_mem[txn.address[4:0]];
                        txn.print("RM");
                        exp_mbox.put(txn);
                end
        endtask
        task run();
                fork
                        write_thread();
                        read_thread();
                join
          endtask
endclass
              
