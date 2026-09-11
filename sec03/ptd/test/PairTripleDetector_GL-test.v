//========================================================================
// PairTripleDetector_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"
`include "ptd/PairTripleDetector_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  TestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic in0;
  logic in1;
  logic in2;
  logic out;

  PairTripleDetector_GL dut
  (
    .in0 (in0),
    .in1 (in1),
    .in2 (in2),
    .out (out)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // All tasks start at #1 after the rising edge of the clock. So we
  // write the inputs #1 after the rising edge, and check the outputs #1
  // before the next rising edge.

  task check
  (
    input logic in0_,
    input logic in1_,
    input logic in2_,
    input logic out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      #1;

      in0 = in0_;
      in1 = in1_;
      in2 = in2_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b %b > %b", t.cycles, in0, in1, in2, out );

      `ECE2300_CHECK_EQ( out, out_ );

      #1;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0 in1 in2 out
    check( 0, 0, 0, 0 );
    check( 0, 1, 1, 1 );
    check( 0, 1, 0, 0 );
    check( 1, 1, 1, 1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_exhaustive
  //----------------------------------------------------------------------

  task test_case_2_exhaustive();
    t.test_case_begin( "test_case_2_exhaustive" );

    //     in0 in1 in2 out
    check( 0,  0,  0,  0 );
    check( 0,  0,  1,  0 );
    check( 0,  1,  0,  0 );
    check( 0,  1,  1,  1 );

    check( 1,  0,  0,  0 );
    check( 1,  0,  1,  1 );
    check( 1,  1,  0,  1 );
    check( 1,  1,  1,  1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_exhaustive();

    t.test_bench_end();
  end

endmodule

