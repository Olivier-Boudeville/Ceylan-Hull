#!/bin/sh

# Returns a ROT13-encoded version of specified parameters:

echo $* | tr A-Za-z N-ZA-Mn-za-m

