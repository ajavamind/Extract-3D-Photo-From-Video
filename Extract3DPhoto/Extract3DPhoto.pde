
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
 
 * It estimates the frame counts using the framerate
 * of the movie file, so it might not be exact in some cases.
 
 * Key commands sSaves left and right eye frames for a stereo image.
 */

import processing.video.*;
import select.files.*;

//boolean DEBUG = false;
boolean DEBUG = true;
String VERSION = "1.0";
String BUILD = str(1);

String filename = "sample_whale_grapefruit_juice.mp4";
String filenamePath;
String name;

String outputFolderPath= "output";
//String defaultFilename = "default.txt";
//String configFilename;

PImage screen;
boolean anaglyph = false;
boolean newVideo = false;
boolean leftToRight = true;

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
static final String[] FRAME_4V_LABEL = { "Left Left   ", "Left Middle", "Right Middle ", "Right Right  "};
static final String[] FRAME_LENTICULAR_LABEL = { "00 ", "01 ", "02 ", "03 ", "04 ", "05 ", "06 ", "07 ", "08 ", "09 "};

static final String PNG = ".png";
static final String JPG = ".jpg";
static final String BMP = ".bmp";
String outputFileType = JPG;

String message;
int msgCounter = 0;

Movie mov;
int leftFrame = 1;
int rightFrame = 1;
int newFrame = 1;
int TEXT_SIZE;  // in pixels
int TEXT_SIZE2;  // in pixels

int CROSSHAIR_SIZE = 40;
float CROSSHAIR_SPACING_PERCENT = 0.75;
float CROSSHAIR_SPACING_INCREMENT = 0.05;
color[] textColor = {color(128), color(255), color(0), color(255, 0, 0), color(0, 255, 0), color(0, 0, 255) };
color[] crosshairColor = {color(64), color(192), color(128), color(0, 255, 255), color(255, 0, 255), color(255, 255, 0) };
int textColorIndex = 4;

boolean showHelp = false;
String[] helpLegend;

// current frame display shift
int offsetX = 0;
int offsetY = 0;
int parallax = 0;

// counter numbers a group of images single, 3D, 4V, and Lenticular
// for output filename grouping of the same related images
int counter = 1;

static final String emptyStr = "";
String   savedSingleFn = emptyStr;
String[] saved3DFn = { emptyStr, emptyStr};
String[] saved4VFn = { emptyStr, emptyStr, emptyStr, emptyStr};
String[] savedLenticularFn = { emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr, emptyStr};
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
    savedLenticularFn[i] = emptyStr;
  }
  savedAnaglyphFn = emptyStr;
  frameType = FRAME_TYPE_MISSING;
  parallax = 0;
  offsetX = 0;
  offsetY = 0;
}

void settings() {
  //fullScreen(); // full screen is size of output images
  // all 16:9 aspect ratios
  // size sets fixed size of output images
  //size(2560, 1440);
  size(1920, 1080);
  //size(960, 540);
}

void setup() {
  background(0);
  TEXT_SIZE = width/80;
  TEXT_SIZE2 = width/120;
  fill(255);
  textSize(TEXT_SIZE);
  text("Extract 3D Photo From Video File", 20, 100);
  text("Version "+VERSION+ " BUILD " + BUILD + " "+ (DEBUG ? "DEBUG" : ""), 20, 130);
  text("Copyright 2022 Andy Modla", 20, 160);
  text("All Rights Reserved", 20, 190);
  text("Loading Sample 4K Video File", 20, 300);

  text("Do Mouse Click to Start", 20, 360);
  openFileSystem();

  helpLegend = loadStrings("../help.txt");

  name = filename.substring(0, filename.indexOf(".mp4"));
  if (DEBUG) println(name);

  if (DEBUG) println("TEXT_SIZE = "+TEXT_SIZE);
  // Load and set the video to play. Setting the video 
  // in play mode is needed so at least one frame is read
  // and we can get duration, size and other information from
  // the video stream. 
  mov = new Movie(this, filename);

  // Pausing the video at the first frame. 
  mov.play();
  mov.jump(0);
  mov.pause();
  setFrame(newFrame);

  selectPhotoOutputFolder();
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  if (newVideo) {
    newVideo = false;
    mov.stop();
    mov.dispose();
    newFrame = 1;
    name = filename.substring(0, filename.indexOf(".mp4"));
    mov = new Movie(this, filenamePath);

    // Pausing the video at the first frame. 
    mov.play();
    mov.jump(0);
    mov.pause();
    setFrame(newFrame);
  }

  background(0);
  if (screen != null) {
    image(screen, 0, 0, screen.width, screen.height);
  } else {
    image(mov, offsetX, offsetY, width, height);
  }
  keyUpdate();

  fill(textColor[textColorIndex]);
  textSize(TEXT_SIZE);
  text("Input: "+filename, 10, 30);
  //parallax = leftMouseX - rightMouseX;
  text("Frame: "+newFrame + " / " + (getLength() - 1)+ " offsetX="+offsetX + " offsetY="+offsetY +" parallax="+parallax, 10, 60);

  String lr = "Truck Left to Right ";
  if (!leftToRight) lr = "Truck Right to Left ";
  text(lr + "Mode: "+ modeString, 10, 90);

  text("Crosshair Spacing: "+CROSSHAIR_SPACING_PERCENT + "% Frame Width", 10, 120);
  //text("Output: " +name+"_"+counter+"_"+newFrame + FRAME_TYPE_STR[frameType] + outputFileType, 10, 150);
  text("Group Counter: "+counter + " "+ modeString + " Frame Type "+FRAME_TYPE_STR[frameType], 10, 150);
  text("Type H for Key Function Legend", 10, 180);
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
      text(FRAME_LENTICULAR_LABEL[i]+savedLenticularFn[i], 10, 270 + i*30);
    }
  } else if (mode == MODE_SINGLE) {
    text("SINGLE "+savedSingleFn, 10, 270 );
  }

  if (showHelp) {
    textSize(TEXT_SIZE2);
    for (int i=0; i< helpLegend.length; i++) {
      text(helpLegend[i], width/2, 30 + i*TEXT_SIZE2);
    }
  } else {
    if (lastMouseX > 0 ) {
      fill(textColor[textColorIndex]);
      text(FRAME_TYPE_STR[frameType], lastMouseX, lastMouseY);
      drawCrosshairs(lastMouseX, lastMouseY, CROSSHAIR_SPACING_PERCENT);
    }
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

void savePhoto(String fn, boolean saveName) {
  String lfn = outputFolderPath+File.separator+fn;
  if (saveName) {
    if (mode == MODE_SINGLE) {
      savedSingleFn = lfn;
    }
    if (frameType ==FRAME_TYPE_MISSING) {
      displayMessage("Frame Type Not Set", 60);
      return;
    }

    if (mode == MODE_3D) {
      saved3DFn[frameType-FRAME_TYPE_LEFT] = lfn;
    } else if (mode == MODE_4V) {
      saved4VFn[frameType - FRAME_TYPE_LEFT_LEFT] = lfn;
    } else if (mode == MODE_LENTICULAR) {
      savedLenticularFn[frameType - FRAME_TYPE_BASE_LENTICULAR] = lfn;
    }
  } else {
    savedAnaglyphFn = lfn;
  }

  save(lfn);
  if (DEBUG) println("Save Photo: " + lfn);
  //displayMessage(lfn, 60);
}

int getFrame() {    
  return ceil(mov.time() * 30) - 1;
}

void setFrame(int n) {
  mov.play();

  // The duration of a single frame:
  float frameDuration = 1.0 / mov.frameRate;

  // We move to the middle of the frame by adding 0.5:
  float where = (n + 0.5) * frameDuration; 

  // Taking into account border effects:
  float diff = mov.duration() - where;
  if (diff < 0) {
    where += diff - 0.25 * frameDuration;
  }

  mov.jump(where);
  mov.pause();
  if (DEBUG) println("setFrame("+n+")");
}  

int getLength() {
  return int(mov.duration() * mov.frameRate);
}

void play() {
  mov.speed(0.1);
  if (mov.isPlaying()) {
    mov.pause();
    newFrame = getFrame();
  } else {
    mov.play();
  }
}

/**
 * Draw vertical lines spaced a percentage of horizontal width
 */

void drawGrid(float percent) {
  stroke(textColor[textColorIndex]);
  float s = (percent * width)/100.0;
  for (float d = s; d < float(width); d += s) {
    line(int(d), 0, int(d), height-1);
  }
}

void drawCrosshairs(float x, float y, float percent) {
  float s = (percent * width)/100.0;
  stroke(crosshairColor[textColorIndex]);
  line(lastMouseX-3*CROSSHAIR_SIZE, lastMouseY, lastMouseX+3*CROSSHAIR_SIZE, lastMouseY);
  for (int d = 0; d < 11; d++) {
    if (d == 5 ) {
      stroke(crosshairColor[textColorIndex]);
    } else {
      stroke(textColor[textColorIndex]);
    }
    line(x+(float(d)-5)*s, y-2*CROSSHAIR_SIZE, x+(float(d)-5)*s, y+2*CROSSHAIR_SIZE);
  }
}

void drawCrosshair(float x, float y) {
  stroke(crosshairColor[textColorIndex]);
  line(x-CROSSHAIR_SIZE, y, x+CROSSHAIR_SIZE, y);
  line(x, y-CROSSHAIR_SIZE, x, y+CROSSHAIR_SIZE);
}
