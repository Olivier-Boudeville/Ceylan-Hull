#!/bin/sh

usage="Usage: $(basename $0) [FILES]: compares current (committed) version with previous one, for specified file(s)"

#svn diff -r PREV:BASE $* | more

# See https://stackoverflow.com/questions/10176601/git-diff-file-against-its-last-change/:
git log -p -1 $*
