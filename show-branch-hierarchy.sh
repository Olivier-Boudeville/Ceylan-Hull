#!/bin/sh

usage="Usage: $(basename $0): shows the hierarchy of the branches in the current VCS repository"

git log --all --graph --decorate --oneline --simplify-by-decoration
