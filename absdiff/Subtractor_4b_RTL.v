//========================================================================
// Subtractor_4b_RTL
//========================================================================

`ifndef SUBTRACTOR_4B_RTL_V
`define SUBTRACTOR_4B_RTL_V

`include "ece2300/ece2300-misc.v"

module Subtractor_4b_RTL
(
  (* keep=1 *) input  logic [3:0] in0,
  (* keep=1 *) input  logic [3:0] in1,
  (* keep=1 *) input  logic       bin,
  (* keep=1 *) output logic       bout,
  (* keep=1 *) output logic [3:0] diff
);

  // logic [4:0] result;
  // assign result = in0 - in1 - bin;
  // assign bout = result[4];
  // assign diff = result[3:0];

  logic [4:0] result;
  assign result = {1'b1, in0} - {1'b0, in1} - bin;
  assign bout = ~result[4];
  assign diff = result[3:0];

endmodule

`endif /* SUBTRACTOR_4B_RTL_V */

