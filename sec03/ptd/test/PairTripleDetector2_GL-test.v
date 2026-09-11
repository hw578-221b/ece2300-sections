//========================================================================
// PairTripleDetector2_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"
`include "ptd/PairTripleDetector2_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  TestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [2:0] a;
  logic [2:0] b;
  logic       out;

  PairTripleDetector2_GL dut
  (
    .a   (a),
    .b   (b),
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
    input logic [2:0] a_,
    input logic [2:0] b_,
    input logic       out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      #1;

      a = a_;
      b = b_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b > %b", t.cycles, a, b, out );

      `ECE2300_CHECK_EQ( out, out_ );

      #1;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     a       b       out
    check( 3'b000, 3'b000, 0 );
    check( 3'b011, 3'b011, 1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_many_ones
  //----------------------------------------------------------------------

  task test_case_2_many_ones();
    t.test_case_begin( "test_case_2_many_ones" );

    //     a       b       out
    check( 3'b001, 3'b011, 1 );
    check( 3'b010, 3'b011, 1 );
    check( 3'b100, 3'b011, 1 );
    check( 3'b011, 3'b001, 1 );
    check( 3'b011, 3'b010, 1 );
    check( 3'b011, 3'b100, 1 );
    check( 3'b011, 3'b011, 1 );
    check( 3'b110, 3'b110, 1 );
    check( 3'b101, 3'b101, 1 );
    check( 3'b111, 3'b111, 1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_few_ones
  //----------------------------------------------------------------------

  task test_case_3_few_ones();
    t.test_case_begin( "test_case_3_few_ones" );

    check( 3'b100, 3'b100, 0);
    check( 3'b100, 3'b010, 0);
    check( 3'b100, 3'b001, 0);
    
    check( 3'b010, 3'b010, 0);
    check( 3'b010, 3'b100, 0);
    check( 3'b010, 3'b001, 0);

    check( 3'b001, 3'b001, 0);
    check( 3'b001, 3'b010, 0);
    check( 3'b001, 3'b100, 0);

    check( 3'b001, 3'b000, 0);
    check( 3'b000, 3'b100, 0);
    check( 3'b000, 3'b000, 0);

    t.test_case_end();
  endtask

  task test_case_4_random();

    logic [2:0] in0, in1;
    logic expec_out;
    int in0_ones, in1_ones;

    t.test_case_begin("test_case_4_random");
    
    for(int i=0; i<20; i=i+1) begin
      in0 = 3'($urandom(t.seed));
      in1 = 3'($urandom(t.seed));

      in0_ones = 0;
      in1_ones = 0;

      for(int j=0; j<3; j=j+1) begin
        if(in0[j])
          in0_ones = in0_ones + 1;
        if(in1[j])
          in1_ones = in1_ones + 1;
      end

      expec_out = (in0_ones > 1) || (in1_ones > 1);

      check( in0, in1, expec_out );
    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_many_ones();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_few_ones();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_random();

    t.test_bench_end();
  end

endmodule

