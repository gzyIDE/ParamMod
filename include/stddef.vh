/*
* <stddef.vh>
*
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
*
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _STDDEF_VH_INCLUDED_
`define _STDDEF_VH_INCLUDED_

`define	NULL				0
`define	Null				1'b0
`define	ZERO				0

`define	DISABLE				1'b0
`define	Disable				1'b0
`define	ENABLE				1'b1
`define	Enable				1'b1

`define	DISABLE_			1'b1
`define	Disable_			1'b1
`define	ENABLE_				1'b0
`define	Enable_				1'b0

`define	ON					1'b1
`define	On					1'b1
`define	OFF					1'b0
`define	Off					1'b0

`define	HIGH				1'b1
`define	High				1'b1
`define	LOW					1'b0
`define	Low					1'b0

`define	TRUE				1'b1
`define	True				1'b1
`define	FALSE				1'b0
`define	False				1'b0

`define	READ				1'b1
`define	Read				1'b1
`define	WRITE				1'b0
`define	Write				1'b0

`define	BUSY				1'b1
`define	Busy				1'b1
`define	FREE				1'b0
`define	Free				1'b0

`define	HiZ					1'bz
`define	HIZ					'hz

`define	LOCAL				1'b0
`define	Local				1'b0
`define	GLOBAL				1'b1
`define	Global				1'b1

`define	UNSIGNED			1'b0
`define	Unsigned			1'b0
`define	SIGNED				1'b1
`define	Signed				1'b1

`define	LONGWORD			8
`define	DOUBLE				8
`define	WORD				4
`define	INT					4
`define	FLOAT				4
`define	HALFWORD			2
`define	SHORT				2
`define	BYTE				1
`define	CHAR				1

`define	LongWordBitWidth	64
`define	DoubleBitWidth		64
`define	DOUBLE_DATA_W		64
`define	WordBitWidth		32
`define	WORD_DATA_W			32
`define	IntBitWidth			32
`define	FloatBitWidth		32
`define	HalfWordBitWidth	16
`define	ShortBitWidth		16
`define	ByteBitWidth		8
`define	CharBitWidth		8
`define HalfByteBitWidth	4		// 4bit Integer

// Shift width
`define HalfByteShiftWidth	2
`define	ByteShiftWidth		3
`define	HalfWordShiftWidth	4
`define	WordShiftWidth		5
`define	DoubleShiftWidth	6

`define	LongWord			63:0
`define	Double				63:0
`define	DoubleDataBus		63:0
`define	DoubleData0			63:32
`define	DoubleData1			31:0
`define	Word				31:0
`define	WordDataBus			31:0
`define	Int					31:0
`define	Float				31:0
`define	HalfWord			15:0
`define	Half				15:0
`define	Short				15:0
`define	Byte				7:0
`define	Char				7:0
`define HalfByte			3:0		// 4bit Integer Range

`define	Byte0				31:24
`define	Byte1				23:16
`define	Byte2				15:8
`define	Byte3				7:0

`define	HalfWord0			31:16
`define	HalfWord1			15:0

`define HalfSign			15		// Sign Bit Range of Half Precision
`define HalfExponent		14:10	// Exponent Bit Range of Half Precision
`define HalfFraction		9:0		// Fraction Bit Range of Half Precision
`define	SingleSign			31		// Sign Bit Range of Single Precision
`define	SingleExponent		30:23	// Exponent Bit Range of Single Precision
`define	SingleFraction		22:0	// Fraction Bit Range of Single Precision
`define	DoubleSign			63		// Sign Bit Range of Double Precision
`define	DoubleExponent		62:52	// Exponent Bit Range of Double Precision
`define	DoubleFraction		51:0	// Fraction Bit Range of Double Precision

`define FloatingHalf		16		// Half Precision Bit Width
`define HalfExpWidth		5		// Exponent Bit Width of Single Precision
`define HalfFracWidth		10		// Fraction Bit Width of Half Precision
`define	FloatingSingle		32		// Single Precision Bit Width
`define	SingleExpWidth		8		// Exponent Bit Width of Single Precision
`define	SingleFracWidth		23		// Fraction Bit Width of Single Precision
`define	FloatingDouble		64		// Double Precision Bit Width
`define	DoubleExpWidth		11		// Exponent Bit Width of Double Precision
`define	DoubleFracWidth		52		// Fraction	Bit	Width of Double Precision

`define Kilo				1024
`define Mega				1048576

// range expression for generate, always, function
`define RangeG(Idx,W)		(Idx+1)*W-1:Idx*W	// range for generate
`define RangeF(Idx,W)		Idx*W+:W			// range for function
`define RangeA(Idx,W)		Idx*W+:W			// range for always

// standard expression for convenience
`define Max(A,B)			(A>B)?A:B			// Return larger of the two
`define Min(A,B)			(A<B)?A:B			// Return smaller of the two

// Functions for counter
`define CntUp(VAL,MAX,INC)	(VAL>MAX-INC)?MAX:VAL+INC	// increment
`define CntDwn(VAL,MIN,DEC)	(VAL<MIN+DEC)?MIN:VAL-DEC	// decrement

// Bit extension
`define SignExt(Bit,Sig)	{{Bit-$bits(Sig){Sig[$bits(Sig)-1]}}, Sig}
`define USignExt(Bit,Sig)	{{Bit-$bits{1'b0}}, Sig}

`endif // _STDDEF_VH_INCLUDED_
