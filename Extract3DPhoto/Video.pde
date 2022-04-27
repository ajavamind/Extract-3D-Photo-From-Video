// Export 3D video file using left and right frame difference in original input video
// Uses Video Export library for Processing from https://funprogramming.org/VideoExport-for-Processing/
// You need to download and install FFmpeg on your system before you can use this library.
// The exported video is compressed using the h264 codec.

//import com.hamoid.*;

VideoExport videoExport;

private static final int FULL_WIDTH_SBS = 0;
private static final int FULL_WIDTH_BORDER_SBS = 1;
private static final int HALF_WIDTH_SBS = 2;
private static final int FULL_WIDTH_CROP_SBS = 3;
private static final int ROTATE = 4;

int vFormat = FULL_WIDTH_SBS; // FULL_WIDTH_BORDER_SBS;
int rotate = 0; // 90;  // degrees

Movie lMovie;
Movie rMovie;
PGraphics pg;

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
  savedLeftFrame = leftFrame;
  savedRightFrame = rightFrame;
  videoSetup(lMovie);
  videoSetup(rMovie);
  setFrame(lMovie, leftFrame);
  setFrame(rMovie, rightFrame);

  String vFile = configuration[OUTPUT_FOLDER]+File.separator+name+"_"+convert(counter)+
    "_"+convert(leftFrame)+"_"+convert(rightFrame)+"_2x1"+outputVideoType;
  if (DEBUG) println("Create video file " + vFile);

  try {
    if (vFormat == FULL_WIDTH_SBS) {
      pg = createGraphics(2*lMovie.width, lMovie.height);
      videoExport = new VideoExport(this, vFile, pg);
    } else {
      videoExport = new VideoExport(this, vFile);
    }
  }
  catch (Error err) {
    println("Error "+err.toString());
    err.printStackTrace(logger);
    logger.flush();
  }
  catch (Exception ex) {
    println("Exception "+ ex.toString());
    ex.printStackTrace(logger);
    logger.flush();
  }
  if (DEBUG) println("constructor: " + videoExport.toString()+ videoExport.ffmpegFound());
  videoExport.setQuality(70, 128);
  //videoExport.setFrameRate(movie.sourceFrameRate);  // 30 default or uncomment for input movie framerate
  videoExport.startMovie();
  if (DEBUG) println("startMovie() "+videoExport.toString());
}

private void videoSetup(Movie mov) {
  // Pausing the video at the first frame.
  mov.play();
  mov.jump(0);
  mov.pause();
}

void videoDraw(boolean stop) {
  background(0);
  fill(0);

  if (vFormat == ROTATE) {
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
  } else if (vFormat == FULL_WIDTH_CROP_SBS) {
    image(lMovie, 0, 0, lMovie.width, lMovie.height);
    image(rMovie, width/2, 0, lMovie.width, lMovie.height);
  } else if (vFormat == HALF_WIDTH_SBS) {
    image(lMovie, 0, 0, lMovie.width/2, lMovie.height);
    image(rMovie, width/2, 0, lMovie.width/2, lMovie.height);
  } else if (vFormat == FULL_WIDTH_BORDER_SBS) {
    image(lMovie, 0, (height-(width/2)/movieAspectRatio)/2, (width/2), (width/2)/movieAspectRatio);
    image(rMovie, width/2, (height-(width/2)/movieAspectRatio)/2, (width/2), (width/2)/movieAspectRatio);
  }

  if (vFormat == FULL_WIDTH_SBS) {
    pg.beginDraw();
    pg.background(0);
    if (leftToRight) {
      pg.image(lMovie, 0, 0, lMovie.width, lMovie.height);
      pg.image(rMovie, pg.width/2, 0, rMovie.width, rMovie.height);
    } else {
      pg.image(rMovie, 0, 0, rMovie.width, rMovie.height);
      pg.image(lMovie, pg.width/2, 0, lMovie.width, lMovie.height);
    }
    pg.endDraw();
    image(pg, 0, height/4, width, (float) width/((float)pg.width/(float)pg.height));
  }
  videoExport.saveFrame();

  fill(255);
  if (vFormat == ROTATE) {
    text(getFrame(lMovie) + " / " + (getLength(lMovie)-1), 0, height/2);
    text(getFrame(rMovie) + " / " + (getLength(rMovie)-1), width/2, height/2);
  } else {
    text(getFrame(lMovie) + " / " + (getLength(lMovie)-1), 0, height-20);
    text(getFrame(rMovie) + " / " + (getLength(rMovie)-1), width/2, height-20);
  }

  leftFrame++;
  rightFrame++;
  setFrame(lMovie, leftFrame);
  setFrame(rMovie, rightFrame);
  if (rightFrame >getLength(rMovie) || stop) {
    if (DEBUG) println("Video saved "+ videoExport.toString());
    videoExport.endMovie();
    videoExport.dispose();
    lMovie.stop();
    lMovie.dispose();
    rMovie.stop();
    rMovie.dispose();
    lMovie = null;
    rMovie = null;
    saveVideo = FINISHED_VIDEO;
    displayMessage("Saved 3D SBS Video "+configuration[OUTPUT_FOLDER]+File.separator+name+"_2x1.mp4", 60);
  }
}
