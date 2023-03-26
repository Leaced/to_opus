# to_opus
converting all Files with given file extension in your current working directory and all subdirectories to opus. The Script will choose an automatic bitrate for every audiostream dependent on the number of channels and the original bitrate.
See https://wiki.xiph.org/Opus_Recommended_Settings for more information about this.

Executed on videofiles it will make a copy of the audiostream(s) and convert them to opus. The original file remains unaffected.

This script is work in progress and in a early state.

### Example
convert all files with .mp3-extension and .flac-extension to opus
```bash to_opus.sh mp3 flac```

### Dependencies
- ffmpeg

## ToDo:
- better documentation
