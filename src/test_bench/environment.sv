class environment;
    generator        gen;
    driver           drv;
    monitor          mon;
    reference_model  rm;
    scoreboard       sb;
      virtual ram_if vif;
    // Generator -> Driver
    mailbox #(transaction) wr_mbox;
    mailbox #(transaction) rd_mbox;

    // Driver -> Generator
    mailbox #(bit) wr_done_mbox;
    mailbox #(bit)rd_done_mbox;
    // Driver -> Reference Model
    mailbox #(transaction) rm_wr_mbox;
    mailbox #(transaction) rm_rd_mbox;

    // Reference Model -> Scoreboard
    mailbox #(transaction) exp_mbox;

    // Monitor -> Scoreboard
    mailbox #(transaction) act_mbox;

    // Constructor
    function new(virtual ram_if vif);

        this.vif = vif;

    endfunction
    // Build
    task build();
        // Mailboxes
        wr_mbox      = new();
        rd_mbox      = new();

        wr_done_mbox = new();
        rd_done_mbox=new();
        rm_wr_mbox   = new();
        rm_rd_mbox   = new();
        exp_mbox  = new();

        act_mbox   = new();

        // Components
        gen = new(
            wr_mbox,
            rd_mbox,
            wr_done_mbox,
            rd_done_mbox
        );
        drv = new(
            vif,
            wr_mbox,
            rd_mbox,
            rm_wr_mbox,
            rm_rd_mbox,
            wr_done_mbox,
            rd_done_mbox
        );

        mon = new(
            vif,
            act_mbox
        );

        rm = new(
            rm_wr_mbox,
            rm_rd_mbox,
            exp_mbox
        );

        // Scoreboard compares READ transactions
        sb = new(
            exp_mbox,
          act_mbox
        );

    endtask

    // Run
    task run();

        fork
            drv.run();
            mon.run();
            rm.run();
            sb.run();
        join_none

    endtask

endclass
                     
