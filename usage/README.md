# How to Extract 3D Photos from Video with the App

Follow these steps using key commands to manually extract and save left and right image pairs from a video file. The steps assume
the video trucks from left to right. 

1. Select an input video file with the "I" key command. 
Select a folder using the "O" key command to save the images extracted from frames.

2. Start by selecting the left eye frame. You can use the Enter key to preview the video in slow motion. 
Pressing Enter again stops the video. 
Use the space key to advance a single frame in the video file. 
The backspace key displays the previous frame.

3. Having selected a left eye frame, place your mouse cursor over a feature point in the frame where the stereo window will be placed.
This point will also be used to align the frames vertically. Features in foreground and in front of the stereo window will pop out.
Click the mouse button to show crosshairs marking this position. Press the "G" key to save this fixed feature position.
A large crosshair will mark this position.

Press the "L" key to label the frame as a left eye view, 
Press "S" key to save the frame in the output folder.
Note: Subjects behind the stereo window have positive parallax, subjects in front of the window have negative parallax.

4. Now advance video frames (space bar) to find a suitable right eye view frame. The crosshair spacing is a percentage of the display window width.
The frame used should be less than 3% of the window width. 
After selecting the right eye frame, use the right arrow key to move the frame so that the two vertical crosshair patterns match.

Press the "R" key to label the frame as right eye. Now if the feature position does not line up vertically with the feature crosshair, use the
up/down arrow keys to position the horizontal crosshairs on the same plane. Press the "S" key to save the right eye frame in the output folder. 

5. Check how the selected left and right views look in stereo by pressing the "A" key to convert to Anaglyph view. 
Use Red-Cyan glasses to see the stereoscopic effect.
If satisfied, save the anaglyph image with the "S" key.
If not satisifed, press the "A" key again to exit anaglypy mode, and then select new left and right views and save again. 
If you change the frame used for the left view you must press the "G" key again to save the large window crosshair position.

6. Press the "+" key to increment the group number for saving a new extracted photo group.


## Screenshot

![Analog screenshot](screenshots/screenshot_anaglyph.jpg)


