//========================================================================
// ptd-sim +a=000 +b=000
//========================================================================
// Author : Christopher Batten (Cornell)
// Date   : September 7, 2024

`include "ptd/PairTripleDetector2_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Instantiate detector
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
  // Perform the simulation
  //----------------------------------------------------------------------

  initial begin

    // Process command line arguments

    if ( $test$plusargs( "help" ) ) begin
      $display("");
      $display(" ptd-sim +a=000 +b=000");
      $display("");
      $finish;
    end

    if ( !$value$plusargs( "a=%b", a ) )
      a = 3'b000;

    if ( !$value$plusargs( "b=%b", b ) )
      b = 3'b000;

    // Advance time

    #10;

    // Display output

    $write( "\n" );
    $display( "a   = %b", a );
    $display( "b   = %b", b );
    $display( "out = %b", out );
    $write( "\n" );

    $finish;
  end

endmodule

