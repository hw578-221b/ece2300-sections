//========================================================================
// Mux2_4b_RTL
//========================================================================

`ifndef MUX2_4B_RTL
`define MUX2_4B_RTL

`include "ece2300/ece2300-misc.v"

module Mux2_4b_RTL
(
  (* keep=1 *) input  logic [3:0] in0,
  (* keep=1 *) input  logic [3:0] in1,
  (* keep=1 *) input  logic       sel,
  (* keep=1 *) output logic [3:0] out
);

  assign out = sel? in1 : in0;

endmodule

`endif /* MUX2_4B_RTL */

