#!/bin/bash

ps -e -o vsize,cmd | grep VSZ | grep -v grep
ps -e -o vsize,cmd | grep -v VSZ | sort -r | head -n 30
