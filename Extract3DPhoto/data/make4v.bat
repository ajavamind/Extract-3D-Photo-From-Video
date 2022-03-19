rem Windows batch file runs Image magick to create 2x2 JPG for Leia Inc LumePad glasses free 3D tablet display
rem 4V full size remove -resize x1600 option
rem 4V resized to vertical 1600 pixels, no alignment
rem appends _2x2 suffix for LumePad
rem 1-4 parameters are LL LM RM RR image filenames and 5th parameter output filename prefix
magick montage %1 %2 %3 %4 -resize x1600 -geometry +0+0 -tile 2x2 %5_1600_2x2.jpg
