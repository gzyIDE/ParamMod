/*
* <reset_config.vh>
*
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
*
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _RESET_CONFIG_VH_INCLUDED_
`define _RESET_CONFIG_VH_INCLUDED_

//***** include dependent define
`include "stddef.vh"

//***** Reset configuration
//*** Reset behavior (Asynchronous or Synchronous Reset)
//		Select one of following define
//`define AsyncReset
`define SyncReset

//*** Reset Polarity (Posedge or Negedge)
//		Select one of following define
`define PosedgeReset
//`define NegedgeReset



//***** automatic configuration (do not edit below)
//*** Reset polarity
`ifdef PosedgeReset
	`define ResetEdge		posedge
	`define ResetEnable		`Enable
	`define ResetDisable	`Disable
`elsif NegedgeReset
	`define ResetEdge		negedge
	`define ResetEnable		`Enable_
	`define ResetDisable	`Disable_
`endif

//*** Reset behavior description
//		Call in "always_ff @(`ResetTrigger)".
`ifdef AsyncReset
	// Asynchronous and Active High resetting
	`define ClkRstTrigger(C, R)	posedge C or `ResetEdge R
`elsif SyncReset
	// Synchronous and Active High resetting
	`define ClkRstTrigger(C, R)	posedge C
`endif

`endif // _RESET_CONFIG_VH_INCLUDED_
