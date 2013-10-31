#!/bin/sh

# Can be run by a normal user.

# Tired to forget how to do it:
/bin/ntpq -p


# Should output something like:

#      remote           refid      st t when poll reach   delay   offset  jitter
# ==============================================================================
# *ntp.tuxfamily.n 195.220.94.163   2 u  258 1024  177   33.150    1.031   0.265
# +obelix.gegeweb. 145.238.203.10   3 u  216 1024  177   24.098   -0.509   0.643
# +ntp.univ-angers 145.238.203.14   2 u  199 1024  177   29.205    0.487   1.057
