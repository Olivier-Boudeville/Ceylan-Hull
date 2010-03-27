#!/bin/sh

# Compares current (committed) version with previous one:

svn diff -r PREV:BASE $* | more
