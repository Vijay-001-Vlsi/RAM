`timescale 1ns/1ps
import ram_pkg::*;
module top;
    // Clock
    logic clk;
    logic reset;
    initial
        clk = 0;
    always #10 clk = ~clk;
        initial begin
                reset=1'b0;
                repeat(2)@(posedge clk);
                reset=1'b1;
        end


    // Interface
    ram_if intf(clk,reset);
    // DUT
    RAM dut(
        .clk(clk),
        .reset(intf.reset),
        .data_in(intf.data_in),
        .address(intf.address[4:0]),
        .write_enb(intf.write_enb),
        .read_enb(intf.read_enb),
        .data_out(intf.data_out)
    );
    // Test
    test t;
    // Run Test
    initial begin
        t = new(intf);
        t.run();
    end
    // End Simulation
    initial begin
        #3000;
        $finish;
    end
  endmodule
