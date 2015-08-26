# Copyright (C) 2015 Swift Navigation Inc.
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

from common cimport *

cdef extern from "libswiftnav/fec.h":
  ctypedef union metric_t:
    unsigned int w[64]

  ctypedef union decision_t:
    unsigned long w[2]

  cdef union branchtab27:
    unsigned char c[32]

  cdef struct v27:
    metric_t metrics1
    metric_t metrics2
    decision_t *dp
    metric_t *old_metrics
    metric_t *new_metrics
    decision_t decisions[756]

  void set_viterbi27_polynomial(int polys[2])
  void init_viterbi27(v27 *vp, int starting_state)
  int update_viterbi27_blk(v27 *vp, const unsigned char sym[], int npairs)
  int chainback_viterbi27(v27 *vp, unsigned char *data, unsigned int nbits,
                          unsigned int endstate)
  void set_decisions_viterbi27(v27 *vp, decision_t *dec)
