/*
* <lsfr.sv>
* 
* Copyright (c) 2021-2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

// Pseudo random sequence generator
//    - Reference of generation polinomial
//        https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
//        Page 5, table 3.
module lsfr #(
  parameter DATA = 3
  // constant
)(
  input wire              clk,
  input wire              reset,
  output wire [DATA-1:0]  out
);

  //***** internal registers
  reg [DATA-1:0]        rand_reg;

  //***** internal wires
  wire [DATA-1:0]        next_rand_reg;

  //***** error check
  localparam DATA_MIN = 3;  // minimum supported data width
  localparam DATA_MAX = 16;  // maximum supported data width
  initial begin
    if ( DATA < DATA_MIN ) begin
      $error("Error: Data size must be larger or equal than %1d", DATA_MIN);
      $fatal(1);
    end
    if ( DATA > DATA_MAX ) begin
      $error("Error Data size must be smaller or equal than %2d", DATA_MAX);
      $fatal(1);
    end
  end



  //***** assign output
  assign out = rand_reg;



  //***** assign internal
  assign next_rand_reg[DATA-1:1] = rand_reg[DATA-2:0];

  generate
    genvar gi;
    case ( DATA )
      3 : begin : lsfr3
        assign next_rand_reg[0] = rand_reg[2] ^ rand_reg[1];
      end
      4 : begin : lsfr4
        assign next_rand_reg[0] = rand_reg[3] ^ rand_reg[2];
      end
      5 : begin : lsfr5
        assign next_rand_reg[0] = rand_reg[4] ^ rand_reg[2];
      end
      6 : begin : lsfr6
        assign next_rand_reg[0] = rand_reg[5] ^ rand_reg[4];
      end
      7 : begin : lsfr7
        assign next_rand_reg[0] = rand_reg[6] ^ rand_reg[5];
      end
      8 : begin : lsfr8
        assign next_rand_reg[0] =
          rand_reg[7] ^ rand_reg[5] ^ rand_reg[4] ^ rand_reg[3];
      end
      9: begin : lsfr9
        assign next_rand_reg[0] = rand_reg[8] ^ rand_reg[4];
      end
      10 : begin : lsfr10
        assign next_rand_reg[0] = rand_reg[9] ^ rand_reg[6];
      end
      11 : begin : lsfr11
        assign next_rand_reg[0] = rand_reg[10] ^ rand_reg[8];
      end
      12 : begin : lsfr12
        assign next_rand_reg[0] =
          rand_reg[11] ^ rand_reg[5] ^ rand_reg[3] ^ rand_reg[0];
      end
      13 : begin : lsfr13
        assign next_rand_reg[0] =
          rand_reg[12] ^ rand_reg[3] ^ rand_reg[2] ^ rand_reg[0];
      end
      14 : begin : lsfr14
        assign next_rand_reg[0] =
          rand_reg[13] ^ rand_reg[4] ^ rand_reg[2] ^ rand_reg[0];
      end
      15 : begin : lsfr15
        assign next_rand_reg[0] = rand_reg[14] ^ rand_reg[13];
      end
      16 : begin : lsfr16
        assign next_rand_reg[0] =
          rand_reg[15] ^ rand_reg[14] ^ rand_reg[12] ^ rand_reg[3];
      end
      default : begin
        // not supported
        assign next_rand_reg = '1;
      end
    endcase
  endgenerate



  //***** sequential logics
  always @( posedge clk ) begin
    if ( reset == `ENABLE ) begin
      rand_reg <= {{DATA-1{1'b0}}, 1'b1};
    end else begin
      rand_reg <= next_rand_reg;
    end
  end

endmodule
