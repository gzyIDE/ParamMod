/*
* <lru.sv>
* Cache LRU check and update
* 
* Copyright (c) 2024 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

`default_nettype none

module lru #(
  parameter Way       = 8,
  // Constant
  parameter LruStatW  = Way-1,
  parameter WaySel    = $clog2(Way)
)(
  input wire [LruStatW-1:0]   lrustat,
  output wire [WaySel-1:0]    lruo,

  input wire [WaySel-1:0]     acway,
  output wire [LruStatW-1:0]  updstato
);

generate for (genvar gi = 0; gi < WaySel; gi++) begin
  localparam ofs    = (2**gi) - 1;
  localparam width  = (2**gi);
  localparam idx    = gi;
  wire [width-1:0]  w_stat;
  wire [width-1:0]  w_updstat;
  wire              w_acbit;
  assign w_stat  = lrustat[ofs+width-1:ofs];
  assign updstato[ofs+width-1:ofs] = w_updstat;
  assign w_acbit = acway[WaySel-1-gi];

  if ( gi == 0 ) begin
    logic c_lrubit;
    logic c_upd;
    assign lruo[WaySel-1-gi] = c_lrubit;
    assign w_updstat         = c_upd;

    always_comb begin
      c_lrubit = w_stat[0];
      c_upd    = (c_lrubit == w_acbit) ? !c_lrubit
               :                         c_lrubit;
    end
  end else begin
    logic             c_lrubit;
    logic [width-1:0] c_upd;
    wire [idx-1:0]    w_idx;
    wire [idx-1:0]    w_acidx;
    assign w_idx             = lruo[WaySel-1:WaySel-1-(gi-1)];
    assign w_acidx           = acway[WaySel-1:WaySel-gi];
    assign lruo[WaySel-1-gi] = c_lrubit;
    assign w_updstat         = c_upd;

    always_comb begin
      c_lrubit = w_stat[w_idx];

      for (int i = 0; i < width; i++) begin
        automatic logic updtmp;
        updtmp   = (w_stat[i] == w_acbit)  ? !w_stat[i]
                 :                           w_stat[i];
        c_upd[i] = (w_acidx == i[idx-1:0]) ? updtmp
                 :                           w_stat[i];
      end
    end
  end
end
endgenerate

endmodule

`default_nettype wire
