# Extract-3D-Photo-From-Video

## Motivation
I like to capture 3D photos with a single camera, taking left and right eye view photos sequentially (the cha-cha method). This works for stationary subjects and static scenes without any motion. Any subject motion makes the stereo view uncomfortable to look at. Otherwise for events or subjects in motion, I use a homemade nearly synchronized twin camera rig for stereo capture and a 3D photo alignment tool like Stereo Photo Maker.

When I capture sequential left/right photos, I have to be aware of my subject distance and background to obtain an ideal interaxial spacing between shots. Sometimes I use multiple exposure in the camera to judge the camera spacing I need for good stereo. With a twin camera rig, the camera spacing determines how far from the subject I should be to get the best stereo photo.

I began experimenting with 3D sequential capture from a single 2D left to right video (trucking) and then picked out the left and right eye frames with images that gave good stereo results. This way I do not need to be too concerned with my sequential shot camera spacing, I could select left/right view frames with good disparity for my subject. 

The major issue when shooting the video is getting smooth camera movement in a straight line to minimize poor stereo artifacts in the resulting 3D photo, making the photo uncomfortable to view. Otherwise I would need better tools for stereo photo alignment.

I could not find an existing application to extract acceptable and view video frames for stereo, 
so I wrote my own application and made it open source here. 

## The Application
This Java application for Windows, written in the Processing Java language/framework SDK, assists with ___manual extraction___ of left and right eye image pairs from motion videos that truck left to right. Multiple groups of extracted images can be saved for 3D stereo photos, 4V quad stereo photos displayable on a Leia Lumpad glasses free 3D tablet display, and photo collections for creating 3D lenticular images. 

The app requires a truck motion video that capture static scences of stationary subjects for 3D viewing after image extraction. The motion video contains multiple sequential image captures of left and right views without determining precise camera interaxial distances for the best stereo image capture based on the camera distance from the subject and background. The app aids to setting the best displacement between left and right eye views for comfortable 3D stereo viewing. 
 
Single key commands control the app operation to extract the left and right eye view photos. These commands are defined in help.txt. There is no graphical user interface to invoke the commands provided.

Mouse press displays crosshairs that define a point in a movie frame scene for setting the stereo window. This point should be close to the foreground to reduce negative parallax (scene elements may pop out towards the viewer excessively) in the stereo photo. The cross hair line width helps the user to avoid 3D disparities that exceed 3% of the display width. 3D Images with disparities more than 3% are uncomfortable to view.

A stereo pair extracted from the video can be checked for good 3D viewing by a command that displays the 3D image in anaglyph. If more or less disparity is needed the right eye photo can be shifted with arrow keys or changed by going forward or backward one frame at a time, and then view the extracted image pairs again. 

I found that extracting 4V images the disparity between each image should not exceed 1% (default crosshair spacing), even better to have less disparity. This is the reason for adjusting the percent spacing in the crosshair grid.

Currently the size of the extracted saved photos is the size of the display window the application execution window. A specified size(width, height) window or full screen can be defined in the application's settings() function. There is an option to save the video frame size as extracted without any alignment. Stereo Photo Maker is needed to align the extracted photos. Stereo Photo Maker is also need to align for rotation errors because the application does not provide this kind of alignment.

So far I have experimented with mp4 video files with resolutions of 1920x1080, 3840x2160 (4K), and 7680x4320 (8K) pixels. The 8K video files are noticibly slow reads on my computer, almost to the point of being not practical. The source of the videos are my Samsung phone and DSLR camera.

## Application Environment
The application requires a minimum 1080P display monitor, 1920x1080 pixels for display. I recommend 16 GB of RAM and a fast CPU.

The application requires ImageMagick software installed on your computer. It is used for creating side-by-side and 2x2 photo quilts. Windows batch files call ImageMagick for this task.

## Building the Application
Building the application requires you to download install the [Processing.org SDK](https://processing.org/). This is free software.
You compile and run the Extract 3D Photo application in the Processing SDK for Windows or Linux (version 3.5.4) (I have not tried Linux yet).

Create the Windows application exe file with the Processing SDK using its Export Application menu selection. This will create both application.windows32 or application.windows64 folders with the Extract3DPhoto.exe file and supporting libraries.

Note that the application 32-bit version requires installation of Java. The 64-bit version has Java built-in.

## Running the Application
You can run the application from the Processing SDK.

Here is a link to download a zip file containing the latest version of the application for Windows [application.windows64](https://drive.google.com/file/d/1Ph-0zexFHO-q4oeq6kG9E0ZH3l7FfMlf/view?usp=sharing).

## Application Issues
1. There is a bug where the application sometimes has trouble reading the frame rate of some video files. This may be caused by the Processing video library that uses an old version GStreamer 1.16.2. The video file I found this error is MP4 4k video at 60 FPS. Until resolved you may want to only use lower FPS videos.



## Screenshot

![Analog screenshot](screenshots/screenshot_anaglyph.jpg)

## Manual Extraction Tools
To be determined.

## 3D Stereo Photo Editing and Alignment Tools
[Stereo Photo Maker](https://stereo.jpn.org/eng/stphmkr/)

## Automated Tools
These automated tools may be of interest because they capture 3D images sequentially with a single camera:

Camarada - Android app in Google play store at [https://play.google.com/store/apps/details?id=com.aimfire.camarada&hl=en_US&gl=US](https://play.google.com/store/apps/details?id=com.aimfire.camarada&hl=en_US&gl=US)


### Automated Left/Right Frame Extraction Script in Python
[3D Videos 2 Stereo](https://github.com/lasinger/3DVideos2Stereo)

Code for automated depth maps:

[MiDaS](https://github.com/isl-org/MiDaS)

[Youtube demonstration of automated depth map extraction from video](https://www.youtube.com/watch?v=D46FzVyL9I8)

### Semi-automatic Stereo Extraction from Video Footage

[Stereo Conversion PDF paper](https://www.cs.tau.ac.il/~wolf/papers/stereoconversion_web.pdf)


