class monitor;
        virtual ram_if.MONITOR vif;
        mailbox #(transaction)act_mbox;
           op_t        cov_op;
            logic [7:0] cov_address;
            logic [7:0] cov_data_out;
covergroup mon_cg;
        option.per_instance = 1;
        cp_op      : coverpoint cov_op;
        cp_addr    : coverpoint cov_address {
            bins low  = {[0:7]};
            bins mid  = {[8:23]};
            bins high = {[24:31]};
        }
        cp_data    : coverpoint cov_data_out {
            bins zero    = {8'h00};
            bins allones = {8'hFF};
            bins others  = default;
        }
        cross_op_addr : cross cp_op, cp_addr;
    endgroup
        function new(virtual ram_if.MONITOR vif,
                mailbox #(transaction)act_mbox
               );
                this.vif=vif;
                this.act_mbox=act_mbox;
                mon_cg = new();
        endfunction
        task run();
    transaction txn;
    bit read_pending = 0;
    logic [7:0] pending_addr;
    $display("Mon started");
    forever begin
        @(vif.mon);
        if (!vif.mon.reset) begin
            read_pending = 0;
            continue;
        end
        if (read_pending) begin
           txn = new();
            txn.op = read_op;
            txn.address  = pending_addr;
            txn.data_out = vif.mon.data_out;
            txn.print("[mon-rd]");
            act_mbox.put(txn);
                cov_op       = read_op;
            cov_address  = pending_addr;
            cov_data_out = txn.data_out;
            mon_cg.sample();
                read_pending = 0;

        end
        if (vif.mon.write_enb) begin
            txn = new();
            txn.op = write_op;
            txn.address = vif.mon.address;
            txn.data_in = vif.mon.data_in;
            txn.print("[mon-wr]");
            cov_op      = write_op;
            cov_address = vif.mon.address;
            mon_cg.sample();
        end
        else if (vif.mon.read_enb) begin
            pending_addr = vif.mon.address;
            read_pending = 1;
        end
    end
endtask
endclass

