#!/bin/sh

usage="Usage: $(basename $0) PARAM [...]: returns a ROT13-encoded version of specified parameters."

echo $* | tr A-Za-z N-ZA-Mn-za-m
