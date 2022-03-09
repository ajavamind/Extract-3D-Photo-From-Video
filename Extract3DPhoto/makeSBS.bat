rem Windows batch file runs Image Magick to create parallel SBS JPG 
rem full size remove -resize x1600 option
rem resize to vertical 1600 pixels, no alignment
rem appends _2x1 suffix for Leia LumePad 3D glasses free tablet
magick montage %1 %2 -resize x1600 -geometry +0+0 -tile 2x1 %3_1600_2x1.jpg
pause
