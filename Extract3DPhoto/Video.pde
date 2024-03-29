// Export 3D video file using left and right frame difference in original input video
// Uses Video Export library for Processing from https://funprogramming.org/VideoExport-for-Processing/
// You need to download and install FFmpeg on your system before you can use this library.
// The exported video is compressed using the h264 codec.

//import com.hamoid.*;

VideoExport videoExport;

private static final int FULL_WIDTH_SBS = 0; // for 2D to 3D full SBS
private static final int FULL_WIDTH_BORDER_SBS = 1;
private static final int HALF_WIDTH_SBS = 2;
private static final int FULL_WIDTH_CROP_SBS = 3;
private static final int ROTATE = 4;
private static final int FULL_WIDTH_SBS_MERGE = 5;  // for Qoocam EGO video inputs

//private int vFormat = FULL_WIDTH_SBS; // FULL_WIDTH_BORDER_SBS;
private int vFormat = FULL_WIDTH_SBS_MERGE; // FULL_WIDTH_BORDER_SBS;
private int rotate = 0; // 90;  // degrees

private Movie lMovie;
private Movie rMovie;
private PGraphics pg;

private static final int NO_VIDEO = 0;
private static final int SETUP_VIDEO = 1;
private static final int WRITE_VIDEO = 2;
private static final int FINISHED_VIDEO = 3;
private int saveVideo = NO_VIDEO;

String outputVideoType = ".mp4";  // with H264 codec
//String outputVideoType = ".avi";  // with H264 codec
String vFile;

boolean videoSetup() {
  // Load and set the video to play. Setting the video
  // in play mode is needed so at least one frame is read
  // and we can get duration, size and other information from
  // the video stream.
  boolean success = true;
  vFile = configuration[OUTPUT_FOLDER]+File.separator+name+"_"+convert(counter)+
    "_"+convert(leftFrame)+"_"+convert(rightFrame)+"_2x1"+outputVideoType;
  if (DEBUG) println("Create video file " + vFile);

  if (videoExport != null) {
    pg.dispose();
  }
  try {
    if (vFormat == FULL_WIDTH_SBS) {
      if (mode == MODE_3D) {
        pg = createGraphics(2*movie.width, movie.height);
        videoExport = new VideoExport(this, vFile, pg);
      } else if (mode == MODE_4V) {
        pg = createGraphics(2*movie.width, 2*movie.height);
        videoExport = new VideoExport(this, vFile, pg);
      }
    } else if (vFormat == FULL_WIDTH_SBS_MERGE) {
      if (mode == MODE_3D) {
        pg = createGraphics(movie.width, movie.height);
        videoExport = new VideoExport(this, vFile, pg);
      }
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
  videoExport.setQuality(70, 128);
  //videoExport.setFrameRate(movie.sourceFrameRate);  // 30 default or uncomment for input movie framerate
  videoExport.startMovie();
  if (DEBUG) println("startMovie() "+videoExport.toString());
  if (videoExport.getFFmpegFound()) {
    if (DEBUG) println("constructor: " + videoExport.toString());
  } else {
    println("Configuration Error: "+ videoExport.ffmpegFound());
    success = false;
  }

  if (success) {
    lMovie = new Movie(this, filenamePath);
    rMovie = new Movie(this, filenamePath);
    savedLeftFrame = leftFrame;
    savedRightFrame = rightFrame;
    videoSetup(lMovie);
    videoSetup(rMovie);
    setFrame(lMovie, leftFrame);
    setFrame(rMovie, rightFrame);
    if (DEBUG) println("after setFrame="+success);
  }
  return success;
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
  } else if (vFormat == FULL_WIDTH_SBS) {
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
  } else if (vFormat == FULL_WIDTH_SBS_MERGE) {
    pg.beginDraw();
    pg.background(0);
    if (leftToRight) {
      pg.imageMode(CORNER);
      pg.image(lMovie, 0, 0, lMovie.width, lMovie.height);
      // overwrites the left image
      pg.clip(width/2, 0, width/2, height);
      pg.image(rMovie, 0, 0, rMovie.width, rMovie.height);
      pg.noClip();
    } else {
      pg.image(lMovie, pg.width/2, 0, lMovie.width/2, rMovie.height);
      pg.image(rMovie, -pg.width/2, 0, rMovie.width/2, rMovie.height);
    }
    pg.endDraw();
    image(pg, 0, height/4, width, (float) width/((float)pg.width/(float)pg.height));
  } else {
    println("Invalid vFormat="+vFormat);
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
    videoExport.endMovie();
    videoExport.dispose();
    lMovie.stop();
    lMovie.dispose();
    rMovie.stop();
    rMovie.dispose();
    lMovie = null;
    rMovie = null;
    saveVideo = FINISHED_VIDEO;
    log("Save video " + vFile);
    //displayMessage("Saved 3D SBS Video: "+configuration[OUTPUT_FOLDER]+File.separator+name+"_2x1.mp4", 60);
    displayMessage("Saved 3D SBS Video: "+vFile, 60);
  }
}
