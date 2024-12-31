/*
* <parammod_stddef.vh>
* 
* Copyright (c) 2023 Yosuke Ide <gizaneko@outlook.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

// Info : If stddef.vh is already included,
//        paramdef_stddef.vh should be ignored!!
`ifndef _STDDEF_VH_INCLUDED_
`define _STDDEF_VH_INCLUDED_

//***** 1bit constant Expression
//*** active/inactive
`define DISABLE     1'b0        // Active High Disable
`define ENABLE      1'b1        // Active High Enable
`define DISABLE_    1'b1        // Active Low Disable
`define ENABLE_     1'b0        // Active Low Enable
//*** logic
`define ON          1'b1
`define OFF         1'b0
`define HIGH        1'b1
`define LOW         1'b0
`define TRUE        1'b1
`define FALSE       1'b0
//*** read/write    
`define READ        1'b1
`define WRITE       1'b0
//*** high impedance
`define HIZ         1'bz


//***** Bit width expression
`define BYTE        8
`define HWORD       16
`define WORD        32
`define DWORD       64
`define QWORD       128
`define BYTE_R      7:0
`define HWORD_R     15:0
`define WORD_R      31:0
`define DWORD_R     63:0
`define QWORD_R     127:0


//***** Useful Macros
//*** Zero/One of specified width
`define ZERO(W)             {W{1'b0}}
`define ONE(W)              {{W-1{1'b0}}, 1'b1}
`define SETALL(W)           {W{1'b1}}
`define FULL(W)             {W{1'b1}}
//*** standard expression for convenience
`define MAX(A,B)            (A>B)?A:B                       // Return larger of the two
`define MIN(A,B)            (A<B)?A:B                       // Return smaller of the two
`define MAX3(A,B,C)         (A>B)?((A>C)?A:C):((B>C)?B:C)   // Return minmum of the three
`define MIN3(A,B,C)         (A<B)?((A<C)?A:C):((B<C)?B:C)   // Return maximum of the three
//*** Functions for counter
`define CNTUP(VAL,MAX,INC)  (VAL>MAX-INC)?MAX:VAL+INC       // increment
`define CNTDWN(VAL,MIN,DEC) (VAL<MIN+DEC)?MIN:VAL-DEC       // decrement
//*** Fraction Adjustment
`define CEIL(A,B)           ((A/B)+(A%B!=0))                // round up to nearest integer

`endif // _STDDEF_VH_INCLUDED_
