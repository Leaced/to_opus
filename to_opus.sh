#!/usr/bin/env bash

shopt -q globstar; globstar_set=$?
((globstar_set)) && shopt -s globstar
shopt -q extglob; extglob_set=$?
((extglob_set)) && shopt -s extglob
# Note, 0 (true) from shopt -q is "false" in a math context.

FORMATS=$@

for file in **/*.@(${FORMATS// /|}); do
	ffmpeg -threads 4 -i "$file" -c:a libopus -b:a 128k "${file%.*}.opus" && rm "$file"
done

((globstar_set)) && shopt -u globstar
((extglob_set)) && shopt -u extglob

exit 0
