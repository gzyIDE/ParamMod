/*
* <stddef.h>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`ifndef _STDDEF_H_INCLUDED_
`define _STDDEF_H_INCLUDED_

//***** Zero expression
`define	Null				1'b0
`define	Zero				0



//***** 1bit constant Expressions
//*** active/inactive
`define	Disable				1'b0		// Active High Disable
`define	Enable				1'b1		// Active High Enable
`define	Disable_			1'b1		// Active Low Disable
`define	Enable_				1'b0		// Active Low Enable

//*** logic
`define	On					1'b1
`define	Off					1'b0
`define	High				1'b1
`define	Low					1'b0
`define	True				1'b1
`define	False				1'b0

//*** read/write
`define	Read				1'b1
`define	Write				1'b0

//*** high impedance
`define	HiZ					1'bz



//***** Useful Macros
//*** standard expression for convenience
`define Max(A,B)			(A>B)?A:B						// Return larger of the two
`define Min(A,B)			(A<B)?A:B						// Return smaller of the two
`define Max3(A,B,C)			(A>B)?((A>C)?A:C):((B>C)?B:C)	// Return minmum of the three
`define Min3(A,B,C)			(A<B)?((A<C)?A:C):((B<C)?B:C)	// Return maximum of the three

//*** Functions for counter
`define CntUp(VAL,MAX,INC)	(VAL>MAX-INC)?MAX:VAL+INC		// increment
`define CntDwn(VAL,MIN,DEC)	(VAL<MIN+DEC)?MIN:VAL-DEC		// decrement

//*** Fraction Adjustment
`define CEIL(A,B)			((A/B)+(A%B!=0))				// round up to nearest integer

`endif // _STDDEF_H_INCLUDED_
