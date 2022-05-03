// Save frame photos

private static final int NO_LR = 0;
private static final int SETUP_READ = 1;
private static final int WRITE_LR = 2;
private static final int FINISHED_WRITE_LR = 3;
int saveLRphoto = NO_LR;

String leftFile;
String rightFile;
String eFile;
int eFrame = 0;

// Extract Photos from Video File
void ePhotoSetup() {
  // Load and set the video to play. Setting the video 
  // in play mode is needed so at least one frame is read
  // and we can get duration, size and other information from
  // the video stream. 
  eFrame = 0;
  setFrame(movie, eFrame);
}

void ePhotoDraw() {
  background(0);
  fill(0);

  image(movie, 0, (height-(width/2)/movieAspectRatio)/2, (width/2), (width/2)/movieAspectRatio);
  fill(255);
  text(getFrame(movie) + " / " + (getLength(movie)-1), 0, height-20);
  eFrame = getFrame(movie);
  eFile = configuration[OUTPUT_FOLDER]+File.separator+name+"_F"+convert(eFrame)+outputFileType;
  if (DEBUG) println("Create photo files " + eFile);

  PImage tmp = movie.copy();
  tmp.save(eFile);
  log("Save photo "+eFile);
  eFrame++;
  //leftFrame++;
  //rightFrame++;
  //setFrame(movie, leftFrame);  
  //if (rightFrame >getLength(rMovie)) {
  if (eFrame > getLength(movie)) {
    if (DEBUG) println("LR Photos saved ");
    saveLRphoto = FINISHED_WRITE_LR;
    displayMessage("Finished extracting frame photos from video.", 60);
  } else {
    setFrame(movie, eFrame);
  }
}

void lrPhotoSetup() {
  // Load and set the video to play. Setting the video 
  // in play mode is needed so at least one frame is read
  // and we can get duration, size and other information from
  // the video stream. 
  lMovie = new Movie(this, filenamePath);
  rMovie = new Movie(this, filenamePath);
  videoSetup(lMovie);
  videoSetup(rMovie);
  setFrame(lMovie, leftFrame);  
  setFrame(rMovie, rightFrame);
}

void lrPhotoDraw() {
  background(0);
  fill(0);

  image(lMovie, 0, (height-(width/2)/movieAspectRatio)/2, (width/2), (width/2)/movieAspectRatio);
  image(rMovie, width/2, (height-(width/2)/movieAspectRatio)/2, (width/2), (width/2)/movieAspectRatio);   
  //if (DEBUG) {
  fill(255);
  text(getFrame(lMovie) + " / " + (getLength(lMovie)-1), 0, height-20);
  text(getFrame(rMovie) + " / " + (getLength(rMovie)-1), width/2, height-20);
  //}

  leftFile = configuration[OUTPUT_FOLDER]+File.separator+name+"_"+counter+"_F"+convert(leftFrame)+"_"+convert(rightFrame)+"_L"+outputFileType;
  rightFile = configuration[OUTPUT_FOLDER]+File.separator+name+"_"+counter+"_F"+convert(leftFrame)+"_"+convert(rightFrame)+"_R"+outputFileType;
  if (DEBUG) println("Create photo files " + leftFile);
  if (DEBUG) println("Create photo files " + rightFile);

  PImage tmpl = lMovie.copy();
  tmpl.save(leftFile);
  log("Save left photo "+leftFile);
  PImage tmpr = rMovie.copy();
  tmpr.save(rightFile);
  log("Save right photo "+rightFile);

  leftFrame++;
  rightFrame++;
  setFrame(lMovie, leftFrame);  
  setFrame(rMovie, rightFrame);  
  if (rightFrame >getLength(rMovie)) {
    if (DEBUG) println("LR Photos saved ");
    saveLRphoto = FINISHED_WRITE_LR;
    lMovie.dispose();
    rMovie.dispose();
    displayMessage("Finished saving LR Photos from video ", 60);
  }
}

void savePhoto(String fn, String prefix, boolean saveName, boolean highRes) {
  String lfn = configuration[OUTPUT_FOLDER]+File.separator+prefix+fn;
  if (saveName) {
    if (mode == MODE_SINGLE) {
      savedSingleFn = lfn;
    } else if (frameType == FRAME_TYPE_MISSING) {
      displayMessage("Frame Type Not Set", 60);
      return;
    }

    if (mode == MODE_3D) {
      saved3DFn[frameType-FRAME_TYPE_LEFT] = lfn;
    } else if (mode == MODE_4V) {
      saved4VFn[frameType - FRAME_TYPE_LEFT_LEFT] = lfn;
    } else if (mode == MODE_LENTICULAR) {
      savedLentFn[frameType - FRAME_TYPE_BASE_LENTICULAR] = lfn;
    }
    save(lfn);
    log("Save photo "+lfn);
  } else {
    if (highRes) {
      // highest resolution but NO shift vertical or horizontal for alignment of stereo window
      PImage tmp = movie.copy();
      tmp.save(lfn);
      log("Save photo "+lfn);
      displayMessage("Saved original resolution: "+lfn, 60);
    } else {
      savedAnaglyphFn = lfn;
      displayMessage("Saved: "+lfn, 60);
      screen.save(lfn);
      log("Save photo "+lfn);
    }
  }
  if (DEBUG) println("savePhoto() " + lfn);
}

private String convert(int value) {
  if (value <10) {
    return ("000"+value);
  } else if (value <100) {
    return ("00"+value);
  } else if (value <1000)
    return ("0"+value);
  return str(value);
}
