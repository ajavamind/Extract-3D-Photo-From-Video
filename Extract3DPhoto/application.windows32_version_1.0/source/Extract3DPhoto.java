import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import select.files.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Extract3DPhoto extends PApplet {


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




boolean DEBUG = false;
//boolean DEBUG = true;
String VERSION = "1.0";
String BUILD = str(1);

String filename = "sample_whale_grapefruit_juice_noaudio.mp4";
//String filename ="http://";  // TODO
String filenamePath;
String name;

String outputFolderPath= "output";
//String defaultFilename = "default.txt";
//String configFilename;

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

Movie mov;
int leftFrame = 1;
int rightFrame = 1;
int currentFrame = 1;
int TEXT_SIZE;  // in pixels
int TEXT_SIZE2;  // in pixels

int CROSSHAIR_SIZE = 40;
float CROSSHAIR_SPACING_PERCENT = 1.00f;
float CROSSHAIR_SPACING_INCREMENT = 0.05f;
int MIDHORZ = 6; // for crosshair lines

int[] textColor = {color(128), color(255), color(0), color(255, 0, 0), color(0, 255, 0), color(0, 0, 255) };
int[] crosshairColor = {color(64), color(192), color(128), color(0, 255, 255), color(255, 0, 255), color(255, 255, 0) };
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

public void resetSavedFn() {
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

public void settings() {
  //fullScreen(); // full screen is size of output images
  // all 16:9 aspect ratios
  // size sets fixed size of output images
  //size(2560, 1440);
  size(1920, 1080);
  //size(960, 540);
}

public void setup() {
  background(0);
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

  text("Press Left Mouse Button to Start", 20, 360);
  openFileSystem();

  helpLegend = loadStrings("../help.txt");

  if (filename.toLowerCase().startsWith("http")) {
    name = filename.substring(filename.lastIndexOf("/")+1);
  } else {
    name = filename.substring(0, filename.indexOf("."));
  }

  //name = filename.substring(0, filename.indexOf(".mp4"));
  if (DEBUG) println("name="+name);

  if (DEBUG) println("TEXT_SIZE = "+TEXT_SIZE);
  // Load and set the video to play. Setting the video 
  // in play mode is needed so at least one frame is read
  // and we can get duration, size and other information from
  // the video stream. 
  mov = new Movie(this, filename);

  // Pausing the video at the first frame. 
  rewind(1);

  selectPhotoOutputFolder();
}

public void movieEvent(Movie m) {
  m.read();
}

public void rewind(int frameNo) {
  currentFrame = frameNo;
  mov.play();
  mov.jump(0);
  mov.pause();
  setFrame(currentFrame);
}

public void draw() {
  if (newVideo) {
    newVideo = false;
    mov.stop();
    mov.dispose();
    name = filename.substring(0, filename.toLowerCase().lastIndexOf("."));
    mov = new Movie(this, filenamePath);

    // Pausing the video at the first frame. 
    rewind(1);
  }

  background(0);

  keyUpdate();
  if (screen != null) {
    image(screen, 0, 0, screen.width, screen.height);
  } else {
    image(mov, offsetX, offsetY, width, height);
    if (updated) {
      updated = false;
      savePhoto(name+"_"+counter+"_"+currentFrame+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    }
  }

  if (showHelp == INFO) {
    fill(textColor[textColorIndex]);
    textSize(TEXT_SIZE);
    text("Input: "+filename + " width="+mov.width+" height="+mov.height+" "+mov.frameRate+" FPS", 10, 30);
    //parallax = leftMouseX - rightMouseX;
    text("Output Folder: "+outputFolderPath, 10, 60);
    text("Frame: "+currentFrame + " / " + (getLength() - 1)+ " Type: "+FRAME_TYPE_STR[frameType]
      , 10, 90);

    String lr = "Parallel L/R  ";
    if (!leftToRight) lr = "Crosseye R/L  ";
    text(lr + "Mode: "+ modeString, 10, 120);

    text("Crosshair Spacing: "+CROSSHAIR_SPACING_PERCENT + "% Frame Width", 10, 150);
    //text("Output: " +name+"_"+counter+"_"+currentFrame + FRAME_TYPE_STR[frameType] + outputFileType, 10, 150);
    text("Group Counter: "+counter + " offsetX="+offsetX + " offsetY="+offsetY, 10, 180);
    text("Type H to Toggle Key Command Help", 10, 210);
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

  // check for message and update time on the screen message counter
  if (message != null && msgCounter > 0) {
    //fill(color(128, 32, 128));
    fill(textColor[textColorIndex]);
    text(message, 30, height/2+60);
    msgCounter--;
    if (msgCounter == 0) message = null;
  }
}

public void changeTextColor() {
  textColorIndex++;
  if (textColorIndex >= textColor.length) {
    textColorIndex = 0;
  }
}

public void displayMessage(String msg, int counter) {
  message = msg;
  msgCounter = counter;
}

public void savePhoto(String fn, String prefix, boolean saveName, boolean highRes) {
  String lfn = outputFolderPath+File.separator+prefix+fn;
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
  } else {
    if (highRes) {
      // highest resolution but NO shift vertical or horizontal for alignment of stereo window
      PImage tmp = mov.copy();
      tmp.save(lfn);
      displayMessage("Saved original resolution: "+lfn, 30);
    } else {
      savedAnaglyphFn = lfn;
      displayMessage("Saved: "+lfn, 30);
      screen.save(lfn);
    }
  }

  if (DEBUG) println("Save Photo: " + lfn);
  //displayMessage(lfn, 60);
}

public int getFrame() {    
  return ceil(mov.time() * 30) - 1;
}

public void setFrame(int n) {
  if (DEBUG) println("setFrame("+n+")");
  mov.play();

  // The duration of a single frame:
  float frameDuration = 1.0f / mov.frameRate;

  // We move to the middle of the frame by adding 0.5:
  float where = (n + 0.5f) * frameDuration; 

  // Taking into account border effects:
  float diff = mov.duration() - where;
  if (diff < 0) {
    where += diff - 0.25f * frameDuration;
  }

  mov.jump(where);
  mov.pause();
  mov.play();
  mov.pause();
}  

public int getLength() {
  return PApplet.parseInt(mov.duration() * mov.frameRate);
}

public void play() {
  mov.speed(0.1f);
  if (mov.isPlaying()) {
    mov.pause();
    currentFrame = getFrame();
  } else {
    mov.play();
  }
}

/**
 * Draw vertical lines spaced a percentage of horizontal width
 */
public void drawVerticalLineGrid(float percent) {
  stroke(textColor[textColorIndex]);
  float s = (percent * width)/100.0f;
  for (float d = s; d < PApplet.parseFloat(width); d += s) {
    line(PApplet.parseInt(d), 0, PApplet.parseInt(d), height-1);
  }
}

// Draw horizontal spacing crosshairs for feature alignment and disparity measurement
public void drawSpacingCrosshairs(float x, float y, float percent) {
  if (showCrosshair) {
    float s = (percent * width)/100.0f;
    stroke(crosshairColor[textColorIndex]);
    line(lastMouseX-3*CROSSHAIR_SIZE, y, lastMouseX+3*CROSSHAIR_SIZE, y);
    for (int d = 0; d < (2*MIDHORZ+1); d++) {
      if (d == MIDHORZ ) {
        stroke(crosshairColor[textColorIndex]);
      } else {
        stroke(textColor[textColorIndex]);
      }
      line(x+(PApplet.parseFloat(d)-MIDHORZ)*s, y-2*CROSSHAIR_SIZE, x+(PApplet.parseFloat(d)-MIDHORZ)*s, y+2*CROSSHAIR_SIZE);
    }
    fill(textColor[textColorIndex]);
    text(FRAME_TYPE_STR[frameType], x, y);

    drawFeatureCrosshair(saveMouseX, saveMouseY, percent);
  }
}

public void drawFeatureCrosshair(float x, float y, float percent) {
  if (x == 0 && y == 0) return;
  float s = (percent * width)/100.0f;

  stroke(textColor[textColorIndex]);
  line(x, 0, x, height);
  line(0, y, width, y);
  for (int d = 0; d < (2*MIDHORZ+1); d++) {
    //if (d == MIDHORZ ) {
    stroke(crosshairColor[textColorIndex]);
    //} else {
    //  stroke(textColor[textColorIndex]);
    //}
    line(x+(PApplet.parseFloat(d)-MIDHORZ)*s, y-2*CROSSHAIR_SIZE, x+(PApplet.parseFloat(d)-MIDHORZ)*s, y+2*CROSSHAIR_SIZE);
  }

  if (saveFrameType == FRAME_TYPE_LEFT) {
    text(FRAME_TYPE_STR[saveFrameType], x+CROSSHAIR_SIZE, y-CROSSHAIR_SIZE);
  } else if (saveFrameType == FRAME_TYPE_LEFT_LEFT) {
    text(FRAME_TYPE_STR[saveFrameType], x+CROSSHAIR_SIZE, y-CROSSHAIR_SIZE);
  } else {
    text(FRAME_TYPE_STR[saveFrameType], x+CROSSHAIR_SIZE, y-CROSSHAIR_SIZE);
  }
}
// Create Anaglyph screen

public PImage makeAnaglyph(boolean anaglyph) {
  if (DEBUG) println("makeAnaglyph("+anaglyph+") "+MODE_STR[mode]);
  PImage img = null;
  if (anaglyph) {
    if (mode == MODE_3D) {
      if (leftToRight) {
        img = createAnaglyph(saved3DFn[0], saved3DFn[1]);
      } else {
        img = createAnaglyph(saved3DFn[1], saved3DFn[0]);
      }
      if (img == null) {
        if (DEBUG) println("Could not create anaglyph "+saved3DFn[0]+" "+saved3DFn[1]);
        anaglyph = false;
      }
    }
  }
  return img;
}

public PImage createAnaglyph(String leftFn, String rightFn) {
  PImage img;
  PImage left;
  PImage right;

  left = loadImage(leftFn);
  right = loadImage(rightFn);
  if (!(left != null && left.width > 0)) { 
    displayMessage("Left Image was NOT Saved! "+ leftFn, 120);
    anaglyph = false;
    parallax = 0;
    return null;
  } else if (!(right != null && right.width > 0)) {
    displayMessage("Right Image was NOT Saved! "+ rightFn, 120);
    anaglyph = false;
    parallax = 0;
    return null;
  }
  parallax = leftMouseX - rightMouseX;
  img = colorAnaglyph(left, right);

  return img;
}


private PImage colorAnaglyph(PImage bufL, PImage bufR) {
  // color anaglyph merge left and right images
  // reuse left image for faster performance
  bufL.loadPixels();
  bufR.loadPixels();
  int cr = 0;
  int len = bufL.pixels.length;
  int i = 0;
  while (i < len) {
    cr = bufR.pixels[i];
    bufL.pixels[i] = color(red(bufL.pixels[i]), green(cr), blue(cr));
    i++;
  }
  bufL.updatePixels();
  return bufL;
}

private PImage colorAnaglyph(PImage bufL, PImage bufR, int offset) {
  // color anaglyph merge left and right images
  // reuse left image for faster performance
  if (DEBUG) println("createAnaglyph "+saved3DFn[0] +"   "+saved3DFn[1]);
  if (DEBUG) println("parallax="+parallax);

  bufL.loadPixels();
  bufR.loadPixels();
  int cr = 0;
  int w = bufL.width;
  int h = bufL.height;
  int i = 0;
  int j = w - offset;
  int k = w;
  int len = bufL.pixels.length;
  while (i < len) {
    if (j > 0) {
      cr = bufR.pixels[i ];
      if ((i + offset) < 0  || (i+offset) >= len) {
        println("anaglyph creation out of range, need crosshairs for both left and right "+ (i+offset));
      } else {
        bufR.pixels[i] = color(red(bufL.pixels[i+offset]), green(cr), blue(cr));
      }
      j--;
    } else {
      bufR.pixels[i] = 0;
    }
    k--;
    if (k <= 0) {
      k = w;
      j = w - offset;
    }
    i++;
  }
  bufR.updatePixels();
  return bufR;
}
///**
// Java or Android platform build
// Important Comment out the platform not used in the build
// */

//// Android Platform Build Mode NOT IMPLEMENTED
//final static boolean ANDROID_MODE = true;
//import android.content.SharedPreferences;
//import android.preference.PreferenceManager;
//import android.content.Context;
//import android.app.Activity;
//import select.files.*;
//boolean grantedRead = false;
//boolean grantedWrite = false;

//SelectLibrary files;

//void openFileSystem() {
//  requestPermissions();
//  files = new SelectLibrary(this);
//}

//public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
//  println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
//  for (int i=0; i<permissions.length; i++) {
//    println(permissions[i]);
//  }
//}  


//void requestPermissions() {
//  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
//  }
//  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
//  }
//}

//void handleRead(boolean granted) {
//  if (granted) {
//    grantedRead = granted;
//    println("Granted read permissions.");
//  } else {
//    println("Does not have permission to read external storage.");
//  }
//}

//void handleWrite(boolean granted) {
//  if (granted) {
//    grantedWrite = granted;
//    println("Granted write permissions.");
//  } else {
//    println("Does not have permission to write external storage.");
//  }
//}

//void selectConfigurationFile() {
//  //if (!grantedRead || !grantedWrite) {
//  //  requestPermissions();
//  //}
//  files.selectInput("Select XML Configuration File:", "fileSelected");
//}

//void selectPhotoFolder() {
//  if (saveFolderPath == null) {
//    files.selectFolder("Select Photo Folder", "folderSelected");
//  } else {
//    state = PRE_SAVE_STATE;
//    if (DEBUG) println("saveFolderPath="+saveFolderPath);
//    gui.displayMessage("Save Photos", 30);
//  }
//}

//final String configKey = "ConfigFilename";
//final String photoNumberKey = "photoNumber";
//final String myAppPrefs = "MultiNX";

//void saveConfig(String config) {
//  if (DEBUG) println("saveConfig "+config);
//  SharedPreferences sharedPreferences;
//  SharedPreferences.Editor editor;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  editor = sharedPreferences.edit();
//  editor.putString(configKey, config );
//  editor.commit();
//}

//String loadConfig() {
//  SharedPreferences sharedPreferences;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  String result = sharedPreferences.getString(configKey, null);
//  if (DEBUG) println("loadConfig "+result);
//  return result;
//}

//void savePhotoNumber(int number) {
//  if (DEBUG) println("savePhotoNumber "+number);
//  SharedPreferences sharedPreferences;
//  SharedPreferences.Editor editor;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  editor = sharedPreferences.edit();
//  editor.putInt(photoNumberKey, number );
//  editor.commit();
//}

//int loadPhotoNumber() {
//  SharedPreferences sharedPreferences;
//  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
//  int result = sharedPreferences.getInt(photoNumberKey, 0);
//  if (DEBUG) println("loadPhotoNumber "+result);
//  return result;
//}


//..........................................................................

// Java mode
final static boolean ANDROID_MODE = false;

SelectLibrary files;

public void openFileSystem() {
  files = new SelectLibrary(this);
}

public void selectVideoFile() {
  //if (DEBUG) println("Select Input Video File state="+stateName[state]);
  selectInput("Select Input Video File:", "fileSelected");
}

public void selectPhotoOutputFolder() {
  //  if (outputFolderPath == null) {
  selectFolder("Select Output Photo Folder", "folderSelected");
  //  } else {
  //    if (DEBUG) println("Save Output Folder: "+ outputFolderPath);
  //    displayMessage("Save Output Folder: "+ outputFolderPath, 60);
  //  }
}

public void saveConfig(String config) {
}

public String loadConfig()
{
  return null;
}

public void fileSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("Nothing was selected.");
    displayMessage("No File Selected, Using: "+filename, 60);
  } else {
    if (DEBUG) println("User selected " + selection.getAbsolutePath());
    displayMessage("Video File selected " + selection.getName(), 60);
    //displayMessage("Video File selected " + selection.getAbsolutePath(), 60);
    filenamePath = selection.getAbsolutePath();
    filename = selection.getName();
    if (DEBUG) println("filenamePath="+filenamePath);
    if (DEBUG) println("filename="+filename);
    newVideo = true;
    resetSavedFn();
    counter = 1;
    lastKeyCode = KEYCODE_Z;
  }
}

public void folderSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("No Output Folder Selected.");
    displayMessage("No Output Folder Selected. Using Folder: "+ outputFolderPath, 60);
  } else {
    if (DEBUG) println("Photo Output Folder selected " + selection.getAbsolutePath());
    outputFolderPath = selection.getAbsolutePath();
    displayMessage("Photo Output Folder Selected " + selection.getAbsolutePath(), 60);
  }
}
// Keyboard input handling
// These codes (ASCII) are for Java applications
// Android codes (not implemented) differ with some keys

static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
static final int KEYCODE_ENTER = 10;
static final int KEYCODE_ESCAPE = 27;
static final int KEYCODE_SPACE = 32;
static final int KEYCODE_MINUS = 45;
static final int KEYCODE_0 = 48;
static final int KEYCODE_1 = 49;
static final int KEYCODE_2 = 50;
static final int KEYCODE_3 = 51;
static final int KEYCODE_4 = 52;
static final int KEYCODE_5 = 53;
static final int KEYCODE_6 = 54;
static final int KEYCODE_7 = 55;
static final int KEYCODE_8 = 56;
static final int KEYCODE_9 = 57;
static final int KEYCODE_PLUS = 61;

static final int KEYCODE_A = 65;
static final int KEYCODE_B = 66;
static final int KEYCODE_C = 67;
static final int KEYCODE_D = 68;
static final int KEYCODE_E = 69;
static final int KEYCODE_F = 70;
static final int KEYCODE_G = 71;
static final int KEYCODE_H = 72;
static final int KEYCODE_I = 73;
static final int KEYCODE_J = 74;
static final int KEYCODE_K = 75;
static final int KEYCODE_L = 76;
static final int KEYCODE_M = 77;
static final int KEYCODE_N = 78;
static final int KEYCODE_O = 79;
static final int KEYCODE_P = 80;
static final int KEYCODE_Q = 81;
static final int KEYCODE_R = 82;
static final int KEYCODE_S = 83;
static final int KEYCODE_T = 84;
static final int KEYCODE_U = 85;
static final int KEYCODE_V = 86;
static final int KEYCODE_W = 87;
static final int KEYCODE_X = 88;
static final int KEYCODE_Y = 89;
static final int KEYCODE_Z = 90;
static final int KEYCODE_LEFT_BRACKET = 91;
static final int KEYCODE_RIGHT_BRACKET = 93;
static final int KEYCODE_DEL = 127;
static final int KEYCODE_MEDIA_NEXT = 87;
static final int KEYCODE_MEDIA_PLAY_PAUSE = 85;
static final int KEYCODE_MEDIA_PREVIOUS = 88;
static final int KEYCODE_PAGE_DOWN = 93;
static final int KEYCODE_PAGE_UP = 92;
static final int KEYCODE_PLAY = 126;
static final int KEYCODE_MEDIA_STOP = 86;
static final int KEYCODE_MEDIA_REWIND = 89;
static final int KEYCODE_MEDIA_RECORD = 130;
static final int KEYCODE_MEDIA_PAUSE = 127;
static final int KEYCODE_MOVE_HOME = 122;
static final int KEYCODE_MOVE_END  = 123;

// lastKey and lastKeyCode are handled in the draw loop
int lastKey;
int lastKeyCode;

public void keyReleased() {
}

public void keyPressed() {
  if (DEBUG) println("key="+key + " keyCode="+keyCode);        
  //if (DEBUG) Log.d(TAG, "key=" + key + " keyCode=" + keyCode);
  lastKey = key;
  lastKeyCode = keyCode;
}

// Handling key in the main loop not in keyPressed()
// returns false no key processed
// returns true when a key is processed
public boolean keyUpdate() {
  //if (DEBUG) println("keyUpdate lastKey="+lastKey + " lastKeyCode="+lastKeyCode);
  if (lastKey == 0 && lastKeyCode == 0) {
    return false;
  }

  boolean common = true;
  switch(lastKeyCode) {
  case KEYCODE_G:
    // toggle crosshair display
    showCrosshair = !showCrosshair;
    break;
  case KEYCODE_H:
    showHelp++;
    if (showHelp > NO_HELP) {
      showHelp = INFO;
    }
    break;
  case KEYCODE_W: // debug output including stereo window parallax offset
    parallax = saveMouseX - rightMouseX;
    if (DEBUG) println("anaglyph=" + anaglyph +" parallax="+parallax);
    if (DEBUG) println("lastMouseX="+lastMouseX+" lastMouseY="+lastMouseY);
    if (DEBUG) println("leftMouseX="+leftMouseX + " rightMouseX="+rightMouseX);
    if (DEBUG) println("saveMouseX="+saveMouseX + " saveMouseY="+saveMouseY);
    break;
  case KEYCODE_LEFT_BRACKET:
    CROSSHAIR_SPACING_PERCENT = CROSSHAIR_SPACING_PERCENT-CROSSHAIR_SPACING_INCREMENT;
    break;
  case KEYCODE_RIGHT_BRACKET:
    CROSSHAIR_SPACING_PERCENT = CROSSHAIR_SPACING_PERCENT+CROSSHAIR_SPACING_INCREMENT;
    break;
  case KEYCODE_C:
    changeTextColor();
    break;
  default:
    common = false;
    break;
  }
  if (common) {
    lastKey = 0;
    lastKeyCode = 0;
    return true;
  }

  if (lastKeyCode == KEYCODE_A && mode == MODE_3D) {
    anaglyph = !anaglyph;
    if (anaglyph) {
      screen = makeAnaglyph(true);
      if (screen != null) {
        if (leftToRight) {
          savePhoto(name+"_"+counter+"_"+leftFrame+"L"+rightFrame+"R"+"_ana"+outputFileType, "", false, false);
        } else {
          savePhoto(name+"_"+counter+"_"+rightFrame+"L"+leftFrame+"R"+"_ana"+outputFileType, "", false, false);
        }
      }
    } else {
      screen = null;
    }
    lastKey = 0;
    lastKeyCode = 0;
    return true;
  } else if (anaglyph) {
    if (lastKeyCode == KEYCODE_X) {
      leftToRight = ! leftToRight;
      //} else if (lastKeyCode == LEFT) {
      //  offsetX--;
      //} else if (lastKeyCode == RIGHT) {
      //  offsetX++;
      //} else if (lastKeyCode == UP) {
      //  offsetY--;
      //} else if (lastKeyCode == DOWN) {
      //  offsetY++;
    } else {
      lastKey = 0;
      lastKeyCode = 0;
      return true;
    }
    screen = makeAnaglyph(true);
    if (leftToRight) {
      savePhoto(name+"_"+counter+"_"+leftFrame+"L"+rightFrame+"R"+"_ana"+outputFileType, "", false, false);
    } else {
      savePhoto(name+"_"+counter+"_"+rightFrame+"L"+leftFrame+"R"+"_ana"+outputFileType, "", false, false);
    }
    lastKey = 0;
    lastKeyCode = 0;
    return true;
  }

  switch (lastKeyCode) {
  case KEYCODE_BACKSPACE:
    if (currentFrame > 0 ) {
      currentFrame--;
      offsetX = 0;
      offsetY = 0;
      setFrame(currentFrame);
      frameType = FRAME_TYPE_MISSING;
    }
    break;
  case KEYCODE_SPACE:
    if (currentFrame < getLength() - 1) {
      currentFrame++;
      offsetX = 0;
      offsetY = 0;
      setFrame(currentFrame);
      frameType = FRAME_TYPE_MISSING;
    }
    break;
  case KEYCODE_Z:
    currentFrame = 1;
    offsetX = 0;
    offsetY = 0;
    setFrame(currentFrame);
    frameType = FRAME_TYPE_MISSING;
    lastMouseX = 0;
    lastMouseY = 0;
    break;
  case KEYCODE_TAB:
    currentFrame += 10;
    offsetX = 0;
    offsetY = 0;
    setFrame(currentFrame);
    frameType = FRAME_TYPE_MISSING;
    break;
  case LEFT:
    offsetX--;
    updated = true;
    break;
  case RIGHT:
    offsetX++;
    updated = true;
    break;
  case UP:
    offsetY--;
    updated = true;
    break;
  case DOWN:
    offsetY++;
    updated = true;
    break;
  case KEYCODE_0:
  case KEYCODE_1:
  case KEYCODE_2:
  case KEYCODE_3:
  case KEYCODE_4:
  case KEYCODE_5:
  case KEYCODE_6:
  case KEYCODE_7:
  case KEYCODE_8:
  case KEYCODE_9:
    if (mode == MODE_LENTICULAR) {
      if (lastKeyCode == KEYCODE_0) {
        saveMouseX = lastMouseX;
        saveMouseY = lastMouseY;
        saveFrameType = FRAME_TYPE_BASE_LENTICULAR + lastKeyCode - KEYCODE_0;
      }
      modeString = MODE_STR[mode];
      frameType = FRAME_TYPE_BASE_LENTICULAR + lastKeyCode - KEYCODE_0;
      offsetX += saveMouseX - lastMouseX;
      offsetY += saveMouseY - lastMouseY;
      updated = true;
      //savePhoto(name+"_"+counter+"_"+currentFrame+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    } else {
      displayMessage("Not Lenticular Mode.", 30);
    }
    break;
  case KEYCODE_D: // set mode to 3D
    mode = MODE_3D;
    modeString = MODE_STR[mode];
    resetSavedFn();
    break;
  case KEYCODE_V: // set mode to 4V for Leia LumePad 3D Tablet
    mode = MODE_4V;
    modeString = MODE_STR[mode];
    resetSavedFn();
    break;
  case KEYCODE_Y: // set mode to Single and save
    mode = MODE_SINGLE;
    modeString = MODE_STR[mode];
    frameType = FRAME_TYPE_SINGLE;
    resetSavedFn();
    updated = true;
    break;
  case KEYCODE_T: // set mode to Lenticular
    mode = MODE_LENTICULAR;
    modeString = MODE_STR[mode];
    resetSavedFn();
    break;
  case KEYCODE_P:
    outputFileType = PNG;
    break;
  case KEYCODE_J:
    outputFileType = JPEG;
    break;
  case KEYCODE_B:
    outputFileType = BMP;
    break;
  case KEYCODE_F:
    outputFileType = TIFF;
    break;
  case KEYCODE_I:
    selectVideoFile();
    break;
  case KEYCODE_O:
    selectPhotoOutputFolder();
    break;
  case KEYCODE_K:
    savePhoto(name+"_"+counter+"_"+currentFrame+FRAME_TYPE_STR[frameType]+outputFileType, "F", false, true);
    break;
  case KEYCODE_S:
    //launch(sketchPath("")+"makeSBS.bat");
    if (mode == MODE_3D) {
      if (DEBUG) println("Launch Windows Batch File   "+sketchPath("") + "makeSBS.bat");
      launch(sketchPath("") + "makeSBS.bat "+ saved3DFn[0] + " " + saved3DFn[1] + " "+ outputFolderPath+File.separator +name + "_"+counter);
      displayMessage("Save SBS 3D Photo", 30);
    } else if (mode == MODE_4V) {
      if (DEBUG) println("Launch Windows Batch File   "+sketchPath("")+"make4v.bat");
      launch(sketchPath("") + "make4v.bat "+ saved4VFn[0] + " " + saved4VFn[1] + " "+ 
        saved4VFn[2] + " " + saved4VFn[3] + " " + outputFolderPath+File.separator +name+"_"+counter);
      displayMessage("Save 4V 3D Photo", 30);
    } else if (mode == MODE_LENTICULAR) { // Note: incomplete work in progress
      if (DEBUG) println("Launch Windows Batch File   "+sketchPath("")+"makeLGP.bat");
      launch(sketchPath("") + "makeLGP.bat "+ outputFolderPath + File.separator + name + "_" + counter + " " + 
        savedLentFn[4] + " " + savedLentFn[5] + " " + savedLentFn[6] + " " + savedLentFn[7] + " " +
        savedLentFn[0] + " " + savedLentFn[1] + " " + savedLentFn[2] + " " + savedLentFn[3] );
      displayMessage("Save Quilt 3D Photo", 30);
    }
    break;
  case KEYCODE_L:
    if (mode == MODE_3D) {
      frameType = FRAME_TYPE_LEFT;
      leftFrame = currentFrame;
      leftMouseX = lastMouseX;
    } else if (mode == MODE_4V) {
      frameType = FRAME_TYPE_LEFT_LEFT;
    } else {
      break;
    }
    saveMouseX = lastMouseX;
    saveMouseY = lastMouseY;
    saveFrameType = frameType;
    updated = true;
    //savePhoto(name+"_"+counter+"_"+currentFrame+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    break;
  case KEYCODE_M:
    if (mode == MODE_4V) {
      frameType = FRAME_TYPE_LEFT_MIDDLE;
      offsetX += saveMouseX - lastMouseX;
      offsetY += saveMouseY - lastMouseY;
      updated = true;
      //savePhoto(name+"_"+counter+"_"+currentFrame+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    }
    break;
  case KEYCODE_N:
    if (mode == MODE_4V) {
      frameType = FRAME_TYPE_RIGHT_MIDDLE;
      offsetX += saveMouseX - lastMouseX;
      offsetY += saveMouseY - lastMouseY;
      updated = true;
      //savePhoto(name+"_"+counter+"_"+currentFrame+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    }
    break;
  case KEYCODE_R:
    if (mode == MODE_3D) {
      frameType = FRAME_TYPE_RIGHT;
      rightFrame = currentFrame;
      rightMouseX = lastMouseX;
    } else if (mode == MODE_4V) {
      frameType = FRAME_TYPE_RIGHT_RIGHT;
    } else {
      break;
    }
    offsetX = saveMouseX - lastMouseX;
    offsetY = saveMouseY - lastMouseY;
    updated = true;
    //savePhoto(name+"_"+counter+"_"+currentFrame+FRAME_TYPE_STR[frameType]+outputFileType, "", true, false);
    break;
  case KEYCODE_PLUS:
    counter++;
    resetSavedFn();
    break;
  case KEYCODE_MINUS:
    if (counter > 1) {
      counter--;
      resetSavedFn();
    }
    break;
    // play input video file
  case KEYCODE_MEDIA_PLAY_PAUSE:
  case KEYCODE_PLAY:
  case KEYCODE_ENTER:
    play();
    break;
  default:
    break;
  }

  lastKey = 0;
  lastKeyCode = 0;
  return true;
}

// Mouse input handling

int lastMouseX = 0;
int lastMouseY = 0;

int leftMouseX = 0;
int rightMouseX = 0;

int saveMouseX = 0;
int saveMouseY = 0;
int saveFrameType = 0;

int clickNumber = 1;
boolean firstClick = false; // used to give window focus for key press input

public void mousePressed() {
  if (firstClick) {
    lastKey = 0;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
    frameType = FRAME_TYPE_MISSING;
  }
}

public void mouseReleased() {
  firstClick = true;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Extract3DPhoto" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
