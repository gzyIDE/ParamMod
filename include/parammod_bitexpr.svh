/*
* <parammod_bitexpr.vh>
* 
* Copyright (c) 2024 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`ifndef _BITEXPR_SVH_INCLUDED_
`define _BITEXPR_SVH_INCLUDED_

`define RANGE(Idx,W)        (Idx)*(W)+:(W)

`define LSB(Sig)          Sig[0]
`define MSB(Sig)          Sig[$bits(Sig)-1]
`define SIGN(Sig)         Sig[$bits(Sig)-1]

`define REPEAT(Cnt,Sig)   {Cnt{Sig}}

`define ZEROEXT(W,Sig)    {{(W-$bits(Sig)){1'b0}}, Sig}
`define SIGNEXT(W,Sig)    {{(W-$bits(Sig)){Sig[$bits(Sig)-1]}},Sig}
`define ZEROPAD(W, Sig)   {Sig, {(W-$bits(Sig)){1'b0}}}

`endif
