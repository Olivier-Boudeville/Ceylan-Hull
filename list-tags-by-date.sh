#!/bin/sh

usage="Usage: $(basename $0): lists, for the current VCS (GIT) repository, all (annotated) tags, from the oldest one to the latest one."

echo "  Listing repository tags, from oldest to newest:"

# Removing empty lines:
git for-each-ref --sort=taggerdate --format '%(tag)' | sed '/^[[:space:]]*$/d'
