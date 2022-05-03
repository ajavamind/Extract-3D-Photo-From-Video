rem Convert video mp4 to mkv format using ffmpeg
rem ffmpeg i input.mp4 -vcodec copy -acodec copy output.mkv
rem
ffmpeg -i %1 -vcodec copy -acodec copy %2
