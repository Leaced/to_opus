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
	extension=${extension// /|}
fi


echo "extension is $extension"

for file in **/*.@($extension); do
	channels=$(ffprobe "$file" -show_entries stream=channels -select_streams a -of compact=p=0:nk=1 -v 0)	
	streams=$(echo "$channels" | wc -l)
	if [ streams -gt 1 ]; then
		echo "Error: Automatic Bitrate is not supported for files with multiple audiostreams. The default bitrate of 128k will be used"
		channels="2"
	fi

	case $channels in
		1) bitrate="64k";;
		2) bitrate="128k";;
		6) bitrate="256k";;
		8) bitrate="450k";;
		*) continue;;
	esac
	# https://wiki.xiph.org/Opus_Recommended_Settings

	ffmpeg -threads 4 -v 0 -i "$file" -map 0 -c:a libopus -b:a $bitrate "${file%.*}.opus" && rm "$file"
done

exit 0
