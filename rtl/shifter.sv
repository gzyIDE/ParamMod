/*
* <shifter.v>
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module shifter #(
  parameter bit BIT_VEC   = `ENABLE,  // shift by # of active bits
  parameter bit ROTATE    = `DISABLE, // rotate
  parameter bit TO_RIGHT  = `DISABLE, // right
  parameter DATA          = 8,
  parameter SHAMT         = 4,
  parameter ACT           = `HIGH
)(
  input wire [DATA-1:0]   in,
  input wire [SHAMT-1:0]  shamt,
  output wire [DATA-1:0]  out
);

//***** internal parameter
localparam SNUM = BIT_VEC ? $clog2(SHAMT) + 1 : SHAMT;

//***** internal wires
wire [SNUM-1:0]   snum;


//***** shift amount
generate
  if ( BIT_VEC ) begin : bitvec
    //***** count enable bits
    cnt_bits #(
      .IN   ( SHAMT ),
      .ACT  ( ACT )
    ) cnt_shamt (
      .in   ( shamt ),
      .out  ( snum )
    );
  end else begin : idx
    assign snum = shamt;
  end
endgenerate


//***** output
generate
  case ( {ROTATE, TO_RIGHT} )
    2'b00 : begin : sl
      // shift left
      assign out = in << snum;
    end
    2'b01 : begin : sr
      // shift right
      assign out = in >> snum;
    end
    2'b10 : begin : rl
      // rotate left
      assign out = ( in << snum ) | ( in >> ( DATA - snum ) );
    end
    2'b11 : begin : rr
      // rotate right
      assign out = ( in >> snum ) | ( in << ( DATA - snum ) );
    end
  endcase
endgenerate

endmodule
