#!/bin/bash

# set shopt-options used by this shell-script
# Note, 0 (true) from shopt -q is "false" in a math context.
shopt -q globstar; globstar_set=$?
((globstar_set)) && shopt -s globstar
shopt -q extglob; extglob_set=$?
((extglob_set)) && shopt -s extglob

# return default shopt-options
function finish {
	((globstar_set)) && shopt -u globstar
	((extglob_set)) && shopt -u extglob
}
trap finish EXIT

# setting default extension to mp3
if [ $# -eq 0 ]; then
	extension="mp3"
else
	extension=$@
fi

for file in **/*.@(${extension// /|}); do
	ffmpeg -threads 4 -i $file -c:a libopus -b:a 128k "${file%.*}.opus" && rm "$file"
done

exit 0
