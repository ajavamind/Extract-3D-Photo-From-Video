// Export 3D video file using left and right frame difference in original input video
// Uses Video Export library for Processing from https://funprogramming.org/VideoExport-for-Processing/
// You need to download and install FFmpeg on your system before you can use this library.
// The exported video is compressed using the h264 codec.

import com.hamoid.*;

VideoExport videoExport;

int rotate = 0; // 90;  // for test 
Movie lMovie;
Movie rMovie;
private static final int NO_VIDEO = 0;
private static final int SETUP_VIDEO = 1;
private static final int WRITE_VIDEO = 2;
private static final int FINISHED_VIDEO = 3;
int saveVideo = NO_VIDEO;

String outputVideoType = ".mp4";  // with H264 codec
//String outputVideoType = ".avi";  // with H264 codec

void videoSetup() {
  // Load and set the video to play. Setting the video 
  // in play mode is needed so at least one frame is read
  // and we can get duration, size and other information from
  // the video stream. 
  lMovie = new Movie(this, filenamePath);
  rMovie = new Movie(this, filenamePath);
  videoSetup(lMovie);
  videoSetup(rMovie);
  setFrame(lMovie, leftFrame, true);  
  setFrame(rMovie, rightFrame, true);  

  String vFile = configuration[OUTPUT_FOLDER]+File.separator+name+"_"+counter+"_2x1"+outputVideoType;
  if (DEBUG) println("Create video file " + vFile);
  videoExport = new VideoExport(this, vFile);
  videoExport.setQuality(70, 128);
  videoExport.setFrameRate(10);  // 30 default
  videoExport.startMovie();
}

private void videoSetup(Movie mov) {
  // Pausing the video at the first frame. 
  mov.play();
  mov.jump(0);
  mov.pause();
}

void videoDraw() {
  background(0);
  fill(0);
  if (rotate > 0) {
    imageMode(CENTER);
    float angle = radians(rotate);
    push();
    translate(width/4, height/2);
    rotate(angle);
    image(lMovie, 0, height/4, lMovie.width/2, lMovie.height/2);
    pop();
    push();
    translate(3*width/4, height/2);
    rotate(angle);
    image(rMovie, 0, height/4, rMovie.width/2, rMovie.height/2);
    pop();
    if (DEBUG) {
      text(getFrame(lMovie) + " / " + (getLength(lMovie)-1), 0, height/2);
      text(getFrame(rMovie) + " / " + (getLength(rMovie)-1), width/2, height/2);
    }
  } else {
    image(lMovie, 0, (height-(width/2)/movieAspectRatio)/2, (width/2), (width/2)/movieAspectRatio);
    image(rMovie, width/2, (height-(width/2)/movieAspectRatio)/2, (width/2), (width/2)/movieAspectRatio);   
    //if (DEBUG) {
    fill(255);
    text(getFrame(lMovie) + " / " + (getLength(lMovie)-1), 0, height-20);
    text(getFrame(rMovie) + " / " + (getLength(rMovie)-1), width/2, height-20);
    //}
  }

  videoExport.saveFrame();
  //videoExport.setGraphics(PImage img);

  leftFrame++;
  rightFrame++;
  setFrame(lMovie, leftFrame, false);  
  setFrame(rMovie, rightFrame, false);  
  if (rightFrame >getLength(rMovie)) {
    if (DEBUG) println("Video saved "+ videoExport.toString());
    videoExport.endMovie();
    videoExport.dispose();
    lMovie.dispose();
    rMovie.dispose();

    saveVideo = FINISHED_VIDEO;
    displayMessage("Saved 3D SBS Video "+configuration[OUTPUT_FOLDER]+File.separator+name+"_2x1.mp4", 60);
  }
}
