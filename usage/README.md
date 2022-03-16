# How to Extract 3D Photos from Video with the App

Follow these steps using key commands to manually extract and save left and right image pairs from a video file. The steps assume
the video trucks from left to right. The "H" key toggles information display and a key command help summary.

1. When the app first starts, an output folder is requested. To select an output folder for saving images extracted from frames use the "O" key command. Select an input video file with the "I" key command. 


2. Start by selecting the left eye frame. You can use the Enter key to preview the video in slow motion. 
Pressing Enter again will stop the video. The "Z" key rewinds the video. 
Use the space key to advance a single frame in the video file. 
The backspace key goes back to the previous frame. The "tab" key will advance 10 video frames.

3. Having selected a left eye frame, place your mouse cursor over a feature point in the frame where the stereo window will be placed.
This point will also be used to align the frames vertically. Features in the foreground that are in front of the stereo window will pop out.
Click the mouse button to show crosshairs marking this position. Press the "L" key to save this fixed feature position for the left eye view.
A large crosshair will mark this position and the frame will be saved in the output folder.

4. Now advance video frames (space bar) to find a suitable right eye view frame. The crosshair spacing width is a percentage of the display window width.
By default the crosshair spacing is 1% of the window width. The frame used should have a feature displacement of less than 3% of the window width. 
Mouse click on the feature point you selected previously when the offset reaches your desired displacement.  Use the right arrow key to move the frame so that the two vertical crosshair patterns line up. The "G" key will toggle the crosshair pattern on and off to see the feature position more clearly.

5. If the feature position does not line up vertically with the feature crosshair, use the up/down arrow keys to position the horizontal crosshairs on the same plane. 
Press the "R" key to label the frame as right eye and writes it to the save folder.

6. Check how the selected left and right views look in stereo by pressing the "A" key to convert to Anaglyph view. 
Use Red-Cyan glasses to see the stereoscopic effect.
If not satisifed, press the "A" key again to exit anaglyph mode, adjust the position of the alignment of the right eye view with the right or left arrow keys for more or less displacement. The right eye view frame is automatically saved with these changes.

7. You may also select a new right eye view by changing the frame. Mark the fixed feature position by clicking the mouse cursor over this image feature.
If you change the frame used for the left view you must press the "L" key again to save the large window crosshair position that 
defines the placement of the stero window. 

8. Start over with a new group for major changes. Press the "+" key to increment the group number for saving extracted photos in a new photo group.

9. The "K" key will save the selected frame in its original video resolution, without any alignment adjustments.
These files can be aligned with Stereo Photo Maker and set the stereo window automatically. With SPM you can also set the stereo window manually.
Note that this app does not correct for rotation alignment, SPM provides full alignment tools.

10. The "S" key will save the left and right image pair as a side-by-side SBS stereo image file. For this you need ImageMagick installed on your computer because it is called from a Windows batch file.

