# How to Extract 3D Photos from Video with the App

Follow these steps using key commands to manually extract and save left and right image pairs from a video file. The steps assume
the video trucks from left to right and you select an appropiate stereo pair. The "H" key toggles information display and a key command help summary.

1. When the app first starts, an output folder is requested. Otherwise at any time select an alternate output folder for saving images extracted from frames with the "O" key command. Select an input video file with the "I" key command. 

2. Start by selecting the left eye frame. You can use the "Enter" key to preview the video in slow motion. 
Pressing Enter again will stop the video. The "Z" key rewinds the video. 
Use the "space bar" key to advance a single frame in the video file. 
The "backspace" key displays the previous frame. The "tab" key will advance 10 video frames.

3. Having selected a left eye frame, place your mouse cursor over a feature point in the frame where the stereo window will be placed.
This point will also be used to align the frames vertically and horizontally. Subjects in the foreground in front of the stereo window will pop out.
Subjects behind the feature point are behind the stereo window. Click the mouse button to show crosshairs marking this position. 
Press the "L" key to save this fixed feature position for the left eye view.
A large crosshair will mark this feature position and the frame will be saved in the output folder.

4. Now advance one or more video frames with the "space bar" to find a suitable right eye view frame. 
The crosshair spacing width is a percentage of the display window width.
By default the crosshair spacing is 1% of the window width. The right frame used should have a feature displacement of about 3% of the window width. 
Mouse click on the feature point you selected previously when the offset reaches your desired displacement.  
The "G" key will toggle the crosshair pattern on and off to see the feature position more clearly. 
Press the "R" key to label the frame as right eye. 
The frame will align vertically and horizontally with the left view feature position and the command writes the right eye frame to the save folder.

6. Check how the selected left and right views look in stereo by pressing the "A" key to convert to Anaglyph view. 
Use Red-Cyan glasses to see the stereoscopic effect.
If not satisifed, press the "A" key again to exit anaglyph mode, adjust the position of the alignment of the right eye view with the right or left arrow keys for more or less displacement to position the stereo window. The right eye view frame is automatically saved with arrow key changes.
Do not press "R" again unless you want to restore the initial alignment offsets.

7. You may also select a new right eye view by changing the frame. Mark the fixed feature position by clicking the mouse cursor on the image feature.
If you change the frame used for the left view you must press the "L" key again to save the large window crosshair position that 
defines the placement of the stero window. 

8. Start over with a new group for major changes. Press the "+" key to increment the group number for saving extracted photos in a new photo group.

9. The "K" key will save the selected frame in its original video resolution, without any alignment adjustments.
These files can be aligned with Stereo Photo Maker and set the stereo window automatically. With SPM you can also set the stereo window manually.
Note that this app does not correct for rotational alignment, so use Stereo Photo Maker for the best full alignment.

10. The "S" key will save the left and right image pair as a side-by-side SBS stereo image file. For this you need ImageMagick installed on your computer because it is called from a Windows batch file.

