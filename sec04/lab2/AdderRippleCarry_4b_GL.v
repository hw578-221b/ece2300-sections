//========================================================================
// AdderRippleCarry_4b_GL
//========================================================================

`ifndef ADDER_RIPPLE_CARRY_4B_GL_V
`define ADDER_RIPPLE_CARRY_4B_GL_V

`include "ece2300/ece2300-misc.v"
`include "lab2/FullAdder_GL.v"

module AdderRippleCarry_4b_GL
(
  (* keep=1 *) input  wire [3:0] in0,
  (* keep=1 *) input  wire [3:0] in1,
  (* keep=1 *) input  wire       cin,
  (* keep=1 *) output wire       cout,
  (* keep=1 *) output wire [3:0] sum
);

  wire [2:0] carry;

  FullAdder_GL fa0 (
    .in0(in0[0]),
    .in1(in1[0]),
    .cin(cin),
    .cout(carry[0]),
    .sum(sum[0])
  );

  FullAdder_GL fa1 (
    .in0(in0[1]),
    .in1(in1[1]),
    .cin(carry[0]),
    .cout(carry[1]),
    .sum(sum[1])
  );

  FullAdder_GL fa2 (
    .in0(in0[2]),
    .in1(in1[2]),
    .cin(carry[1]),
    .cout(carry[2]),
    .sum(sum[2])
  );

  FullAdder_GL fa3 (
    .in0(in0[3]),
    .in1(in1[3]),
    .cin(carry[2]),
    .cout(cout),
    .sum(sum[3])
  );

endmodule

`endif /* ADDER_RIPPLE_CARRY_4B_GL_V */

