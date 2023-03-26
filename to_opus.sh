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
	
	#set a channel-dependent  bitrate for every audio stream
	command=$(
		ffprobe "$file" -v 0 -show_entries stream=channels,bit_rate -select_streams a -of compact=p=0:nk=1:s="\ " |
		awk -v file="$file" -v file_output="${file%.*}.opus" '
			BEGIN{
				ORS=" ";
				print "ffmpeg -threads 4 -i \""file"\" -map 0:a -c:a libopus"
			}
			{	# https://wiki.xiph.org/Opus_Recommended_Settings
				if($1==1) print $2>=64000 ? "-b:a:"NR-1" 128k" : "-b:a:"NR-1" "$2
				else if($1==2) print $2>=500000 ? "-b:a:"NR-1" 128k" : "-b:a:"NR-1" "$2
				else if($1<=6) print $2>=256000 ? "-b:a:"NR-1" 128k" : "-b:a:"NR-1" "$2
				else print $2>=450000 ? "-b:a:"NR-1" 128k" : "-b:a:"NR-1" "$2
			}
			END{
				print "\""file_output"\" -v 32 -hide_banner"
			}')


	is_video=$(ffprobe "$file" -v 0 -show_entries stream=codec_type -of compact=p=0:nk=1:s="\ " | grep video)
	if [[ -n "$is_video" ]]; then
		eval "$command"
	else
		#eval "$command" && rm "$file"
	fi

done

exit 0
