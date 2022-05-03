rem Windows batch file runs Image Magick to create parallel SBS JPG 
rem full size remove -resize x1080 option
rem resize to vertical 1080 pixels, no alignment
rem appends _2x1 suffix for Leia LumePad 3D glasses free tablet
magick montage %1 %2 -resize x1080 -geometry +0+0 -tile 2x1 %3_1080_2x1.jpg
