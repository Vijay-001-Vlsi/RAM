class driver;
        virtual ram_if.DRIVER vif;
        mailbox #(transaction)wr_mbox;
        mailbox #(transaction)rd_mbox;
        mailbox #(transaction)rm_wr_mbox;
        mailbox #(transaction)rm_rd_mbox;
        mailbox #(bit)wr_done_mbox;
        mailbox #(bit) rd_done_mbox;


        bit cov_write_enb;
        bit cov_read_enb;
        logic[4:0]cov_address;

        covergroup drv_cg;
                option.per_instance=1;
                cp_write_enb: coverpoint cov_write_enb;
                cp_read_enb: coverpoint cov_read_enb;
                cp_address:coverpoint cov_address{
                        bins low={[0:7]};
                        bins mid={[8:23]};
                        bins high={[24:31]};
                }
                cross cp_write_enb, cp_read_enb {
                          bins wr_only = binsof(cp_write_enb) intersect {1} &&
                                     binsof(cp_read_enb)  intersect {0};

                          bins rd_only = binsof(cp_write_enb) intersect {0} &&
                                     binsof(cp_read_enb)  intersect {1};
                }
        endgroup

        function new(virtual ram_if.DRIVER vif,
                mailbox #(transaction)wr_mbox,
                mailbox #(transaction)rd_mbox,
                mailbox #(transaction)rm_wr_mbox,
                mailbox #(transaction)rm_rd_mbox,
                mailbox #(bit)wr_done_mbox,
                      mailbox #(bit) rd_done_mbox);

                drv_cg=new();
                this.vif=vif;
                this.wr_mbox=wr_mbox;
                this.rd_mbox=rd_mbox;
                this.rm_wr_mbox=rm_wr_mbox;
                this.rm_rd_mbox=rm_rd_mbox;
                this.wr_done_mbox=wr_done_mbox;
                this.rd_done_mbox=rd_done_mbox;
        endfunction
        task reset_dut();
                vif.drv.write_enb<=1'b0;
                vif.drv.read_enb<=1'b0;
                vif.drv.address<='0;
                vif.drv.data_in<='0;
                wait(vif.drv.reset===1'b0);
                wait(vif.drv.reset===1'b1);
                $display("drv reset completed");

        endtask



        task drive_write(transaction txn);
                bit done =1;
                @(vif.drv);
                vif.drv.write_enb<=1'b1;
                vif.drv.read_enb<=1'b0;
                vif.drv.address<=txn.address;
                vif.drv.data_in<=txn.data_in;
                @(vif.drv);
                vif.drv.write_enb<=0;

            $display("[DRV] WRITE Addr=%0d Data=%0h",txn.address, txn.data_in);
          cov_write_enb=1;
                cov_read_enb=0;
                cov_address=txn.address;
                drv_cg.sample();
                rm_wr_mbox.put(txn);
                wr_done_mbox.put(done);
        endtask


        task write_thread();
                transaction txn;
                forever begin
                        wr_mbox.get(txn);
                        drive_write(txn);
                end
        endtask
        task drive_conflict(transaction txn);
                    @(vif.drv);
                    vif.drv.write_enb <= 1'b1;
                    vif.drv.read_enb  <= 1'b1;      // both asserted together
                    vif.drv.address   <= txn.address;
                    vif.drv.data_in   <= txn.data_in;
                    @(vif.drv);
                    vif.drv.write_enb <= 1'b0;
                    vif.drv.read_enb  <= 1'b0;
                    $display("[DRV] CONFLICT Addr=%0d Data=%0h", txn.address, txn.data_in);

                cov_write_enb=1;
                cov_read_enb=1;
                cov_address=txn.address;
                drv_cg.sample();
        endtask


        //task drive_read(transaction txn);
           //      @(vif.drv);
        //      vif.drv.write_enb<=1'b0;
        //      vif.drv.read_enb<=1'b1;
        //      vif.drv.address<=txn.address;
        //      @(vif.drv);
        //      vif.drv.read_enb<=0;
        //      $display("[DRV] READ Addr=%0d", txn.address);
        //      rm_rd_mbox.put(txn);
//
//      endtask
         task drive_read(transaction txn);
                 bit done = 1;

    @(vif.drv);


    vif.drv.write_enb <= 0;
    vif.drv.read_enb  <= 1;
    vif.drv.address   <= txn.address;
    @(vif.drv);

    vif.drv.read_enb <= 0;
    $display("[DRV] READ Addr=%0d", txn.address);
        cov_write_enb = 0;
        cov_read_enb  = 1;
        cov_address   = txn.address;
         drv_cg.sample();

    rm_rd_mbox.put(txn);
 rd_done_mbox.put(done);
endtask

        task read_thread();
                transaction txn;
                 $display("[DRV] Read thread started");   
          forever begin
                        rd_mbox.get(txn);
                        $display("[DRV] Got READ transaction");
                        drive_read(txn);
                end
        endtask
        task run();
                reset_dut();
                fork
                        write_thread();
                        read_thread();
                join_none
        endtask
endclass
