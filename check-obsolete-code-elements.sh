#!/bin/sh

usage="Usage: $(basename) $0: checks for obsolete forms in all Erlang code found from the current directory"


ergrep 'ex :'
ergrep 'ex:'
ergrep '@doc'
ergrep 'maybe('
ergrep 'Shorthand'
ergrep '<b>'
ergrep '</b>'
ergrep ' ie '
ergrep '<http'

# Potentially lacking:
# Creation date
# Full '%' header lines
