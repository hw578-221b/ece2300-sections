//========================================================================
// FullAdder_GL
//========================================================================

`ifndef FULL_ADDER_GL_V
`define FULL_ADDER_GL_V

`include "ece2300/ece2300-misc.v"

module FullAdder_GL
(
  (* keep=1 *) input  wire in0,
  (* keep=1 *) input  wire in1,
  (* keep=1 *) input  wire cin,
  (* keep=1 *) output wire cout,
  (* keep=1 *) output wire sum
);

  wire [3:0] tmp;
  
  xor(sum, in0, in1, cin);

  and(tmp[0], in0, in1);
  and(tmp[1], in0, cin);
  and(tmp[2], in1, cin);

  or(tmp[3], tmp[0], tmp[1]);
  or(cout, tmp[3], tmp[2]);

endmodule

`endif /* FULL_ADDER_GL_V */

