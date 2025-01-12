/*
* <selector.sv>
* 
* Copyright (c) 2020-2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"

module selector #(
  parameter bit MODE      = `LOW,     // 0: index, 1: bit vector
  parameter int DATA      = 5,        // width of single element
  parameter int IN        = 32,       // # of input element
  parameter bit ACT       = `LOW,     // Active High/Low
  parameter bit MSB       = `DISABLE, // select from Most Sifnificant Elements
  // constant
  parameter int LOG2_IN   = $clog2(IN),
  parameter int POS       = IN,
  parameter int SEL_WIDTH = MODE ? IN : LOG2_IN // selector width
) (
  input wire [IN-1:0][DATA-1:0] in,
  input wire [SEL_WIDTH-1:0]    sel,
  output wire                   valid,
  output wire [POS-1:0]         pos,
  output wire [DATA-1:0]        out
);

  //***** internal parameters
  localparam bit ENABLE  = ACT ? `ENABLE : `ENABLE_;
  localparam bit DISABLE = ACT ? `DISABLE : `DISABLE_;
  localparam EIN         = 1 << LOG2_IN;    // align to 2^n
  localparam STAGE       = LOG2_IN;
  localparam ELMS        = EIN - 1;

  //***** Internal wires
  wire [ELMS-1:0][DATA-1:0]  res;
  wire [ELMS-1:0]            sel_res;



  //****** output
  if ( IN == 1 ) begin : IF_thr
    if ( MODE ) begin : bitvec
      assign out = ( sel[0] == ENABLE ) ? in[0] : {DATA{1'b0}};
    end else begin : idx
      assign out = ENABLE;
    end
    assign valid = sel[0];
  end else begin : IF_sel
    assign out   = res[ELMS-1];
    assign valid = sel_res[ELMS-1];
  end



  //***** output position
  generate
    genvar gk;
    if ( MODE ) begin : IF_BIT
      if ( MSB ) begin : IF_MSB
        assign pos[IN-1] = sel[IN-1];
        for ( gk = IN-2; gk >= 0; gk = gk - 1 ) begin : LP_pos
          assign pos[gk] = ACT ? !( |pos[IN-1:gk+1] ) && sel[gk]
                         :       !( &pos[IN-1:gk+1] ) || sel[gk];
        end
      end else begin : IF_LSB
        assign pos[0] = sel[0];
        for ( gk = 1; gk < IN; gk = gk + 1 ) begin : LP_pos
          assign pos[gk] = ACT ? !( |pos[gk-1:0] ) && sel[gk]
                         :       !( &pos[gk-1:0] ) || sel[gk];
        end
      end
    end else begin : IF_IDX
      for ( gk = 0; gk < POS; gk = gk + 1 ) begin
        assign pos[gk] = ( gk == sel ) ? ENABLE: DISABLE;
      end
    end
  endgenerate



  //***** element select function
  generate
    genvar gi, gj;
    //*** Input Stage ( = stage 1 )
    for ( gi = 0; gi < EIN / 2; gi = gi + 1 ) begin : ST1

      if ( 2*gi+1 < IN ) begin : elm
        wire                sel1;
        wire                sel2;
        if ( ACT ) begin : IF_acth
          assign sel_res[gi] = sel1 || sel2;
          if ( MODE ) begin : bitvec
            assign sel1 = ( sel[gi*2] == ENABLE );
            assign sel2 = ( sel[gi*2+1] == ENABLE );
          end else begin : idx
            assign sel1 = ( sel == ( gi * 2 ) );
            assign sel2 = ( sel == ( gi * 2 + 1 ) );
          end
        end else begin : IF_actl
          assign sel_res[gi] = sel1 && sel2;
          if ( MODE ) begin : bitvec
            assign sel1 = !( sel[gi*2] == ENABLE );
            assign sel2 = !( sel[gi*2+1] == ENABLE );
          end else begin : idx
            assign sel1 = !( sel == ( gi * 2 ) );
            assign sel2 = !( sel == ( gi * 2 + 1 ) );
          end
        end

        sub_sel #(
          .DATA ( DATA ),
          .MSB  ( MSB ),
          .ACT  ( ACT )
        ) sub_sel_st1 (
          .in1  ( in[gi*2] ),
          .in2  ( in[gi*2+1] ),
          .sel1 ( sel1 ),
          .sel2 ( sel2 ),
          .out  ( res[gi] )
        );
      end else if ( 2 * gi < IN ) begin : elmh
        //* one element is valid
        assign res[gi] = in[gi*2];
        if ( ACT ) begin : IF_acth
          assign sel_res[gi] = MODE ? (sel[gi*2] == ENABLE)
                             :        (sel == (gi*2));
        end else begin : IF_actl
          assign sel_res[gi] = MODE ? !(sel[gi*2] == ENABLE)
                             :        !(sel == (gi*2));
        end
      end else begin : zero
        assign res[gi]     = {DATA{1'b0}};
        assign sel_res[gi] = DISABLE;
      end
    end

    //*** middle to output stages
    for ( gi = 2; gi <= STAGE; gi = gi + 1 ) begin : ST
      for ( gj = 0; gj < EIN >> gi; gj = gj + 1 ) begin : elm
        wire    sel1; 
        wire    sel2; 
        assign sel1 = sel_res[(gj*2)+(EIN-(EIN>>(gi-2)))];
        assign sel2 = sel_res[(gj*2+1)+(EIN-(EIN>>(gi-2)))];
        if ( ACT ) begin : IF_acth
          assign sel_res[gj+(EIN-(EIN>>(gi-1)))] = sel1 || sel2;
        end else begin : IF_actl
          assign sel_res[gj+(EIN-(EIN>>(gi-1)))] = sel1 && sel2;
        end

        sub_sel #(
          .DATA ( DATA ),
          .MSB  ( MSB ),
          .ACT  ( ACT )
        ) sub_sel_stN (
          .in1  ( res[(gj*2)+(EIN-(EIN>>(gi-2)))] ),
          .in2  ( res[(gj*2+1)+(EIN-(EIN>>(gi-2)))] ),
          .sel1 ( sel1 ),
          .sel2 ( sel2 ),
          .out  ( res[gj+(EIN-(EIN>>(gi-1)))] )
        );
      end
    end
  endgenerate

endmodule

// simple 2:1 mux
module sub_sel #(
  parameter int DATA = 8,
  parameter bit MSB = `DISABLE,
  parameter bit ACT = `HIGH
)(
  input  wire [DATA-1:0]   in1,
  input  wire [DATA-1:0]   in2,
  input  wire              sel1,
  input  wire              sel2,
  output wire [DATA-1:0]   out
);

  wire [1:0] sel = {sel2, sel1};

  generate
    case ( {MSB, ACT} )
      {`DISABLE, `LOW} : begin : CASE_ll
        assign out = (sel == 2'b00) || (sel == 2'b10) ? in1
                   : (sel == 2'b01)                   ? in2
                   :                                    `ZERO(DATA);
      end
      {`ENABLE, `LOW} : begin : CASE_ml
        assign out = (sel == 2'b00) || (sel == 2'b01) ? in2
                   : (sel == 2'b10)                   ? in1
                   :                                    `ZERO(DATA);
      end
      {`DISABLE, `HIGH} : begin : CASE_lh
        assign out = (sel == 2'b11) || (sel == 2'b01) ? in1
                   : (sel == 2'b10)                   ? in2
                   :                                    `ZERO(DATA);
      end
      {`ENABLE, `HIGH} : begin : CASE_mh
        assign out = (sel == 2'b11) || (sel == 2'b10) ? in2
                   : (sel == 2'b01)                   ? in1
                   :                                    `ZERO(DATA);
      end
    endcase
  endgenerate

endmodule
