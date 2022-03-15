rem Windows batch file runs Image magick to create quilt JPG for Looking Glass Portrait
rem appends _qs8x6 suffix for LGP
rem parameter 1 output file name prefix
rem 2-9 parameters are lenticular photo filenames and last parameter output filename prefix
rem incomplete TODO
magick montage %2 %3 %4 %5 %6 %7 %8 %9 -resize 420x560 -geometry +0+0 -tile 8x6 %1_qs8x6a0.75.jpg
