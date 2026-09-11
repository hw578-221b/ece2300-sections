#=========================================================================
# ptd
#=========================================================================

ptd_srcs = \
  PairTripleDetector_GL.v \
  PairTripleDetector2_GL.v \

ptd_tests = \
  PairTripleDetector_GL-test.v \
  PairTripleDetector2_GL-test.v \

ptd_sims = \
  ptd-sim.v \

$(eval $(call check_part,ptd))
