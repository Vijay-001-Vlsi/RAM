 typedef enum{write_op,read_op}op_t;
class transaction;
         //typedef enum{write_op,read_op}op_t;
        rand logic[7:0] data_in;
        rand logic[4:0] address;
        rand op_t op;
        logic [7:0]data_out;
function void print(string tag=" ");
        $display("[%s] op=%s addr=%0d data_in=0x%0h data_out=0x%0h",
                tag,op.name(),address,data_in,data_out);
endfunction
endclass
