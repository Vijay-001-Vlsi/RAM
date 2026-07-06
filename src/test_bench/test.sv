class test;
    // Environment Handle
    environment env;
    // Virtual Interface
    virtual ram_if vif;
    // Constructor
    function new(virtual ram_if vif);
        this.vif = vif;
        env = new(vif);
    endfunction
    // Run Test
    task run();
        logic [7:0] wr_addr[];
        logic [7:0] wr_data[];
        logic [7:0] rd_addr[];
        transaction conflict_txn;
        // Build Environment
        env.build();
        // Start Driver/Monitor/RM/SB
        env.run();
        // Allocate Arrays
        wr_addr = new[4];
        wr_data = new[4];
        rd_addr = new[4];
        // Directed Test
        wr_addr[0] = 8'd0;
        wr_data[0] = 8'h11;

        wr_addr[1] = 8'd1;
        wr_data[1] = 8'h22;

        wr_addr[2] = 8'd2;
        wr_data[2] = 8'h33;

        wr_addr[3] = 8'd3;
        wr_data[3] = 8'h44;

        rd_addr[0] = 8'd0;
        rd_addr[1] = 8'd1;
        rd_addr[2] = 8'd2;
        rd_addr[3] = 8'd3;

        // Start Generator
        env.gen.run(wr_addr, wr_data, 32, rd_addr, 32, 1);
            repeat(3) @(posedge vif.clk);   // let monitor/rm/scoreboard finish processing
            // --- Directed conflict test: write_enb & read_enb asserted together ---
                conflict_txn = new();
                conflict_txn.address = 5'd5;
                conflict_txn.data_in = 8'hAA;
                env.drv.drive_conflict(conflict_txn);
            repeat(2) @(posedge vif.clk);   // let it settle before finishing
            env.sb.report();
            $finish;
    endtask
endclass                       
