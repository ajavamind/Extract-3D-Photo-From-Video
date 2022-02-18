rem Windows batch file runs Image Magick to create parallel SBS JPG 
rem 4V full size remove -resize x1600 option
rem 4V resized to vertical 1600 pixels, no alignment
rem appends _2x1 suffix for LumePad
magick montage %1 %2 -resize x1600 -geometry +0+0 -tile 2x1 %3_1600_2x1.jpg
