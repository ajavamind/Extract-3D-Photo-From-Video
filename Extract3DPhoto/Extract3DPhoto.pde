/**
 * Extract 3D and 4V (Leia LumePad format) Photos from sequential frames in a Video File 
 * The video file is a left to right capture sequence creating by trucking the camera.
 * https://blog.storyblocks.com/video-tutorials/7-basic-camera-movements/
 *
 * Copyright 2022 Andy Modla All Rights Reserved
 * Written in Processing by Andy Modla. 
 * 
 * The app uses keyboard and mouse click entry. The keyboard issues commands and the mouse generates
 * a crosshair for marking a fixed position in the scene capture in the video.
 * The crosshair should be place on the foreground subject for more positive parallax,
 * and on middle depth subject for negative parallax of the foreground.
 * The app moves through the video one frame at the time using the
 * space and backspace keys. 
 
 * The video frame read technique estimates the frame number using the framerate
 * of the movie file, so it might not be exact for every frame.
 
 * Key commands saves left and right eye frames for a stereo image.
 */

import processing.video.*;

//static final boolean DEBUG = false;
static final boolean DEBUG = true;
static final String VERSION = "1.3"; // bug fixes and add save 3D SBS video
static final String BUILD = str(1);

String filename = "sample_whale_grapefruit_juice_noaudio.mp4";
String filenamePath = filename;
String name;
String defaultOutputFolderPath= "output";

String defaultConfigFilename = "default.txt";
static final int MAX_CONFIG = 3;
String[] configuration = new String[MAX_CONFIG]; // make space for configuration strings
static final int OUTPUT_FOLDER = 0;  // configuration index for output folder path
static final int INPUT_FILENAME = 1;  // configuration index for input file path // TODO
static final int INPUT_FILENAME_PATH = 2;

PImage screen;
boolean anaglyph = false;
boolean newVideo = false;
boolean leftToRight = true;
boolean updated = false;  // screen change requires savePhoto
boolean showCrosshair = true;

static final int MODE_SINGLE = 0;
static final int MODE_3D = 1;
static final int MODE_4V = 2;
static final int MODE_LENTICULAR = 3;
int mode = MODE_3D;  // 3D default mode

static final int NUM_3D = 2;
static final int NUM_4V = 4;
static final int NUM_LENTICULAR = 10;

static final String[] MODE_STR = {"SINGLE", "3D", "4V", "LENTICULAR"};
String modeString = MODE_STR[mode];

static final int FRAME_TYPE_MISSING = 0;
static final int FRAME_TYPE_SINGLE = 1;
static final int FRAME_TYPE_LEFT = 2;
static final int FRAME_TYPE_RIGHT = 3;
static final int FRAME_TYPE_LEFT_LEFT = 4;
static final int FRAME_TYPE_LEFT_MIDDLE = 5;
static final int FRAME_TYPE_RIGHT_MIDDLE = 6;
static final int FRAME_TYPE_RIGHT_RIGHT = 7;
static final int FRAME_TYPE_BASE_LENTICULAR = 8;
static final int FRAME_TYPE_MAX_LENTICULAR = 18;

int frameType = FRAME_TYPE_MISSING;  //FRAME_TYPE_LEFT;
static final String[] FRAME_TYPE_STR = {"", 
  "", 
  "_L", "_R", 
  "_LL", "_LM", "_RM", "_RR", 
  "_00", "_01", "_02", "_03", "_04", "_05", "_06", "_07", "_08", "_09"
};
static final String[] FRAME_3D_LABEL = { "Left  ", "Right "};
static final String[] FRAME_4V_LABEL = { "Left Left   ", "Left Middle ", "Right Middle ", "Right Right  "};
static final String[] FRAME_LENTICULAR_LABEL = { "00 ", "01 ", "02 ", "03 ", "04 ", "05 ", "06 ", "07 ", "08 ", "09 "};

static final String PNG = ".png";
static final String JPEG = ".jpg";
static final String BMP = ".bmp";
static final String TIFF = ".tif";
String outputFileType = JPEG;

String message;
int msgCounter = 0;

Movie movie;

int leftFrame = 0;
int leftMiddleFrame = 0;
int rightMiddleFrame = 0;
int rightFrame = 0;
int currentFrame = 0;
int lrFrameDiff = 0;
float movieAspectRatio;

// Font and Text size
int TEXT_SIZE;  // in pixels
int TEXT_SIZE2;  // in pixels

int CROSSHAIR_SIZE = 40;
float CROSSHAIR_SPACING_PERCENT = 1.00;
float CROSSHAIR_SPACING_INCREMENT = 0.05;
int MIDHORZ = 6; // for crosshair lines

color[] textColor = {color(128), color(255), color(0), color(255, 0, 0), color(0, 255, 0), color(0, 0, 255) };
color[] crosshairColor = {color(64), color(192), color(128), color(0, 255, 255), color(255, 0, 255), color(255, 255, 0) };
int textColorIndex = 4;

static final int INFO = 0;
static final int LEGEND = 1;
static final int NO_HELP = 2;
int showHelp = INFO;
String[] helpLegend;

// current frame display shift
int offsetX = 0;
int offsetY = 0;
int parallax = 0;

// counter numbers a group of images single, 3D, 4V, and Lenticular
// for output filename grouping of the same related images
int counter = 1;  // group counter

static final String emptyStr = "";
String   savedSingleFn = emptyStr;
String[] saved3DFn = { emptyStr, emptyStr};
String[] saved4VFn = { emptyStr, emptyStr, emptyStr, emptyStr};
String[] savedLentFn = { emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr};
String savedAnaglyphFn = emptyStr;

void resetSavedFn() {
  savedSingleFn = emptyStr;
  for (int i=0; i<NUM_3D; i++) {
    saved3DFn[i] = emptyStr;
  }
  for (int i=0; i<NUM_4V; i++) {
    saved4VFn[i] = emptyStr;
  }
  for (int i=0; i<NUM_LENTICULAR; i++) {
    savedLentFn[i] = emptyStr;
  }
  savedAnaglyphFn = emptyStr;
  frameType = FRAME_TYPE_MISSING;
  parallax = 0;
  offsetX = 0;
  offsetY = 0;
  lastMouseX = 0;
  lastMouseY = 0;
  saveMouseX = 0;
  saveMouseY = 0;
  leftMouseX = 0;
  rightMouseX = 0;
}

void settings() {
  //fullScreen(); // full screen is size of output images
  // all 16:9 aspect ratios
  // size sets fixed size of output images
  //size(2560, 1440);
  size(1920, 1080);
  //size(3840, 2160);
  //size(960, 540);

  //openFileSystem(); // for Android
  configuration = loadConfig();
  if (configuration == null) {
    configuration = new String[MAX_CONFIG];
    for (int i=0; i<MAX_CONFIG; i++) {
      configuration[i] = "";
    }
    configuration[OUTPUT_FOLDER] = defaultOutputFolderPath;
  }
}

void setup() {
  background(0);
  // set Landscape orientation
  orientation(LANDSCAPE); 

  TEXT_SIZE = width/80;
  TEXT_SIZE2 = width/120;
  fill(255);
  textSize(TEXT_SIZE);
  surface.setTitle("Extract 3D Photos From a Video File");
  text("Extract 3D Photos From a Video File", 20, 100);
  text("Version "+VERSION+ " BUILD " + BUILD + " "+ (DEBUG ? "DEBUG" : ""), 20, 130);
  text("Copyright 2022 Andy Modla", 20, 160);
  text("All Rights Reserved", 20, 190);
  text("Loading Sample 4K Video File", 20, 300);

  text("Press the Mouse Button to Start", 20, 360);

  helpLegend = loadStrings(sketchPath("data") + File.separator + "help.txt");

  name = filename.substring(0, filename.indexOf("."));

  if (DEBUG) println("name="+name);

  if (DEBUG) println("TEXT_SIZE = "+TEXT_SIZE);

  // Load and set the video to play. Setting the video 
  // in play mode is needed so at least one frame is read
  // and we can get duration, size and other information from
  // the video stream. 
  movie = new Movie(this, filename);

  // Pausing the video at the first frame. 
  rewind(1);

  delay(2000); // To see setup() splash screen up

  selectPhotoOutputFolder();

  movieAspectRatio = (float)movie.width / (float)movie.height;
  if (DEBUG) println("movieAspectRatio="+movieAspectRatio);
}

void movieEvent(Movie m) {
  m.read();
}

void rewind(int frameNo) {
  currentFrame = frameNo;
  movie.play();
  movie.jump(0);
  movie.pause();
  setFrame(movie, currentFrame, true);
}

void draw() {
  if (newVideo) {
    newVideo = false;
    movie.stop();
    movie.dispose();
    name = filename.substring(0, filename.toLowerCase().lastIndexOf("."));
    movie = new Movie(this, filenamePath);
    lrFrameDiff = 0;
    // Pausing the video at the first frame. 
    rewind(1);
    movieAspectRatio = (float)movie.width / (float)movie.height;
    if (DEBUG) println("movieAspectRatio="+movieAspectRatio);
  } else if (saveVideo > NO_VIDEO) {
    if (saveVideo == SETUP_VIDEO) {
      videoSetup();
      saveVideo = WRITE_VIDEO;
    } 
    if (saveVideo == WRITE_VIDEO) {
      videoDraw();
      return;
    } else if (saveVideo == FINISHED_VIDEO) {
      saveVideo = NO_VIDEO;
    }
  } else if (saveLRphoto > NO_LR) {
    if (saveLRphoto == SETUP_READ) {
      lrPhotoSetup();
      saveLRphoto = WRITE_LR;
    } 
    if (saveLRphoto == WRITE_LR) {
      lrPhotoDraw();
      return;
    } else if (saveLRphoto == FINISHED_WRITE_LR) {
      saveLRphoto = NO_LR;
    }
  }


  background(0);

  keyUpdate();
  if (screen != null) {
    image(screen, 0, 0, screen.width, screen.height);
  } else {
    image(movie, offsetX, offsetY, float(height)*movieAspectRatio, height);
    if (updated) {
      updated = false;
      savePhoto(name+"_"+convert(counter)+"_"+getFrame(movie)+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    }
  }

  if (showHelp == INFO) {
    fill(textColor[textColorIndex]);
    textSize(TEXT_SIZE);
    text("Type H To Toggle Keyboard Command List", 10, 30);
    text("Input: "+filenamePath + " width="+movie.width+" height="+movie.height+" "+movie.sourceFrameRate+" FPS "+movie.duration()+" seconds", 10, 60);
    //parallax = leftMouseX - rightMouseX;
    text("Output Folder: "+configuration[OUTPUT_FOLDER], 10, 90);
    //text("Frame: "+currentFrame + " / " + (getLength() - 1)+ " Type: "+FRAME_TYPE_STR[frameType], 10, 120);
    text("Frame: "+getFrame(movie) + " / " + (getLength(movie) - 1)+ " Type: "+FRAME_TYPE_STR[frameType], 10, 120);

    String lr = "Parallel L/R  ";
    if (!leftToRight) lr = "Crosseye R/L  ";
    if (mode == MODE_3D) {
      text(lr + "Mode: " + modeString + " L/R Frame Diff: " + lrFrameDiff, 10, 150);
    } else {
      text(lr + "Mode: "+ modeString, 10, 150);
    }

    text("Crosshair Spacing: "+CROSSHAIR_SPACING_PERCENT + "% Frame Width", 10, 180);
    //text("Output: " +name+"_"+counter+"_"+currentFrame + FRAME_TYPE_STR[frameType] + outputFileType, 10, 150);
    text("Group Counter: "+counter + " offsetX="+offsetX + " offsetY="+offsetY, 10, 210);
    text("Saved Files for Group "+counter+":", 10, 240);

    if (mode == MODE_3D) {
      for (int i=0; i<NUM_3D; i++) {
        text(FRAME_3D_LABEL[i]+saved3DFn[i], 10, 270 + i*30);
      }
      text("Anaglyph "+savedAnaglyphFn, 10, 270 + 2*30);
    } else if (mode == MODE_4V) {
      for (int i=0; i<NUM_4V; i++) {
        text(FRAME_4V_LABEL[i]+saved4VFn[i], 10, 270 + i*30);
      }
    } else if (mode == MODE_LENTICULAR) {
      for (int i=0; i<NUM_LENTICULAR; i++) {
        text(FRAME_LENTICULAR_LABEL[i]+savedLentFn[i], 10, 270 + i*30);
      }
    } else if (mode == MODE_SINGLE) {
      text("SINGLE "+savedSingleFn, 10, 270 );
    }
  }
  if (showHelp == LEGEND) {
    fill(textColor[textColorIndex]);
    textSize(TEXT_SIZE2);
    for (int i=0; i< helpLegend.length; i++) {
      text(helpLegend[i], 10, 30 + i*TEXT_SIZE2);
    }
  } else {
    textSize(TEXT_SIZE);
    if (lastMouseX > 0 || lastMouseY > 0 ) {
      drawSpacingCrosshairs(lastMouseX+offsetX, lastMouseY+offsetY, CROSSHAIR_SPACING_PERCENT);
    }
  }

  if (movie.sourceFrameRate == 0.0) {
    fill(textColor[textColorIndex]);
    text("Internal Error Reading Video File - Convert to MKV or Lower Frame Rate", 30, height/2+120);
  }

  // check for message and update time on the screen message counter
  if (message != null && msgCounter > 0) {
    //fill(color(128, 32, 128));
    fill(textColor[textColorIndex]);
    text(message, 30, height/2+60);
    msgCounter--;
    if (msgCounter == 0) message = null;
  }
}

void changeTextColor() {
  textColorIndex++;
  if (textColorIndex >= textColor.length) {
    textColorIndex = 0;
  }
}

void displayMessage(String msg, int counter) {
  message = msg;
  msgCounter = counter;
}

int getFrame(Movie movie) {    
  return ceil(movie.time() * 30) - 1;
}

void setFrame(Movie movie, int n, boolean doPlay) {
  if (DEBUG) println(movie.toString()+ " setFrame("+n+") " + doPlay);
  movie.play();

  // The duration of a single frame:
  float frameDuration = 1.0 / movie.sourceFrameRate;

  // We move to the middle of the frame by adding 0.5:
  float where = (n + 0.5) * frameDuration; 

  // Taking into account border effects:
  float diff = movie.duration() - where;
  if (diff < 0) {
    where += diff - 0.25 * frameDuration;
  }

  movie.jump(where);
  movie.pause();
  if (doPlay) {
    movie.play();   // Verify TODO for video save
    movie.pause();  // Verify TODO for video save
  }
}  

/**
 * Get length of movie as frame count
 */
int getLength(Movie mov) {
  return int(mov.duration() * mov.sourceFrameRate);
}

void play() {
  movie.speed(0.1);
  if (movie.isPlaying()) {
    movie.pause();
    currentFrame = getFrame(movie);
  } else {
    movie.play();
  }
}

/**
 * Draw vertical lines spaced a percentage of horizontal width
 */
void drawVerticalLineGrid(float percent) {
  stroke(textColor[textColorIndex]);
  float s = (percent * width)/100.0;
  for (float d = s; d < float(width); d += s) {
    line(int(d), 0, int(d), height-1);
  }
}

// Draw horizontal spacing crosshairs for feature alignment and disparity measurement
void drawSpacingCrosshairs(float x, float y, float percent) {
  if (showCrosshair) {
    float s = (percent * width)/100.0;
    stroke(crosshairColor[textColorIndex]);
    line(lastMouseX-3*CROSSHAIR_SIZE, y, lastMouseX+3*CROSSHAIR_SIZE, y);
    for (int d = 0; d < (2*MIDHORZ+1); d++) {
      if (d == MIDHORZ ) {
        stroke(crosshairColor[textColorIndex]);
      } else {
        stroke(textColor[textColorIndex]);
      }
      line(x+(float(d)-MIDHORZ)*s, y-2*CROSSHAIR_SIZE, x+(float(d)-MIDHORZ)*s, y+2*CROSSHAIR_SIZE);
    }
    fill(textColor[textColorIndex]);
    text(FRAME_TYPE_STR[frameType], x, y);

    drawFeatureCrosshair(saveMouseX, saveMouseY, percent);
  }
}

void drawFeatureCrosshair(float x, float y, float percent) {
  if (x == 0 && y == 0) return;
  float s = (percent * width)/100.0;

  stroke(textColor[textColorIndex]);
  line(x, 0, x, height);
  line(0, y, width, y);
  for (int d = 0; d < (2*MIDHORZ+1); d++) {
    //if (d == MIDHORZ ) {
    stroke(crosshairColor[textColorIndex]);
    //} else {
    //  stroke(textColor[textColorIndex]);
    //}
    line(x+(float(d)-MIDHORZ)*s, y-2*CROSSHAIR_SIZE, x+(float(d)-MIDHORZ)*s, y+2*CROSSHAIR_SIZE);
  }

  if (saveFrameType == FRAME_TYPE_LEFT) {
    text(FRAME_TYPE_STR[saveFrameType], x+CROSSHAIR_SIZE, y-CROSSHAIR_SIZE);
  } else if (saveFrameType == FRAME_TYPE_LEFT_LEFT) {
    text(FRAME_TYPE_STR[saveFrameType], x+CROSSHAIR_SIZE, y-CROSSHAIR_SIZE);
  } else {
    text(FRAME_TYPE_STR[saveFrameType], x+CROSSHAIR_SIZE, y-CROSSHAIR_SIZE);
  }
}
