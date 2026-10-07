//========================================================================
// AdderRippleCarry_4b_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"
`include "lab2/AdderRippleCarry_4b_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  TestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [3:0] in0;
  logic [3:0] in1;
  logic       cin;
  logic       cout;
  logic [3:0] sum;

  AdderRippleCarry_4b_GL dut
  (
    .in0  (in0),
    .in1  (in1),
    .cin  (cin),
    .cout (cout),
    .sum  (sum)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic [3:0] in0_,
    input logic [3:0] in1_,
    input logic       cin_,
    input logic       cout_,
    input logic [3:0] sum_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      #1;

      in0 = in0_;
      in1 = in1_;
      cin = cin_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b + %b + %b (%2d + %2d + %b) > %b %b (%2d)", t.cycles,
                  in0, in1, cin, in0, in1, cin, cout, sum, sum );

      `ECE2300_CHECK_EQ( cout, cout_ );
      `ECE2300_CHECK_EQ( sum,  sum_ );

      #1;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0      in1      cin   cout  sum
    check( 4'b0000, 4'b0000, 1'b0, 1'b0, 4'b0000 );
    check( 4'b0001, 4'b0001, 1'b0, 1'b0, 4'b0010 );

    t.test_case_end();
  endtask

  task test_case_2_directed();
    t.test_case_begin( "test_case_2_directed" );

    //     in0      in1      cin   cout  sum
    check( 4'b0010, 4'b0010, 1'b0, 1'b0, 4'b0100 );
    check( 4'b0010, 4'b0010, 1'b1, 1'b0, 4'b0101 );
    check( 4'b1000, 4'b1000, 1'b0, 1'b1, 4'b0000 );
    check( 4'b1000, 4'b1000, 1'b1, 1'b1, 4'b0001 );
    check( 4'b0111, 4'b0111, 1'b0, 1'b0, 4'b1110 );
    check( 4'b0111, 4'b0111, 1'b1, 1'b0, 4'b1111 );
    check( 4'bxxxx, 4'bxxxx, 1'bx, 1'bx, 4'bxxxx );

    t.test_case_end();
  endtask

  logic [3:0] rand_in0;
  logic [3:0] rand_in1;
  logic       rand_cin;
  logic [4:0] rand_result; // this must be 5-bit not 4-bit!
  logic       rand_cout;
  logic [3:0] rand_sum;

  task test_case_3_random();
    t.test_case_begin( "test_case_3_random" );

    rand_in0 = 4'($urandom(t.seed));
    rand_in1 = 4'($urandom(t.seed));
    rand_cin = 1'($urandom(t.seed));
    
    rand_result = rand_in0 + rand_in1 + rand_cin;
    {rand_cout, rand_sum} = rand_result;

    for(int i=0; i<40; i=i+1)
      check(rand_in0, rand_in1, rand_cin, rand_cout, rand_sum);
    
    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_random();

    t.test_bench_end();
  end

endmodule
