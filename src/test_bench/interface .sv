`timescale 1ns/1ps
interface ram_if(input logic clk, input logic reset);
    logic        write_enb;
    logic        read_enb;
    logic [7:0]  address;
    logic [7:0]  data_in;
    logic [7:0]  data_out;

    clocking drv @(posedge clk);
        default input #1 output #1;
        input  reset;
        output write_enb;
        output read_enb;
        output address;
        output data_in;
        input  data_out;
    endclocking

    clocking mon @(posedge clk);
        default input #1;
        input reset;
        input write_enb;
        input read_enb;
        input address;
        input data_in;
        input data_out;
    endclocking

    modport DRIVER  (clocking drv, input clk);
    modport MONITOR (clocking mon, input clk);
endinterface
