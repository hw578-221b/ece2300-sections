//========================================================================
// PairTripleDetector_GL_adhoc
//========================================================================

`include "PairTripleDetector_GL.v"

module Top();

  // Declare wires which will be connected to the design-under-test. Note
  // that we use "logic" not "wire" in test benches. A "logic" is a more
  // abstract kind of signal than a "wire" in Verilog.

  logic in0;
  logic in1;
  logic in2;
  logic out;

  // Instantiate the design-under-test (DUT) and hook up the ports to the
  // logic signals we just declared.

  PairTripleDetector_GL dut
  (
    .in0 (in0),
    .in1 (in1),
    .in2 (in2),
    .out (out)
  );

  // An initial block is a special piece of code which starts running at
  // the beginning of a simulation. You should NEVER use an initial block
  // when modeling hardware. But it is perfectly fine to use an initial
  // block in your test benches.

  initial begin

    // These system tasks are used to tell the simulator to output a VCD
    // file which contains waveforms so we can visualize what our
    // hardware design is doing.

    $dumpfile("waves1.vcd");
    $dumpvars;

    // Set input values for all input ports. Then wait 10 units of time.
    // Then we display all of the input and output values. We do this
    // four times with four different sets of input values.

    in0 = 0;
    in1 = 0;
    in2 = 0;
    #10;
    $display( "%b %b %b > %b", in0, in1, in2, out );

    in0 = 0;
    in1 = 1;
    in2 = 1;
    #10;
    $display( "%b %b %b > %b", in0, in1, in2, out );

    in0 = 0;
    in1 = 1;
    in2 = 0;
    #10;
    $display( "%b %b %b > %b", in0, in1, in2, out );

    in0 = 1;
    in1 = 1;
    in2 = 1;
    #10;
    $display( "%b %b %b > %b", in0, in1, in2, out );

  end

endmodule

