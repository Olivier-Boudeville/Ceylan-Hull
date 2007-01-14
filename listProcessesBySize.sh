#!/bin/sh

ps -e -o vsize,cmd | grep VSZ | grep -v grep
ps -e -o vsize,cmd | grep -v VSZ | sort -nr | head -n 30

