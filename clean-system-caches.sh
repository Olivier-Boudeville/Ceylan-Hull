#!/bin/sh


echo " Cleaning system caches..."

echo "  + full removal of the content of pacman cache"
pacman -Scc
