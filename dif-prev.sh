#!/bin/sh

usage="Usage: $(basename $0) [FILES]: compares the current (committed) version of specified file(s) with their previous one."

#svn diff -r PREV:BASE $* | more

# See https://stackoverflow.com/questions/10176601/git-diff-file-against-its-last-change/:
git log -p -1 $*
