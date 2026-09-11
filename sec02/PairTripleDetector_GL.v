//========================================================================
// PairTripleDetector_GL
//========================================================================

`ifndef PAIR_TRIPLE_DETECTOR_GL_V
`define PAIR_TRIPLE_DETECTOR_GL_V

`include "ece2300-misc.v"

module PairTripleDetector_GL
(
  input wire  in0,
  input wire  in1,
  input wire  in2,
  output wire out
);

wire OR1, AND1, AND2;

or(OR1, in0, in1);
and(AND1, in0, in1);
and(AND2, OR1, in2);
or(out, AND1, AND2);

endmodule

`endif /* PAIR_TRIPLE_DETECTOR_GL_V */

