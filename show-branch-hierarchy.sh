#!/bin/sh

# Shows the hierarchy of the GIT branches in the current repository.

git log --all --graph --decorate --oneline --simplify-by-decoration
