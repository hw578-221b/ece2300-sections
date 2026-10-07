#=========================================================================
# lab2
#=========================================================================

lab2_srcs = \
  FullAdder_GL.v \
  AdderRippleCarry_4b_GL.v \

lab2_tests = \
  FullAdder_GL-test.v \
  AdderRippleCarry_4b_GL-test.v \

lab2_sims =

$(eval $(call check_part,lab2))
