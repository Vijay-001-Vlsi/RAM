class generator;
        mailbox #(transaction)wr_mbx;
        mailbox #(transaction)rd_mbx;
        mailbox #(bit)wr_done_mbx;
        mailbox #(bit) rd_done_mbx;
        function new(mailbox #(transaction)wr_mbx,
                mailbox #(transaction)rd_mbx,
                mailbox #(bit)wr_done_mbx,
                mailbox #(bit) rd_done_mbx);
                this.wr_mbx=wr_mbx;
                this.rd_mbx=rd_mbx;
                this.wr_done_mbx=wr_done_mbx;
                this.rd_done_mbx=rd_done_mbx;
        endfunction
  task send_write(transaction txn);
                txn.op=write_op;
                txn.print("[Gen-wr]");
                wr_mbx.put(txn);
        endtask

        task wait_write_done(input int unsigned n);
                bit token;
                repeat(n)wr_done_mbx.get(token);
        endtask

        task send_read(transaction txn);
                txn.op=read_op;
                txn.print("[Gen-Read]");
                rd_mbx.put(txn);
        endtask
        task wait_read_done(input int unsigned n);
                    bit token;
                    repeat(n) rd_done_mbx.get(token);
        endtask

        task run(
                input logic[7:0]wr_address[],
                input logic[7:0]wr_data[],
                input int unsigned n_writes,
                input logic[7:0]rd_address[],
                input int unsigned n_reads,
                input bit randomize_txns=0);
                logic [7:0]written_addr[];

                transaction txn;
                if(!randomize_txns)begin
                        if(wr_address.size() < n_writes)
                                $fatal(1,"[gen]wr_address size(%d) < n_writes(%d)", wr_address.size(),n_writes);
                         if(wr_data.size() < n_writes)
                                $fatal(1,"[gen]wr_data size(%d) < n_writes(%d)", wr_data.size(),n_writes);
                         if(rd_address.size() < n_reads)
                                $fatal(1,"[gen]rd_address size(%d) < n_reads(%d)", rd_address.size(),n_reads);
                end
                written_addr=new[n_writes];
                $display("[GEN] Sending %0d WRITE transactions", n_writes);
                for(int i=0;i<n_writes;i++)begin
                        txn=new();
                        if(randomize_txns)begin
                                if(!txn.randomize() with {op==write_op;})
                                        $fatal("[gen]write randomization failed");
                        end
                        else begin
                                txn.address=wr_address[i];
                                txn.data_in=wr_data[i];
                                txn.op=write_op;
                        end
                        written_addr[i]=txn.address;
                        send_write(txn);
                end
                wait_write_done(n_writes);

                $display("[GEN] All WRITE transactions completed");
                 for(int i=0;i<n_reads;i++)begin
                   txn=new();
                        if(randomize_txns)begin
                                //if(!txn.randomize() with {op==read_op;})
                                  //      $fatal("[gen]write randomization failed");
                                txn.address = written_addr[i % n_writes];
                                txn.op = read_op;
                        end
                        else begin
                                txn.address=rd_address[i];
                                txn.op=read_op;
                        end
                        send_read(txn);

               end
                wait_read_done(n_reads);
                $display("[gen]generator completed");
endtask
endclass

                                                    
