# $Id$
#
# Copyright (c) 2008, Jon Hart 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY Jon Hart ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Jon Hart BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Stream Control Transmission Protocol
#  http://tools.ietf.org/html/rfc4960
module Racket
class SCTP < RacketPart
  # Source port
  unsigned :src_port, 16
  # Destination port
  unsigned :dst_port, 16
  # Verification tag
  unsigned :verification, 32
  # Checksum
  unsigned :csum, 32
  rest :payload

  # Add a new SCTP chunk (see http://tools.ietf.org/html/rfc4960)
  def add_chunk(type, flags, length, data)
    @chunks << [ type, flags, length, data ]
  end

  def checksum?
    self.csum == compute_checksum
  end

  def checksum!
    self.csum = compute_checksum
  end

  # (really, just set the checksum)
  def fix!
    self.payload = ""
    @chunks.each do |c|
      self.payload += c.pack("CCna*")
    end
    self.checksum!
  end

  def initialize(*args)
    @chunks = []
    super
  end

private
  def compute_checksum
    # XXX this is currently incorrect
    pseudo = [ self.src_port, self.dst_port, self.verification, 0, self.payload] 
    #L3::Misc.checksum(pseudo.pack("nnNNa*"))
    require 'zlib'
    Zlib.crc32(pseudo.pack("nnNNa*"))
  end
end
end
# vim: set ts=2 et sw=2:
