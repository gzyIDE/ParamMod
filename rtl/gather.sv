/*
* <gather.sv>
* 
* Copyright (c) 2021-2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module gather #(
  parameter DATA = 32,          // Data Size
  parameter IN = 8,             // Input Data
  parameter ACT = `HIGH,        // Active High/Low (sel, valid)
  parameter OUT = IN,           // Gathered Output
  parameter OFFSET = `DISABLE,  // Use offset of output elements
  // constant
  parameter OFS = $clog2(OUT)   // Offset bit width
)(
  input wire [IN-1:0][DATA-1:0]   in,
  input wire [IN-1:0]             sel,
  input wire [OFS-1:0]            offset,
  output wire [OUT-1:0]           valid,
  output wire [OUT-1:0][DATA-1:0] out
);

//***** internal parameters
localparam ENABLE = ACT  ? `ENABLE  : `ENABLE_;
localparam DISABLE = ACT ? `DISABLE : `DISABLE_;
localparam NUM = $clog2(IN);

//***** internal wires
wire [IN-1:0][NUM-1:0]      order;

//***** compiler dependent
logic [OUT-1:0][IN-1:0]     prior;

//***** parameter check
initial begin
  if ( IN < OUT ) begin
    $info("Info: Parameter \"IN\" should not be smaller than \"OUT\"");
  end
end



//***** Calculate output order
assign order[0] = 0;
generate
  genvar gi, gj;
  //*** count activated bits of former entries
  for ( gi = 1; gi < IN; gi = gi + 1 ) begin : LP_order
    wire [$clog2(gi):0]    order_each;
    assign order[gi] = {{NUM-$clog2(gi){1'b0}}, order_each};

    cnt_bits #(
      .IN    ( gi ),
      .ACT  ( ACT )
    ) cnt_bits (
      .in    ( sel[gi-1:0] ),
      .out  ( order_each )
    );
  end

  //*** determine which entry to output
  for ( gi = 0; gi < IN; gi = gi + 1 ) begin : LP_prior
    for ( gj = 0; gj < OUT; gj = gj + 1 ) begin : LP_cmp
      if ( OFFSET ) begin : IF_OFS
        always_comb begin
          if ( order[gi] + offset < IN )  begin
            prior[gj][gi] =
              ( ( sel[gi] == ENABLE ) &&
                ( ( order[gi] + offset ) == gj ) )
              ? ENABLE
              : DISABLE;
          end else begin
            prior[gj][gi] = DISABLE;
          end
        end
      end else begin : ELSE_OF
        if ( gi < gj ) begin
          assign prior[gj][gi] = DISABLE;
        end else begin
          assign prior[gj][gi] =
            ( ( order[gi] == gj ) && ( sel[gi] == ENABLE ) )
              ? ENABLE 
              : DISABLE;
        end
      end
    end
  end
endgenerate



//***** Select Output
generate
  genvar gk, gl;
  for ( gk = 0; gk < OUT; gk = gk + 1 ) begin : LP_sel
    if ( OFFSET ) begin : IF_OFS
      selector #(
        .BIT_MAP  ( `ENABLE ),
        .DATA     ( DATA ),
        .IN       ( IN ),
        .ACT      ( ACT )
      ) sel_out (
        .in       ( in ),
        .sel      ( prior[gk] ),
        .valid    ( valid[gk] ),
        .pos      (),
        .out      ( out[gk] )
      );

    end else begin : ELSE_OFS
      wire [IN-gk-1:0][DATA-1:0]  in_partial;
      wire [IN-gk-1:0]            prior_partial;

      for (gl = gk; gl < IN; gl = gl + 1 ) begin : LP_partial
        assign in_partial[gl-gk] = in[gl];
        assign prior_partial[gl-gk] = prior[gk][gl];
      end

      selector #(
        .BIT_MAP  ( `ENABLE ),
        .DATA     ( DATA ),
        .IN       ( IN - gk ),
        .ACT      ( ACT )
      ) sel_out (
        .in       ( in_partial ),
        .sel      ( prior_partial ),
        .valid    ( valid[gk] ),
        .pos      (),
        .out      ( out[gk] )
      );
    end
  end
endgenerate

endmodule
