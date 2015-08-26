# Copyright (C) 2015 Swift Navigation Inc.
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

# cython: embedsignature=True

cimport viterbi27_c as viterbi27
from cpython.mem cimport PyMem_Malloc, PyMem_Free
from libc.string cimport memset

cdef class Viterbi27:
  """
  Wraps the :libfec:`v27` structure and associated functions for
  performing FEC using a Viterbi Decoder 1/2 k=7.

  Parameters
  ----------
  length : int
    Number of bits to decode.

  """
  cdef viterbi27.v27 decoder
  cdef viterbi27.decision_t *decisions

  def __cinit__(self, nbits):
    cdef int nbits_ = nbits
    self.decisions = <viterbi27.decision_t*> PyMem_Malloc(nbits_ * sizeof(viterbi27.decision_t))
    viterbi27.set_decisions_viterbi27(&self.decoder, self.decisions)

  def init(self, state):
    """
    Wraps the function :libfec:`init_viterbi27`.

    Parameters
    ----------
    state : int
      The starting state of the encoder

    """
    cdef int state_ = int(state)
    viterbi27.init_viterbi27(&self.decoder, state_)

  def update_blk(self, symbols, npairs):
    """
    Wraps the function :libfec:`update_viterbi27_blk`.

    Parameters
    ----------
    symbols : list
      List of symbols received on the wire.

    """
    cdef int npairs_ = int(npairs)
    cdef unsigned char *syms = <unsigned char*> PyMem_Malloc(npairs_ * sizeof(unsigned char))

    for i in range(0, npairs_):
      syms[i] = <unsigned char>symbols[i]

    viterbi27.update_viterbi27_blk(&self.decoder, syms, npairs_)

    PyMem_Free(syms)


  def chainback(self, nbits, endstate):
    """
    Wraps the function :libfec:`chainback_viterbi27`.

    Parameters
    ----------
    nbits : int
      Number of bits to decode from the symbols block.
    endstate: int
      End state of the encoder.

    """
    data = []
    cdef int nbits_ = nbits
    cdef int endstate_ = endstate
    cdef unsigned char *data_ = <unsigned char*> PyMem_Malloc((nbits/8) * sizeof(unsigned char))
    memset(data_, 0, (nbits/8) * sizeof(unsigned char))

    viterbi27.chainback_viterbi27(&self.decoder, data_, nbits_, endstate_)

    for i in range(0, nbits/8):
      data += [data_[i]]

    PyMem_Free(data_)

    return data

  def __dealloc__(self):
    PyMem_Free(self.decisions)
