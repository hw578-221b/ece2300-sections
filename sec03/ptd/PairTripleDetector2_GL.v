//========================================================================
// PairTripleDetector2_GL
//========================================================================

`ifndef PAIR_TRIPLE_DETECTOR2_GL_V
`define PAIR_TRIPLE_DETECTOR2_GL_V

`include "ece2300/ece2300-misc.v"
`include "ptd/PairTripleDetector_GL.v"

module PairTripleDetector2_GL
(
  input  wire [2:0] a,
  input  wire [2:0] b,
  output wire       out
);

  wire out0, out1;

  PairTripleDetector_GL pair_triple_detector1 
  (
    .in0 (a[0]),
    .in1 (a[1]),
    .in2 (a[2]),
    .out (out0)
  );

  PairTripleDetector_GL pair_triple_detector2 
  (
    .in0 (b[0]),
    .in1 (b[1]),
    .in2 (b[2]),
    .out (out1)
  );

  or(out, out0, out1);

endmodule

`endif  /* PAIR_TRIPLE_DETECTOR2_GL_V */

