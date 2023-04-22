/*
* <sim.vh>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`ifndef _SIM_H_INCLUDED_
`define _SIM_H_INCLUDED_

/* example of color */
/*
* $write("%c[1;34m", 27);
* $display("I am Blue");
* $write("%c[0m", 27);
*
* with macro
* $write("%c[
*/

/* character setting */
`define SetCharBold				$write("%c[1m",27);
`define SetCharBar				$write("%c[4m",27);
`define SetCharBlack			$write("%c[30m",27);
`define SetCharBlackBold		$write("%c[30m",27);$write("%c[1m",27);
`define SetCharRed				$write("%c[31m",27);
`define SetCharRedBold			$write("%c[31m",27);$write("%c[1m",27);
`define SetCharGreen			$write("%c[32m",27);
`define SetCharGreenBold		$write("%c[32m",27);$write("%c[1m",27);
`define SetCharYellow			$write("%c[33m",27);
`define SetCharYellowBold		$write("%c[33m",27);$write("%c[1m",27);
`define SetCharBlue				$write("%c[34m",27);
`define SetCharBlueBold			$write("%c[34m",27);$write("%c[1m",27);
`define SetCharMagenta			$write("%c[35m",27);
`define SetCharMagentaBold		$write("%c[35m",27);$write("%c[1m",27);
`define SetCharCyan				$write("%c[36m",27);
`define SetCharCyanBold			$write("%c[36m",27);$write("%c[1m",27);
`define SetCharWhite			$write("%c[37m",27);
`define ResetCharSetting		$write("%c[0m",27);

/* reset setting */
`define ATT_RESET			0

/* character option */
`define ATT_BOLD			1
`define ATT_BAR				4

/* character color */
`define ATT_C_BLACK			30
`define ATT_C_RED			31
`define ATT_C_GREEN			32
`define ATT_C_YELLOW		33
`define ATT_C_BLUE			34
`define ATT_C_MAGENTA		35
`define ATT_C_CYAN			36
`define ATT_C_WHITE			37

/* background color */
`define ATT_B_BLACK			40
`define ATT_B_RED			41
`define ATT_B_GREEN			42
`define ATT_B_YELLOW		43
`define ATT_B_BLUE			44
`define ATT_B_MAGENTA		45
`define ATT_B_CYAN			46
`define ATT_B_GRAY			47

/* Clock generation */
`define DefClk	always #(STEP/2) begin \
								  clk <= ~clk; \
							  end

`endif //_SIM_H_INCLUDED_
