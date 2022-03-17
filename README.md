# Extract-3D-Photo-From-Video

## Motivation
I like to capture 3D photos with a single camera, taking left and right eye view photos sequentially (the cha-cha method). This works for stationary subjects and static scenes without any motion. Any subject motion makes the stereo view uncomfortable to look at. Otherwise for events or subjects in motion, I use a homemade nearly synchronized twin camera rig for stereo capture and a 3D photo alignment tool like Stereo Photo Maker.

When I use sequential left/right photo capture, I have to be aware of my subject distance and background to obtain an ideal interaxial spacing between shots. Sometimes I use multiple exposure in the camera to judge the camera spacing I need for good stereo. With a twin camera rig, the camera spacing determines how far from the subject I should be to get the best stereo photo.

What if I used a single video (trucking) capture and picked out the left and right eye frames with images that give good stereo results. This way I do not need to be too concerned with my sequential shot camera spacing, I can select left/right view frames with good disparity for my subject. The major issue when shooting the video is getting smooth camera movement in a straight line to minimize poor stereo artifacts in the resulting 3D photo, making the photo uncomfortable to view. Otherwise I would need better tools for stereo photo alignment.

I could not find an existing application to extract acceptable video frames for stereo viewing that would meet my needs, 
so I wrote my own application and made it open source here. I was able to experiment and learn more about stereo photography writing this application.

## The Application
This Java application for Windows, written in the Processing language/framework SDK, assists with ___manual extraction___ of left and right eye image pairs from motion videos that truck left to right. Multiple groups of extracted images can be saved for 3D stereo photos, 4V quad stereo photos displayable on a Leia Lumpad glasses free 3D tablet display, and photo collections for creating 3D lenticular images. 

The app requires a truck motion video that capture static scences of stationary subjects for 3D viewing after image extraction. The motion video contains multiple sequential image captures of left and right views without determining precise camera interaxial distances for the best stereo image capture based on the camera distance from the subject and background. The app aids to setting the best displacement between left and right eye views for comfortable 3D stereo viewing. 
 
Single key commands control the app operation to extract the left and right eye view photos. These commands are defined in help.txt. There is no graphical user interface to invoke the commands provided.

Mouse press displays crosshairs that define a point in a movie frame scene for setting the stereo window. This point should be close to the foreground to reduce negative parallax (scene elements may pop out towards the viewer excessively) in the stereo photo. The cross hair line width helps the user to avoid 3D disparities that exceed 3% of the display width. 3D Images with disparities more than 3% are uncomfortable to view.

A stereo pair extracted from the video can be checked for good 3D viewing by a command that displays the 3D image in anaglyph. If more or less disparity is needed the right eye photo can be shifted with arrow keys or changed by going forward or backward one frame at a time, and then view the extracted image pairs again. 

I found that extracting 4V images the disparity between each image should not exceed 1% (default crosshair spacing), even better to have less disparity. This is the reason for adjusting the percent spacing in the crosshair grid.

Currently the size of the extracted saved photos is the size of the display window the application execution window. A specified size(width, height) window or full screen can be defined in the application's settings() function. There is an option to save the video frame size as extracted without any alignment. Stereo Photo Maker is needed to align the extracted photos. Stereo Photo Maker is also need to align for rotation errors because the application does not provide this kind of alignment.

So far I have experimented with mp4 video files with resolutions of 1920x1080, 3840x2160 (4K), and 7680x4320 (8K) pixels. The 8K video files are noticibly slow reads on my computer, almost to the point of being not practical. The source of the videos are my Samsung phone and DSLR camera.

## Building the Application
When you compile and run the Extract 3D Photo application in the Processing SDK for Windows or Linux (version 3.5.4), you must add the SelectFile contributed library to the Processing SDK. See [Processing Library](https://processing.org/reference/libraries/) information under Contributions.

[SelectFile Library Documentation](https://andrusiv.com/android-select-file/)

## The Application Environment
The application requires ImageMagick software installed on the computer. It is used for creating side-by-side and 2x2 photo quilts. Windows batch files call ImageMagick for this task.

## Screenshot

![Analog screenshot](screenshots/screenshot_anaglyph.jpg)

## Manual Extraction Tools
Other tools:

## Automated Tools
These automated tools may be of interest:

### Automated Left/Right Frame Extraction Script in Python
[3D Videos 2 Stereo](https://github.com/lasinger/3DVideos2Stereo)

Code for automated depth maps:

[MiDaS](https://github.com/isl-org/MiDaS)

[Youtube demonstration of automated depth map extraction from video](https://www.youtube.com/watch?v=D46FzVyL9I8)

### Semi-automatic Stereo Extraction from Video Footage

[Stereo Conversion PDF paper](https://www.cs.tau.ac.il/~wolf/papers/stereoconversion_web.pdf)


