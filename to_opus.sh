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


for file in **/*.@($extension); do
	# getting information about the streams
	channels=$(ffprobe "$file" -show_entries stream=channels -select_streams a -of compact=p=0:nk=1 -v 0)
	bitrate=$(ffprobe "$file" -show_entries stream=bit_rate -select_streams a -of compact=p=0:nk=1 -v 0)
	streams=$(echo "$channels" | wc -l)

	# setting bitrate
	if [ streams -gt 1 ]; then
		echo "Error: Automatic Bitrate is not supported for files with multiple audiostreams. The default bitrate of 128k will be used"
		bitrate="128k"
	elif
		case $channels in
			1) if [$bitrate -gt 64000]; then bitrate="64k"; fi;;
			2) if [$bitrate -gt 128000]; then bitrate="128k"; fi;;
			6) if [$bitrate -gt 256000]; then bitrate="256k"; fi;;
			8) if [$bitrate -gt 450000]; then bitrate="450k"; fi;;
			*) bitrate=128k";;
		esac
	fi
	# https://wiki.xiph.org/Opus_Recommended_Settings

	ffmpeg -threads 4 -v 0 -i "$file" -map 0 -c:a libopus -b:a $bitrate "${file%.*}.opus" && rm "$file"
done

exit 0
