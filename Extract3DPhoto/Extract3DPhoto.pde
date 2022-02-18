
/**
 * Extract 3D and 4V (Leia LumePad format) Photos from sequential frames in a Video File 
 * The video file is a left to right capture sequence creating by trucking the camera.
 * https://blog.storyblocks.com/video-tutorials/7-basic-camera-movements/
 *
 * Copyright 2022 Andy Modla All Rights Reserved
 * Written in Processing by Andy Modla. 
 * 
 * The app uses keyboard and mouse entry. The keyboard issues commands and the mouse generates
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

static final int MODE_3D = 3;
static final int MODE_4V = 4;
int mode = MODE_3D;

static final String MODESTR_3D = "3D";
static final String MODESTR_4V = "4V";

String modeString = MODESTR_3D;

static final String PNG = ".png";
static final String JPG = ".jpg";
String outputFileType = PNG;

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
  parallax = leftMouseX - rightMouseX;
  text("Frame: "+newFrame + " / " + (getLength() - 1)+ " offsetX="+offsetX + " offsetY="+offsetY +" parallax="+parallax, 10, 60);
  
  String lr = "Truck Left to Right ";
  if (!leftToRight) lr = "Truck Right to Left ";
  
  text(lr + "Mode: "+ modeString, 10, 90);
  text("Crosshair Spacing: "+CROSSHAIR_SPACING_PERCENT + "% Frame Width", 10, 120);
  text("Output: " +name+"_"+counter+"_"+newFrame +outputFileType, 10, 150);
  text("Type H for Key Function Legend", 10, 180);

  if (showHelp) {
    textSize(TEXT_SIZE2);
    for (int i=0; i< helpLegend.length; i++) {
      text(helpLegend[i], 10, 240 + i*TEXT_SIZE2);
    }
  } else {
    if (lastMouseX > 0 ) {
      fill(textColor[textColorIndex]);
      //  drawGrid(0.75);
      //  drawCrosshair(lastMouseX, lastMouseY);
      drawCrosshairs(lastMouseX, lastMouseY, CROSSHAIR_SPACING_PERCENT);
    }
  }

  // check for message and update time on the screen message counter
  if (message != null && msgCounter > 0) {
    //fill(color(128, 32, 128));
    fill(textColor[textColorIndex]);
    text(message, 60, height/2);
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

void savePhoto(String fn) {
  save(outputFolderPath+File.separator+fn);
  displayMessage(fn, 20);
}

int counter = 1;

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
