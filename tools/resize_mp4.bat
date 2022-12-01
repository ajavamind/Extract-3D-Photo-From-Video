rem resize mp4 file to 1080p
rem ffmpeg -i %1 -filter:v scale=3840:-1 -c:a copy output.mkv
rem ffmpeg -i %1 -s 720x480 -c:a copy output.mkv
ffmpeg -i %1 -s %2 -c:a copy output.mp4