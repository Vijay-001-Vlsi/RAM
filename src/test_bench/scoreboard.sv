class scoreboard;
        mailbox #(transaction)exp_mbox;
        mailbox #(transaction)act_mbox;
        int pass_cnt;
        int fail_cnt;
        function new(mailbox #(transaction)exp_mbox,
                mailbox #(transaction)act_mbox);
                this.exp_mbox=exp_mbox;
                this.act_mbox=act_mbox;
                pass_cnt=0;
                fail_cnt=0;
        endfunction
        task compare(
                transaction exp_txn,
                transaction act_txn);
                exp_txn.print("expected");
                act_txn.print("actual");
                if(exp_txn.address !==act_txn.address)begin
                        $error("[SB]Address mismatch");
                        fail_cnt++;
                        return;
                end

                if(exp_txn.data_out ===act_txn.data_out)begin
                        pass_cnt++;
                        $display("[SB] PASS");
                end
                else begin
        //              $display("[SB]fail");
        //              $display("expected=%0hdd",exp_txn.data_out);
        //              $display("actual =%0h",act_txn.data_out);
                        fail_cnt++;
                        //$display("[SB] FAIL");
                            $display("[SB] FAIL exp=0x%0h act=0x%0h", exp_txn.data_out, act_txn.data_out);  // was "PASS"
                end
        endtask
                task run();
                        transaction exp_txn;
                        transaction act_txn;
                   forever begin
                                exp_mbox.get(exp_txn);
                                act_mbox.get(act_txn);
                                compare(exp_txn,act_txn);
                        end
                endtask
                function void report();
                        $display("scoreboard report");
                        $display("pass=%0d",pass_cnt);
                        $display("fail=%0d",fail_cnt);
                endfunction
endclass

                                          
                                                 
